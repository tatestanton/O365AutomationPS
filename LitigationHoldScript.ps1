[string]$userName = ''
[string]$userPassword = '' 
$CsvPath= "C:\temp\Users.csv"

#########################
## it is important that first column in the CSV is called UPN and delimiter is ;
######################
$users= import-csv $CsvPath -Delimiter ";"
$litUsers=@()
$noLitUsers=@()

# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Import-PSSession ( New-PSSession -ConfigurationName Microsoft.Exchange  `
        -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credObject -Authentication Basic -AllowRedirection)


function Get-LitReport {

    foreach ($user in $users) {
        if (-not(
        $temp= Get-Mailbox $user.upn -EA ignore))  {Write-Error "User $($user.upn) Not found"}

        if ($temp.LitigationHoldEnabled -eq "true") {
            
            $litUsers+=$temp
        
        } else {
        
            $noLitUsers+=$temp
        }
        $temp=$null

    
    }

    $litUsers | select PrimarySmtpAddress,LitigationHoldEnabled,LitigationHoldDuration | Export-Csv .\LitUsers.csv -NoTypeInformation -Force
    $noLitUsers | select PrimarySmtpAddress,LitigationHoldEnabled | export-csv .\noLitUsers.csv -NoTypeInformation -Force

}


function Set-Lit ($upn){
    $key= $upn.Split("@")[1].split(".")[0]
    
    if ($key -in ("doc","dot")) {
    
        Set-Mailbox $upn -LitigationHoldEnabled $true -LitigationHoldDuration 730
        
    }

}

foreach ($user in $users) {

    set-lit $user.upn

}

Get-LitReport