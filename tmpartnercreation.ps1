<#
.Synopsis
    This script creates (or re-enables) TM-partner user accounts from a csv-file with the firstName,lastName headers. 
    Run the script, find the .csv-file using the browser and then choose the correct TM-parter.
 
.NOTES   
    Name: TMPartnerCreation
    Author: Joni Ljungqvist
    Version: 1.0
    DateCreated: 2022-Mar-11

#>

# Import Active Directory-module
Import-Module activedirectory

<#####################################################################################################
# Functions are declared below this line.                                                            #
#####################################################################################################>

## Function to prompt user for the CSV-file location
Function Get-FileName
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}

## Function to set the username
Function Create-Username
{
    ## Variables to use when matching $_.Name
    $checkFirst = $firstName
    $checkSecond = $lastname

    ## Replace any non-english characters
    $firstName = $firstName -replace 'Ö|ö','o' -replace 'Å|å|Ä|ä','a' -replace 'É|é','e' -replace 'Û|ü','u'
	$lastName = $lastName -replace 'Ö|ö','o' -replace 'Å|å|Ä|ä','a' -replace 'É|é','e' -replace 'Û|ü','u'

    ## Then, we run the code below to create a username from the first three characters of the firstname and lastname
    $usernamePartOne = $firstName.Substring(0, [Math]::Min($FirstName.Length, 3))
    $usernamePartTwo = $lastName.Substring(0, [Math]::Min($LastName.Length, 3))
    $username = "setm$usernamePartOne$usernamePartTwo"

    ## The section below will test several conditions to make sure a username is generated that is not already taken
    $nameCollision = Get-ADUser -Filter {SamAccountName -eq $username}
    $disabledAccount = Get-ADUser -Filter {SamAccountName -eq $username} -SearchBase "$OU" | Where {"$checkFirst $checkSecond" -eq $_.Name}
    $accountExists = Get-ADUser -Filter {SamAccountName -eq $username} -SearchBase "$OU" | Where {"$checkFirst $checkSecond" -eq $_.Name}

    ## Start testing conditions to get a username that is not in use
    if ($nameCollision -eq $null) {
        $username = $username
    }
    elseif (($disabledAccount -ne $null) -or ($accountExists -ne $null)) {
        $username = $username
    }
    else {
        $usernamePartOne = $firstName.Substring(0, [Math]::Min($FirstName.Length, 2))
        $usernamePartTwo = $lastName.Substring(0, [Math]::Min($LastName.Length, 4))
        $username = "$usernamePartOne$usernamePartTwo"
    }
    return $username.ToLower()
}

## Function needed to correct the name since it there's a mismatch with OUs in AD
Function Correct-TMPartnerName
{
    if ($tmPartner -eq "TMPartner1") {
    $tmPartnerName = 'TMPartner1'
    } elseif ($tmPartner -eq "TMPartner2") {
    $tmPartnerName = 'TMPartner2'
    } else {
    $tmPartnerName = $tmPartner
    }
    return $tmPartnerName
}

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

## Call function Get-FileName to prompt for location of CSV-file and store it in the variable ADUsers
$path = Get-FileName

## Import CSV
$ADUsers = Import-CSV -Path $path -encoding UTF7

## Verify that a valid path was provided, if it wasn't exit the script
if (($ADUsers.firstName -eq $null) -or ($ADUsers.lastName -eq $null)) {
    Write-Error "No valid file found."
    Exit 1
}

## Set value of tmPartner to null
$tmPartner = $null

## Prompt for TM-partner choice
do {
$choice = Read-Host "1. TMPartner1
2. TMPartner2
3. TMPartner3
4. TMPartner4
5. TMPartner5

Please choose TM-partner"

	Switch ($choice)
	    {
		1 {$tmPartner="TMPartner1"}
		2 {$tmPartner="TMPartner2"}
		3 {$tmPartner="TMPartner3"}
		4 {$tmPartner="TMPartner4"}
		5 {$tmPartner="TMPartner5"}
	    }
    } while ($tmPartner -notmatch "TMPartner1|TMPartner2|TMPartner3|TMPartner4|TMPartner5")

## Set OU
$OU = "$OU"

## Set correct AD-group depending on TM-partner as naming standards in AD differ
$tmPartnerName = Correct-TMPartnerName

## Set which AD-group to add
$groupToAdd = "$tmPartnerName.agent"

## Set parameters for name of CSV-file
$nameCSV = $tmPartnerName + "_" + $((Get-Date).ToString('MM-dd-yyyy'))

<#####################################################################################################
# Section below creates the users.                                                                   #
#####################################################################################################>

Write-Output "Creating users..."

## Loop through each row containing user details in the CSV-file 
foreach ($User in $ADUsers)
{
	## Read user data from each field in each row and assign the data to a variable as below
	$firstName = $User.firstName
	$lastName = $User.lastName

    ## Call function New-RandomPassword to generate the password for the user
    $password = New-RandomPassword

    ## Call function Create-Username function to generate the username
    $username = Create-Username  

    ## Test if the account already exists as a disabled account
    $disabledAccount = Get-ADUser -Filter {SamAccountName -eq $username} -SearchBase "$OU" | Where {"$firstName $lastName" -eq $_.Name}
    $accountExists = Get-ADUser -Filter {SamAccountName -eq $username} -SearchBase "$OU" | Where {"$firstName $lastName" -eq $_.Name}

    ## Start testing conditions to get a username that is not in use
    if (($disabledAccount -eq $null) -and ($accountExists -eq $null)) {
            ## Create the user with the specified attributes
            New-ADUser `
                -SamAccountName $username `
                -UserPrincipalName "$username@domain" `
                -Name "$firstName $lastName" `
                -GivenName $firstName `
                -Surname $lastName `
                -Enabled $True `
                -DisplayName "$firstName $lastName" `
                -Description "$tmPartnerName" `
                -Path $OU `
                -AccountPassword (convertto-securestring $password -AsPlainText -Force) -ChangePasswordAtLogon $False
    }
    elseif ($disabledAccount -ne $null) {
            ## If username exists as a disabled user, enable and move the account to the correct OU and reset password
            Get-ADUser -Identity $username | Move-ADObject -TargetPath $OU
            Set-ADAccountPassword -Identity $username -NewPassword (convertto-securestring $password -AsPlainText -Force) -Reset
            Enable-ADAccount -Identity $username
    }
    elseif ($accountExists -ne $null) {
            ## If username exists in the OU already, set a new password
            Set-ADAccountPassword -Identity $username -NewPassword (convertto-securestring $password -AsPlainText -Force) -Reset
    }
    else {
            $username = "Unable to create user"
    }

    ## Add the AD-group to created user
    Add-ADGroupMember -Identity $groupToAdd -Members $username

    ## Export the data to a CSV-file
    [PSCustomObject]@{
    Firstname = $firstName; 
    Lastname  = $lastName;
    Username  = $username;
    Password  = $password;
    } | Export-CSV -NoType -Encoding UTF8 -Delimiter ';' -Append -Path "C:\Temp\$nameCSV.csv"
}

Write-Output "Users created (or updated). File created as C:\Temp\$nameCSV."

Read-Host -Prompt "Press Enter to exit"
