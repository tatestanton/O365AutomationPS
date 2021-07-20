Connect-MsolService



$RootLocation= "C:\CSV\"
##Log file creation
$date=Get-Date -Format MM-dd-yy-HH-mm
$hour= get-date -Format MM-dd-yy-HH-mm 
$log= New-Item $RootLocation\UserDeprovision-$date-log.txt -Force


#import users CSV needs to be in the format 'Userprincipalname;UsageLocation
$users= import-csv C:\csv\O365Deprovision.csv -Delimiter ";"


##Function that enters text to log file
function Fill-Log ($message) {


    $hour + " "+ $message | Out-file $log.FullName -Append



}

function Remove-o365License ($UPN) {

    
    $temp=Get-MsolUser -UserPrincipalName $UPN
    if ($temp -ne $null) {
    
        Set-MsolUserLicense -ObjectId $temp.ObjectId -RemoveLicenses $temp.Licenses.accountskuid

        $licenses=$temp.Licenses.accountsku.SkuPartNumber -join ","

        Fill-Log "License $licenses for $upn have been removed"
    
    } else {
    
        Fill-Log "The operation failed for user $Upn"
        
    }
    

}

function Block-SignIn ($UPN) {


        $temp=Get-MsolUser -UserPrincipalName $UPN
        if ($temp -ne $null) {
    
         Set-MsolUser -ObjectId $temp.ObjectId -BlockCredential:$true
         Fill-Log "$UPN has Blocked Signin set to Yes"
        } else {
    
        Fill-Log "Get operation failed for user $Upn"
        
        }

}

foreach ($user in $users) {

    Remove-o365License $user.UserPrincipalName
    Block-SignIn $user.UserPrincipalName


}
