##turn on litigation hold on mailboxes containing 'dot' or 'doc' in UPN which are provisioned in the last 24 hours and dont have lit hold enabled
##export csv 
##    1) master csv
##    2) each run csv
##
###############################################################

$RootLocation= "C:\CSV"
##creating  log file
$date=Get-Date -Format dd-MM-yy
$hour= get-date -Format HH:mm
$log= New-Item $RootLocation\LitHoldEnabled-$date-log.txt -Force

##Creating MasterLogFile
if (-not(Test-Path "C:\CSV\LitHoldEnabledMaster.txt")) {

    New-Item "C:\CSV\LitHoldEnabledMaster.txt" -Force
}


function Fill-Log ($message) {


    $hour + " "+ $message | Out-file $log.FullName -Append



}


##Function that gets all 'dot' or 'doc' mailboxes provisioned in last X days with LitHold disabled
function fresh_lithold_disabled {
    
    $return=@()
    $date=(get-date).AddDays(-4)
    $mbx= Get-Mailbox  -Filter 'LitigationHoldEnabled -eq "False"' | ? whenmailboxcreated -gt $date

    foreach ($mailbox in $mbx){

        $key= $mailbox.UserPrincipalName.Split("@")[1].split(".")[0]
       
        if ($key -in ("doc","dot","ucka365")) {
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