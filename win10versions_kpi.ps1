###########################################################################################
# Exports lists of computers with name and operating system version and e-mails the list. #
# Joni Ljungqvist, 2021-08-04.                                                            #
###########################################################################################

# Variables for date and file paths
$File1 = 'C:\Temp\Win_10_Laptop.csv'
$File2 = 'C:\Temp\Win_10_Desktop.csv'

# Find all laptops
Get-ADComputer -Filter * -SearchBase 'OU=Laptops' -Properties Name,OperatingSystemVersion,Description,LastLogonDate,whenCreated  | select Name,OperatingSystemVersion,Description,LastLogonDate,whenCreated  | Export-CSV -NoType -Encoding UTF8 -Path $File1

# Find all desktops
Get-ADComputer -Filter * -SearchBase 'OU=Desktops' -Properties Name,OperatingSystemVersion,Description,LastLogonDate  | select Name,OperatingSystemVersion,Description,LastLogonDate  | Export-CSV -NoType -Encoding UTF8 -Path $File2

#Send e-mail and attach files
$options = @{
    'SMTPServer' = "[redacted]" 
    'To' = "[redacted]" 
    'From' = "[redacted]" 
    'Subject' = "Windows 10 Versioner - KPI:er" 
    'Body' = "Hej,`n`nHär kommer de månatliga filerna med Windows 10-versioner för laptops och desktops." 
    'Attachments' = $file1, $file2  
}

Send-MailMessage @options -Encoding UTF8