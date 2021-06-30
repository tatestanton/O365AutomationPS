Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Get-PSSession | Remove-PSSession

function LoginScreen{

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter the credentials:'
$form.Controls.Add($label)

$txtB_user = New-Object System.Windows.Forms.TextBox
$txtB_user.Location = New-Object System.Drawing.Point(10,40)
$txtB_user.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($txtB_user)

$txtB_pwd = New-Object System.Windows.Forms.MaskedTextBox
$txtB_pwd.Location = New-Object System.Drawing.Point(10,70)
$txtB_pwd.Size = New-Object System.Drawing.Size(260,20)
$txtB_pwd.PasswordChar = '*'
$form.Controls.Add($txtB_pwd)

$form.Topmost = $true
$form.ShowDialog()

[securestring]$secStringPassword = ConvertTo-SecureString $txtB_pwd.text -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($txtB_user.Text, $secStringPassword)

Import-PSSession ( New-PSSession -ConfigurationName Microsoft.Exchange  `
        -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credObject -Authentication Basic -AllowRedirection)
}



function Menu {

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)


$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)

$listBox.SelectionMode = 'MultiExtended'

[void] $listBox.Items.Add('Create Shared Mailbox')
[void] $listBox.Items.Add('Add permissions to Shared Mailbox')

$listBox.Height = 70
$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItems
    return $x
}

}

function create_shared_mailbox {

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter emailAddress:'
$form.Controls.Add($label)

$txtB_email = New-Object System.Windows.Forms.TextBox
$txtB_email.Location = New-Object System.Drawing.Point(10,40)
$txtB_email.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($txtB_email)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,60)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter DisplayName:'
$form.Controls.Add($label)

$txtB_DisplayName = New-Object System.Windows.Forms.TextBox
$txtB_DisplayName.Location = New-Object System.Drawing.Point(10,80)
$txtB_DisplayName.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($txtB_DisplayName)

$form.ShowDialog()


New-Mailbox -DisplayName $txtB_DisplayName.Text -name $txtB_DisplayName.Text -Password (ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force) -Shared:$true

}

LoginScreen

$result= menu

switch ($result)
{
    'Create Shared Mailbox' {create_shared_mailbox}
    #'SomethingElse' {}
    #'SomethingElse' {}
}