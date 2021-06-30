while ($true){

        [string]$userName = ''
        [string]$userPassword = '' 

        # Convert to SecureString
        [securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
        [pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

        Connect-MsolService -Credential $credObject
        Import-PSSession ( New-PSSession -ConfigurationName Microsoft.Exchange  `
                -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credObject -Authentication Basic -AllowRedirection)
        #import users CSV needs to be in format 'Userprincipalname;UsageLocation
        $users= import-csv C:\temp\Users.csv -Delimiter ";"

        ## this has to be modified
        $AcctSku= (Get-MsolAccountSku |? AccountSkuId -like "*enterprisepack*")

        ## here you can exclude some services, this is just a reference object (has no impact)
        ##   POWER_VIRTUAL_AGENTS_O365_P2,CDS_O365_P2,PROJECT_O365_P2,DYN365_CDS_O365_P2,MICROSOFTBOOKINGS,KAIZALA_O365_P3,MICROSOFT_SEARCH,WHITEBOARD_PLAN2,MIP_S_CLP1,MYANALYTICS_P2
        ##   BPOS_S_TODO_2,FORMS_PLAN_E3,STREAM_O365_E3,Deskless,FLOW_O365_P2,POWERAPPS_O365_P2,TEAMS1,PROJECTWORKMANAGEMENT,SWAY,INTUNE_O365,YAMMER_ENTERPRISE,RMS_S_ENTERPRISE
        ##   OFFICESUBSCRIPTION,MCOSTANDARD,SHAREPOINTWAC,SHAREPOINTENTERPRISE,EXCHANGE_S_ENTERPRISE

        $MyServicePlans = New-MsolLicenseOptions -AccountSkuId $($AcctSku.AccountSkuId) -DisabledPlans YAMMER_ENTERPRISE,POWERAPPS_O365_P2
        $EXOMyServicePlans = New-MsolLicenseOptions -AccountSkuId $($AcctSku.AccountSkuId) -DisabledPlans YAMMER_ENTERPRISE,POWERAPPS_O365_P2,EXCHANGE_S_ENTERPRISE
            foreach ($entry in $users) {

                 $exoUser=  Get-Recipient $entry.UserPrincipalName
                $user= Get-MsolUser -UserPrincipalName $entry.UserPrincipalName
                $user | Set-MsolUser -UsageLocation $entry.UsageLocation

                $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
                $st.RelyingParty = "*"
                $st.State = "Enforced"
                $sta = @($st)


                $user | Set-MsolUser -StrongAuthenticationRequirements $sta



                    ##Adding license if user has not been assigne e3 license
                    if ($user.licenses.AccountSkuId -notlike "*enterprisepack*")  {
    
                            ##IF no ExchangeGuid assign E3 without YAMMER_ENTERPRISE,POWERAPPS_O365_P2
                          if ($exoUser.ExchangeGuid -eq $null) {
                                
                                 $user|  Set-MsolUserLicense  -AddLicenses $AcctSku.AccountSkuId -LicenseOptions $MyServicePlans

                            } else { ## else - assign E3 without EXCHANGE_S_ENTERPRISE,YAMMER_ENTERPRISE,POWERAPPS_O365_P2
                            
                                $user|  Set-MsolUserLicense  -AddLicenses $AcctSku.AccountSkuId -LicenseOptions $EXOMyServicePlans
                            
                             }



                    
                }

       
            }
             Start-Sleep -Seconds 1800

}


