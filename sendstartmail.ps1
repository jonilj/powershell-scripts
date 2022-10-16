#########################################################################################################################
# This script looks for newly created emails and sends the introduction e-mail. Joni Ljungqvist, 2021-12-03.            #
#########################################################################################################################

# Function to write events into log
Function Write-Log {
    Param(
        $Message,
        $Path = "D:\Logs\MailboxCreationLog.txt"
    )

    function TS {Get-Date -Format 'dd/MM/yyyy HH:mm:ss'}
    "[$(TS)] $Message" | Tee-Object -FilePath $Path -Append | Write-Verbose
}

# File path for Introduction-PDF
$pdf = 'D:\Docs\Introductionguide.pdf'

# Body for the email being sent
$Body = "[redacted]"

# Check if new mailboxes have been created and then send the e-mail to each user. If file does not exist, exit the script.
If (Test-Path D:\Logs\SendEmailTemp.txt) {
    # Import TXT-file
    $Users = Get-Content D:\Logs\SendEmailTemp.txt

    # Loop through each user to send them the e-mail and write it to the log
    ForEach ($User in $Users) 
    {
        $options = @{
        'To' = "$User"
        'From' = '[redacted]'
        'Subject' = "Välkommen!"
        'SMTPServer' = '[redacted]'
        'Body' = $Body
        'Attachments' = $pdf 
        }
    Send-MailMessage @options -Encoding UTF8 -BodyAsHtml
    Write-Log "Welcome e-mail sent to $User"
    }

    # Remove the TXT-file
    Remove-Item D:\Logs\SendEmailTemp.txt
} Else {
	Exit 
}