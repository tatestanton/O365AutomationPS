Connect-MsolService


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


$Outfilename = "C:\temp\License-Done.csv"

$AudioConferencing = "hiveitservices:MCOMEETADV"
$G1="hiveitservices:O365_BUSINESS_ESSENTIALS"
$G3="hiveitservices:O365_BUSINESS_PREMIUM"
#$UPNCheck="*doit.nh.gov"
$UPNCheck="*hiveitservices.onmicrosoft.com"



foreach ($entry in $users) {

    $upn=$entry.UserPrincipalName
    $Mailbox=Get-Recipient $upn
    Set-MsolUser -UserPrincipalName $UPN -UsageLocation "US" 
    
          
    If ($upn -like $UPNCheck)

        {

            ##If users are Doit they will receive all of the apps a G3 license and audio conferencing. They will have MFA enabled

            
            ### ASSIGN G3 
            $AcctSku= $G3

            ## Adding G3 license from $accountSKU variable
            Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AcctSku

            ##Adding audioconferencing
            #Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AudioConferencing

            ## ASSIGN MFA
            $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
            $st.RelyingParty = "*"
            $st.State = "Enabled"
            $sta = @($st)

            Set-MsolUser -UserPrincipalName $UPN -StrongAuthenticationRequirements $sta
    
            Get-MsolUser -UserPrincipalName $upn | Select-object UserPrincipalName, Islicensed | Export-Csv $outFileName -Append -NoTypeInformation
    
        }


    Elseif ($Mailbox.CustomAttribute2 -eq "StoreEmployee") { 
    
        ##If users have customattribute StoreEmployee they will receive G1 license with disabled apps and no audio conferencing. They will also not have MFA enabled

        $AcctSku= $G1

        ##In GOV tenant, service plans are called differently so this has to be adjusted
        ##$MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku -DisabledPlans "FORMS_GOV_E3","POWERAPPS_O365_P2_GOV","FLOW_O365_P2_GOV","MCOSTANDARD_GOV"   
        $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku -DisabledPlans "FORMS_PLAN_E1","POWERAPPS_O365_P1","FLOW_O365_P1","MCOSTANDARD"      


        Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AcctSku -LicenseOptions $MyServicePlans
        Get-MsolUser -UserPrincipalName $upn | Select-object UserPrincipalName, Islicensed | Export-Csv $outFileName -Append -NoTypeInformation
           
    }

    else {
            ###Else users will receive G3 license with disabled apps and audio conferencing and will have MFA enabled.
            $AcctSku= $G3
            $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku -DisabledPlans "FORMS_PLAN_E1","POWERAPPS_O365_P1","FLOW_O365_P1","MCOSTANDARD" 
                 
            ## Adding G3 license from $accountSKU variable
            Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AcctSku -LicenseOptions $MyServicePlans

            ##Adding audioconferencing
            #Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AudioConferencing

            ## ASSIGN MFA
            $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
            $st.RelyingParty = "*"
            $st.State = "Enabled"
            $sta = @($st)

            Set-MsolUser -UserPrincipalName $UPN -StrongAuthenticationRequirements $sta
            Get-MsolUser -UserPrincipalName $upn | Select-object UserPrincipalName, Islicensed | Export-Csv $outFileName -Append -NoTypeInformation
    
    }
    
     
}#foreach