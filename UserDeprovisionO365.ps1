$RootLocation= "C:\Temp"
##creating log file
$date=Get-Date -Format dd-MM-yy
$hour= get-date -Format HH:mm
$log= New-Item $RootLocation\UserDeprovisoin-$date-log.txt -Force


#import users CSV needs to be in format 'Userprincipalname;UsageLocation
$users= import-csv C:\temp\o365Users.csv -Delimiter ";"


##Function that enters text to log file
function Fill-Log ($message) {


    $hour + " "+ $message | Out-file $log.FullName -Append



}

function Remove-o365License ($UPN) {


    $temp=Get-MsolUser -UserPrincipalName $UPN
    if ($temp -ne $null) {
    
        Set-MsolUserLicense -ObjectId $temp.ObjectId -RemoveLicenses $temp.Licenses.accountskuid

        $licenses=$temp.Licenses.accountsku.SkuPartNumber -join ","

        Fill-Log "Licenses $licenses for $upn have been removed"
    
    } else {
    
        Fill-Log "Get operatoin failed for user $Upn"
        
    }
    

}

function Block-SignIn ($UPN) {


        $temp=Get-MsolUser -UserPrincipalName $UPN
        if ($temp -ne $null) {
    
         Set-MsolUser -ObjectId $temp.ObjectId -BlockCredential:$true
         Fill-Log "$UPN has BlockSighIn set to Yes"
        } else {
    
        Fill-Log "Get operatoin failed for user $Upn"
        
        }

}

foreach ($user in $users) {

    Remove-o365License $user.UserPrincipalName
    Block-SignIn $user.UserPrincipalName


}

