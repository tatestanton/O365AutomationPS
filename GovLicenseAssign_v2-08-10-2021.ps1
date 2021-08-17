Connect-MsolService
#Need ExchangeOnline for Group membership adds
Connect-ExchangeOnline

$userRunningthescript=whoami

       
       $users= import-csv "C:\csv\Liquor2.csv"
       
       
       $Outfilename = "C:\csv\License-DoneNew.csv"
       
       $AudioConferencing = "nhgov:MCOMEETADV_GOV"
       $G1="nhgov:STANDARDPACK_GOV"
       $G3="nhgov:ENTERPRISEPACK_GOV"
       $UPNCheck="*doit.nh.gov"
       $upnCheck2="*doc.nh.gov"
       $UPNCheck3="*dot.nh.gov"
       
       
       foreach ($entry in $users) {
       
           $upn=$entry.UserPrincipalName
           $Mailbox=Get-Recipient $upn
           Set-MsolUser -UserPrincipalName $UPN -UsageLocation "US" 
           
                 
           If ($upn -like $UPNCheck)
       
               {
       
                   ##If users are Doit they will receive all of the apps a G3 license and audio conferencing and MFA will be enabled
       
                   
                   ### ASSIGN G3 
                   $AcctSku1= $G3
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
          
           
               }

       elseif ($upn -like $upnCheck2) {
                   ##UPNCheck2 users (DOC) will receive 16 apps without MFA
                   $AcctSku3= $G3
                   $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku3 -DisabledPlans "FORMS_GOV_E3","POWERAPPS_O365_P2_GOV","FLOW_O365_P2_GOV","MCOSTANDARD_GOV"   
                   ## Adding G3 license from $accountSKU variable
                   Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AcctSku3 -LicenseOptions $MyServicePlans
       
                   ##Add audioconferencing
                   Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AudioConferencing
      
           
           }
       
           Elseif ($Mailbox.CustomAttribute2 -eq "StoreEmployee") { 
           
               ##If users have customattribute StoreEmployee they will receive G1 license with disabled apps and no audio conferencing. They will also not have MFA enabled
       
               $AcctSku2= $G1

               ##In GOV tenant, service plans are named differently so this has to be adjusted
               ##Note:G1 Disabled Plans are named differently in the G1 plan $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku -DisabledPlans "FORMS_GOV_E3","POWERAPPS_O365_P2_GOV","FLOW_O365_P2_GOV","MCOSTANDARD_GOV"   
               $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku2 -DisabledPlans "FORMS_GOV_E1","POWERAPPS_O365_P1_GOV","FLOW_O365_P1_GOV","MCOSTANDARD_GOV"     
       
       
               Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $AcctSku2 -LicenseOptions $MyServicePlans
                  
                  
           }

           #Add DOT to Group DOT-EOLMB-RES-All-BookIn
           Elseif ($upn -like $UPNCheck3) {


                    ###Else users will receive G3 license with disabled apps and audio conferencing and will have MFA enabled.
                   $AcctSku3= $G3
                   $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku3 -DisabledPlans "FORMS_GOV_E3","POWERAPPS_O365_P2_GOV","FLOW_O365_P2_GOV","MCOSTANDARD_GOV"   

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
                   #Add DOT-EOLMB-RES-All-BookIn

                   Add-DistributionGroupMember -Identity "DOT-EOLMB-RES-All-BookIn" -Member $upn
                   
                   
                   #Set variable to retrieve and store the ObjectID
                   #$group= Get-MsolGroup -SearchString "DOT-EOLMB-RES-All-BookIn"
                   #Add-UnifiedGroupLinks

                   #Get-command -module exchangeonlinemanagement
       
           else {
                   ###Else users will receive G3 license with disabled apps and audio conferencing and will have MFA enabled.
                   $AcctSku3= $G3
                   $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $AcctSku3 -DisabledPlans "FORMS_GOV_E3","POWERAPPS_O365_P2_GOV","FLOW_O365_P2_GOV","MCOSTANDARD_GOV"   

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

           
           }
           
           ## fill temp variable with user info
                    $temp=Get-MsolUser -UserPrincipalName $upn 
           ## creating custom properties based on the info in the $temp variable
                    $temp | select @{n="UserAccountThatRanTheScript";e={$userRunningthescript}},UserPrincipalName,islicensed,@{n="Licenses";e={$temp.licenses.AccountSkuId -join ","}},@{n="Time";e={get-date -Format MM:dd:yyyy:HH:mm:ss}} | Export-Csv $outFileName -Append -NoTypeInformation -Force
           

       }#foreach


       If user has *dot.nh.gov in their email address
        Add them to the DOT-EOLMB-RES-All-BookIn O365 Group

        Dot should have G3 with disabled apps and MFA enabled

