$RootLocation= "C:\CSV"
[string]$userName = ''
[string]$userPassword = '' 
##creating  log file
$date=Get-Date -Format MM-dd-yy
$hour= get-date -Format HH:mm
$log= New-Item $RootLocation\LitHoldEnabled-$date-log.txt -Force


# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

##Creating MasterLogFile
if (-not(Test-Path "C:\CSV\LitHoldEnabledMaster.txt")) {

    New-Item "C:\CSV\LitHoldEnabledMaster.txt" -Force
}


Import-PSSession ( New-PSSession -ConfigurationName Microsoft.Exchange  `
        -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credObject -Authentication Basic -AllowRedirection)


function Fill-Log ($message) {


    $hour + " "+ $message | Out-file $log.FullName -Append



}



##Function that gets all 'dot' or 'doc' mailboxes provisioned in last X days with LitHold disabled
function fresh_lithold_disabled {
    
    $return=@()
    ## set number of hours  
    $date=(get-date).AddHours(-36)
    $mbx= Get-Mailbox  -Filter 'LitigationHoldEnabled -eq "False"' | ? whenmailboxcreated -gt $date

    foreach ($mailbox in $mbx){

        $key= $mailbox.UserPrincipalName.Split("@")[1].split(".")[0]
       
        if ($key -in ("doc","dot")) {
            $return+=$mailbox
        }
    }
    return $return
}

function check_lit ($mailboxes){

    foreach ($mbx in $mailboxes){
    
        $status=(Get-Mailbox $mbx.UserPrincipalName).LitigationHoldEnabled

        if ($status -eq "True") {
    
            Fill-Log "LitigationHold successfuly enabled on $($mbx.UserPrincipalName)"
        } else {
        
            Fill-Log "LitigationHold failed to enable on $($mbx.UserPrincipalName)"
        }

    
    }
    
}

$targetUsers=fresh_lithold_disabled
$targetUsers | % {Set-Mailbox $_.UserPrincipalName -LitigationHoldEnabled $true -LitigationHoldDuration 730 | Out-Null}
check_lit $targetUsers

$date | Out-File "C:\CSV\LitHoldEnabledMaster.txt" -Append
Get-Content $log | Out-File "C:\CSV\LitHoldEnabledMaster.txt" -Append


### add smtp functionality

$subject = $('LitHold report for '+$date)
[string]$body = (Get-Content $log)

 
### Splatting with Hash Table
 [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$hash = @{
 

 ## "To" address needs to be modified
To = 'dvelovic@hiveitservices.com'
## from address needs to be mailbox which is logged in powershell session
From = 'tate.stanton@hiveitservices.com'
Subject = "Test Lit Hold"
SmtpServer = 'outlook.office365.com'
Credential = $credObject
Port = 587
 
}
 
### Send Mail
 
Send-MailMessage @hash -UseSsl  -Body "Test Test"
