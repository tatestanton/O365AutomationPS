## place from where recursive search starts
#$landingPath="C:\Users\Tate Stanton\AppData\Roaming\Microsoft\MigrationTool\"
$landingPath="C:\span\TateTemp"

##getting all items into variable and filtering only failure
$allItems=Get-ChildItem -Path $landingPath -Recurse
$allFailures=$allItems | ? name -eq "ItemReport_R1.csv" | ? LastWriteTime -gt (get-date).AddHours(-72)

$consolidatedCSV=@()
$onlyFailures=@()
foreach ($Fail in $allFailures) {

$temp= Import-Csv $Fail.FullName
$consolidatedCSV+= $temp
$onlyFailures +=$temp | ? status -in ("failed","Skipped")

}

#$consolidatedCSV | Export-Csv '"C:\Users\Tate Stanton\AppData\Roaming\Microsoft\MigrationTool\allErrors.csv' -NoTypeInformation

##needed for sending emails
$credObject=Get-Credential

##load migration preparation file
$MigPreparationFilePath="C:\span\TateTemp\Migration-Prep-1.csv"
$MigPreparation=import-csv $MigPreparationFilePath -Delimiter ";"

##function for splitting emails (Legacy function)
function Create-Email () {
    $split=$row.destination.split("/")[4].split("_")
    $numberOfFields=($split | measure).count - 1
    $userPartInteger= $numberOfFields - 3

    #UserPart
    $emailTempUser= @()
    0..$userPartInteger | % {$emailTempUser+= $split[$_]}

    #DomainPart
    $emailTempdomain= @()
    $continue=$userPartInteger+1
    $continue..$numberOfFields | % {$emailTempdomain+= $split[$_]}

    $email= ($emailTempUser -join ".")+"@"+($emailTempdomain -join ".")
    $email

}

function Lookup-email ($row) {
    
    $string=@()
    $split=$row.Destination.split("/")
    2..4 | % {$string+= $split[$_]}
    
    $lookupValue="https://"+$($string -join "/")
    $email= $MigPreparation | ? OneDriveSiteLocation -eq $lookupValue
    $email.EmailAddress

}

## Adding Email column
foreach ($row in $onlyFailures){

    $email=Lookup-email $row
    
    $row |Add-Member -MemberType NoteProperty -Name Email -Value $email

}

$onlyFailures | Export-Csv '"C:\Users\Tate Stanton\AppData\Roaming\Microsoft\MigrationTool\OnlyFailures.csv' -NoTypeInformation

foreach ($row in $onlyFailures | group email) {

    
    $body=$row.Group | select source,message,status
    $recipient= $row.name




 
    ### Splatting with Hash Table
     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $hash = @{

    To = $recipient
    ##this might be replaced with the user logged on the begining of the script
    From = 'tate.stanton@hiveitservices.com'
    Subject = "OneDrive Error Report"
    SmtpServer = 'outlook.office365.com'
    Credential = $credObject
    Port = 587
 
    }
 
### Send Mail
$header = @"
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }

    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

    
    
   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }

        #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }
    



</style>
"@

$bodybody=@()
$bodybody +=@"
<img src="https://www.nh.gov/error2/NH-State-Seal.gif" height="100" width="100">
 
<p>Hello $firstname,</p>

<p>This is an automated message being sent by an authorized unattended account. <br><br>

Please do not reply to this email. </p>

<p>This message is to notify you your one drive migraiton resulted with some errors <br><br></p>
"@

$bodybody +=$body| ConvertTo-Html -Head $header
$bodybody +=@"
<p>Please, review the following document for help in managing this requirement. <a href ="https://www.app-support.nh.gov/vpn-guide/documents/vpn-owa-password-mangement.pdf">Password Mangement Instructions</a></p>

<p>If you are unable to successfully resolve migration errors, please, contact the DoIT Central Help Desk by e-mail <a href="mailto:helpdesk@doit.nh.gov">helpdesk@doit.nh.gov</a>
or phone 603-271-7555 (call wait times may be significant due to high volume).</p>

<p> You will continue to receive these email reminders until errors are resolved

<br>

<p>Thank you,</p>

<p>Department of Information Technology <br>
State of New Hampshire <br>
603-271-7555 <br>
<br>
Statement of Confidentiality:  The contents of this message are confidential.  Any unauthorized disclosure, reproduction, use or dissemination (either whole or in part) is prohibited.  If you are not the intended recipient of this message, please notify the sender immediately and delete the message from your system.<br>
</p>

"@

Send-MailMessage @hash -UseSsl  -Body $body
}
