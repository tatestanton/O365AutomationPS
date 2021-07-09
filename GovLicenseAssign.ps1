Import-Module MSonline
Connect-MsolService
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline


### classic Exchange online session is needed because of the extensionattribute
[string]$userName = ''
[string]$userPassword = ''
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Import-PSSession ( New-PSSession -ConfigurationName Microsoft.Exchange  `
        -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credObject -Authentication Basic -AllowRedirection)


#import users CSV needs to be in format 'Userprincipalname;UsageLocation

$users= import-csv "C:\temp\UserLicense.csv"
## this has to be modified
$AcctSku= (Get-MsolAccountSku |? AccountSkuId -like "nhgov:ENTERPRISEPACK_GOV")
$Outfilename = "C:\temp\License-Done.csv"
$accountSkuId2 = "nhgov:MCOMEETADV_GOV"
$licenseOptions2 = New-MsolLicenseOptions -AccountSkuId $accountSkuId2



foreach ($entry in $users) {
    $upn=$entry.UserPrincipalName
    $user= Get-MsolUser -UserPrincipalName $upn
    $Mailbox=Get-Mailbox $upn
           
    If ($upn -like "*doit.nh.gov")

        {
            ### ASSIGN G3 
            $AcctSku= "nhgov:M365_G3_GOV"
            $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku -DisabledPlans "FORMS_GOV_E3","POWERAPPS_O365_P2_GOV","FLOW_O365_P2_GOV","MCOSTANDARD_GOV"             
            
            Set-MsolUser -UserPrincipalName $UPN -UsageLocation "US"
        

            ## ASSIGN MFA
            $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
            $st.RelyingParty = "*"
            $st.State = "Enabled"
            $sta = @($st)

            Set-MsolUser -UserPrincipalName $UPN -StrongAuthenticationRequirements $sta
    
            Get-MsolUser -UserPrincipalName $upn | Select-object UserPrincipalName, Islicensed | Export-Csv $outFileName -Append -NoTypeInformation
    
        }


    Elseif ($Mailbox.CustomAttribute2 -eq "StoreEmployee") { 
    
        
        $AcctSku= "nhgov:ENTERPRISEPACK_GOV"
        $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku -DisabledPlans "FORMS_GOV_E3","POWERAPPS_O365_P2_GOV","FLOW_O365_P2_GOV","MCOSTANDARD_GOV"   
                  
        if ($user.licenses.AccountSkuId -notlike "nhgov:ENTERPRISEPACK_GOV")
            {

            Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AcctSku -LicenseOptions $MyServicePlans
            Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $accountSkuId2
            
            #Needs to be discussed as IMO this is not needed since there are no disabled plans
            #Set-MsolUserLicense -UserPrincipalName $upn -LicenseOptions $licenseOptions2
            Get-MsolUser -UserPrincipalName $upn | Select-object UserPrincipalName, Islicensed | Export-Csv $outFileName -Append -NoTypeInformation
            }
    }

    else {
    
            
        "User $UPN does not meet any of the licensing criteria" | Export-Csv $outFileName -Append -NoTypeInformation
    
    }
    
     
}#foreach