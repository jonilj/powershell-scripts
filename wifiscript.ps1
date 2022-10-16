$profiles = (netsh wlan show profiles name=*) -match '\s{2,}:\s'
$computername = hostname
$fileName = $computername + "_WLAN_" + $((Get-Date).ToString('MM-dd-yyyy'))

foreach ($line in $profiles) {
    $values = $line -split ":"
    $key = $values[0].trim()
    $value = $values[1].trim()
    if ($key -eq "name") {
        $currentProfile = $value
    }
    if ($key -eq "Authentication")  {
    $value | Out-File "C:\Temp\$fileName.txt" -Append
   }
}

# Create temp-path if it doesn't exist
if(-Not (Test-Path -path C:\Temp)) {
    New-Item "C:\Temp" -ItemType "directory"
}

# Send e-mail and attach files
$options = @{
    'SMTPServer' = "[redacted]" 
    'To' = "[redacted]" 
    'From' = "[redacted]" 
    'Subject' = "$computername - Wifi" 
    'Body' = "Hej,`n`nHär kommer en fil från $computername med dess wifi." 
    'Attachments' = "C:\Temp\$fileName.txt"  
}

Send-MailMessage @options -Encoding UTF8

# Remove the text file
Remove-Item -Path "C:\Temp\$fileName.txt"