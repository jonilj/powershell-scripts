<#
.Synopsis
    This script resets the passwords for all of our TM-partner agents. It's intended to be run as a scheduled task every 60 days.
 
.NOTES   
    Name: reset_TMpartner_passwords
    Author: Joni Ljungqvist
    Version: 1.0
    DateCreated: 2022-Apr-13
 
.LINK 
    N/A
#>

## Import Active Directory-module
Import-Module activedirectory

## Function created by theSysadminChannel to generate random passwords
Function New-RandomPassword { 
<#
.Synopsis
    This will generate a new password in Powershell using Special, Uppercase, Lowercase and Numbers.  The max number of characters are currently set to 79.
    For updated help and examples refer to -Online version.
 
.NOTES   
    Name: New-RandomPassword
    Author: theSysadminChannel
    Version: 1.0
    DateCreated: 2019-Feb-23
 
.LINK 
    https://thesysadminchannel.com/generate-strong-random-passwords-using-powershell/ -
 
 
.EXAMPLE
    For updated help and examples refer to -Online version.
 
#>
 
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $false
        )]
        [ValidateRange(5,79)]
        [int]    $Length = 10,
 
        [switch] $ExcludeSpecialCharacters
 
    )
 
 
    BEGIN {
        $SpecialCharacters = @((33,35) + (36..38) + (42..44) + (63) + (91..93))
    }
 
    PROCESS {
        try {
            if (-not $ExcludeSpecialCharacters) {
                    $Password = -join ((48..57) + (65..90) + (97..122) + $SpecialCharacters | Get-Random -Count $Length | foreach {[char]$_})
                } else {
                    $Password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count $Length | foreach {[char]$_})
            }
 
        } catch {
            Write-Error $_.Exception.Message
        }
 
    }
 
    END {
        return $password
    }
 
}

<#####################################################################################################
# Script starts below this line.                                                                     #
#####################################################################################################>

## Define what OUs to iterate through
$OUs = "OU=TMPartner0","OU=TMPartner1","OU=TMPartner2","OU=TMPartner3","OU=TMPartner4","OU=TMPartner5"

## Loop through each row containing user details in the CSV-file 
foreach ($OU in $OUs)
{
    ## Find each user in the OU
    $users = Get-ADUser -Filter * -SearchBase $OU

    ## Sets the name of each CSV-file and subject
    $OU_name = $OU.split(',')[0]
    $nameCSV = $OU_name.substring(3) + "_Passwords_" + $((Get-Date).ToString('MM-dd-yyyy'))

    ## Iterate through each user in the OU, reset their password and write the information to a CSV-file
    foreach($user in $users) {
        $password = New-RandomPassword

        Set-ADAccountPassword -Identity $user -NewPassword (convertto-securestring $password -AsPlainText -Force) -Reset

        ## Export the data to a CSV-file
        [PSCustomObject]@{
        Firstname = $user.GivenName;
        Lastname  = $user.Surname;
        Username  = $user.SamAccountName
        Password  = $password;
        } | Export-CSV -NoType -Encoding UTF8 -Delimiter ';' -Append -Path "C:\Temp\$nameCSV.csv"
    }

    ## Set the correct recipient and subject
    if($nameCSV -like "*TMPartner0*") {
        $recipients = '[redacted]'
        $subject = "New password for TMPartner0"
    }
    elseif($nameCSV -like "*TmPartner1*") {
        $recipients = '[redacted]'
        $subject = "New password for TMPartner1"
    }
    elseif($nameCSV -like "*TMPartner2*") {
        $recipients = '[redacted]'
        $subject = "New password for TMPartner2"
    }
    elseif($nameCSV -like "*TMPartner3*") {
        $recipients =  '[redacted]'
        $subject = "New password for TMPartner3"
    }
    elseif($nameCSV -like "*TMPartner4*") {
        $recipients = '[redacted]'
        $subject = "New password for TMPartner4"
    }
    elseif($nameCSV -like "*TMPartner5*") {
        $recipients = '[redacted]'
        $subject = "New password for TMPartner5"
    }

    ## Send e-mail with the information
    $options = @{
    'SMTPServer' = "[redacted]" 
    'To' = $recipients
    'From' = '[redacted]' 
    'Subject' = $subject
    'Body' = "[redacted]"
    'Attachments' = "C:\Temp\$nameCSV.csv"
    }
    Send-MailMessage @options -Encoding UTF8
}