#########################################################################################################################
# This script looks for accounts that do not have a mailbox enabled, and creates it for them.                           #
# The script was written by Bastiaan Arkesteijn, and modified by Joni Ljungqvist to automate the process.               #
#########################################################################################################################

## Add Exchange Management Shell for Exchange commands to work
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

## Functions to write events into log
Function Write-Log {
    Param(
        $Message,
        $Path = "D:\Logs\MailboxCreationLog.txt"
    )

    function TS {Get-Date -Format 'dd/MM/yyyy HH:mm:ss'}
    "[$(TS)] $Message" | Tee-Object -FilePath $Path -Append | Write-Verbose
}

Function Write-User {
    Param(
        $Message,
        $Path = "D:\Logs\SendEmailTemp.txt"
    )

    "$Message" | Tee-Object -FilePath $Path -Append | Write-Verbose
}

## Leave these variables intact unless they change or you want to use a different Domain Controller
$TargetDomain = "targetdomain"
$TargetDomain2 = "targetdomain2"
$DomainController = "domaincontroller"

## Get the users who do not have a prodxyaddress and are members of any of the 365-groups
$Users = Get-ADUser -Server $DomainController -Filter 'proxyaddresses -NotLike "*[redacted]*"' -Properties MemberOf | Where {$_.MemberOf -Like '*365memberGroup*'}

# Loop through each user and create their mailbox
foreach($User in $Users)
{
    ## Get users sAMAccountName
    $sAMAccountName = Get-ADUser -Identity $User -properties * | Select -Property sAMAccountName
    $sAMAccountName = $sAMAccountName.sAMAccountName

    ## Leave line for other script
    Write-User "$sAMAccountName@postkodlotteriet.se"

    ## Log the events and create users mailbox
    Write-Log "Starting to process $sAMAccountName"
    Get-User -Identity $sAMAccountName | Enable-RemoteMailbox -Alias $sAMAccountName  -RemoteRoutingAddress "$sAMAccountName$targetdomain" -DomainController $DomainController
    Write-Log "$sAMAccountName has been enabled with the correct mailbox properties"
    $secondAlias = "$sAMAccountName$TargetDomain2"
    Set-remotemailbox $sAMAccountName -EmailAddresses @{add=$secondAlias} -DomainController $DomainController
    Write-Log "$sAMAccountName has been provisioned with all the Office 365 aliases."
    Write-Log "$sAMAccountName has been Enabled with an Office 365 mailbox."
}