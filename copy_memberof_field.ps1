<#
.Synopsis
    This script prompts for user input to copy memberof field from one user to the other. Usually employed when a new accounts needs to be setup.
 
.NOTES   
    Name: copy_memberof_field
    Author: Joni Ljungqvist
    Version: 1.0    
    DateCreated: 2022-Oct-06
 
.LINK 
    N/A
#>

# Import Active Directory-module
Import-Module activedirectory

# Function that prompts user for user name input and searches for a match in AD.
Function PromptForUser
{
    Try {
            [string]$userToFind = Read-Host "Input user name (6 or 8 characters)"
    }
    Catch {
            $userToFind = $null
    }

    If (([ADSISearcher] "(sAMAccountName=$userToFind)").FindOne()) {
        $promptedUser = Get-ADUser -Identity $userToFind -Properties *
    }
    Else {
        Write-Error "$userToFind - User not found"
        PromptForUser
    }
    return $promptedUser
}

# Function that simply adds green font color to Write-Output when piped to "Green".
Function Green 
{
    Process { Write-Host $_ -ForegroundColor Green }
}

# Prompt for user input to find user to copy groups from
Write-Output "Input user to copy memberOf FROM." | Green
$userToBeCopied = PromptForUser

# Prompt for user input to find user to copy groups to
Write-Output "Input user to copy memberOf TO." | Green
$userTarget = PromptForUser

# Set name variables for warning
$displayFrom = $userToBeCopied.Name
$displayTo = $userTarget.Name

# Prompt user to verify the correct users have been selected
Write-Warning "You will now copy all memberOf groups FROM $displayFrom TO $displayTo. Proceed?" -WarningAction Inquire

# If yes, try to copy the groups and confirm
    Try {
            Get-ADUser -Identity $userToBeCopied.sAMAccountName -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $userTarget.sAMAccountName
            Write-Output "memberOf groups copied FROM $displayFrom TO $displayTo." | Green
    }
    Catch {
            Write-Error "An error occurred."
    }