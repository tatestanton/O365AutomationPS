Connect-MsolService
Connect-ExchangeOnline

       
       $users= import-csv "C:\csv\Liquor2.csv"
       
       
       $Outfilename = "C:\csv\License-Done.csv"
       
       $AudioConferencing = "nhgov:MCOMEETADV_GOV"
       $G1="nhgov:STANDARDPACK_GOV"
       $G3="nhgov:ENTERPRISEPACK_GOV"
       $UPNCheck="*Onedrive.X.Test3@doit.nh.gov"
       
       
       
       foreach ($entry in $users) {
       
           $upn=$entry.UserPrincipalName
           $Mailbox=Get-Recipient $upn
           Set-MsolUser -UserPrincipalName $UPN -UsageLocation "US" 
           
                 
           If ($upn -like $UPNCheck)
       
               {
       
                   ##If users are Doit they will receive all of the apps a G3 license and audio conferencing. They will have MFA enabled
       
                   
                   ### ASSIGN G3 
                   $AcctSku1= $G3
                   #Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $G3
                   ## Adding G3 license from $accountSKU variable
                   Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AcctSku1
       
                   ##Adding audioconferencing
                   Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AudioConferencing
       
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
       
               $AcctSku2= $G1
               #Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $G1
               ##In GOV tenant, service plans are called differently so this has to be adjusted
               ##$MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku -DisabledPlans "FORMS_GOV_E3","POWERAPPS_O365_P2_GOV","FLOW_O365_P2_GOV","MCOSTANDARD_GOV"   
               $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku2 -DisabledPlans "FORMS_GOV_E1","POWERAPPS_O365_P1_GOV","FLOW_O365_P1_GOV","MCOSTANDARD_GOV"     
       
       
               Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AcctSku2 -LicenseOptions $MyServicePlans
               Get-MsolUser -UserPrincipalName $upn  | Select-object UserPrincipalName, Islicensed | Export-Csv $outFileName -Append -NoTypeInformation -FOrce
                  
           }
       
           else {
                   ###Else users will receive G3 license with disabled apps and audio conferencing and will have MFA enabled.
                   $AcctSku3= $G3
                   $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku3 -DisabledPlans "FORMS_GOV_E3","POWERAPPS_O365_P2_GOV","FLOW_O365_P2_GOV","MCOSTANDARD_GOV"   
                   #Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $G3 
                   ## Adding G3 license from $accountSKU variable
                   Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AcctSku3 -LicenseOptions $MyServicePlans
       
                   ##Adding audioconferencing
                   Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AudioConferencing
       
                   ## ASSIGN MFA
                   $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
                   $st.RelyingParty = "*"
                   $st.State = "Enabled"
                   $sta = @($st)
       
                   Set-MsolUser -UserPrincipalName $UPN -StrongAuthenticationRequirements $sta
                   Get-MsolUser -UserPrincipalName $upn | Select-object UserPrincipalName, Islicensed | Export-Csv $outFileName -Append -NoTypeInformation
           
           }
           
            
       }#foreach

