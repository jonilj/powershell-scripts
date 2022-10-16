###############################################################################################################################
# Script is run on disabled accounts and automatically deletes those where the "whenChanged" attribute it older than 90 days. #
# Partly compiled, partly written by Joni Ljungqvist, EUC, 2021-10-20.                                                        # 
###############################################################################################################################

# Function to write deletions to log
Function Write-Log {
    Param(
        $Message,
        $Path = "$env:C:\Tools\Deletedusers\RemovedUsersLog.txt"
    )

    function TS {Get-Date -Format 'dd/MM/yyyy HH:mm:ss'}
    "[$(TS)] $Message" | Tee-Object -FilePath $Path -Append | Write-Verbose
}

# Specify what OU the script should look in.
$OUToSearch = "OU=Test_for_script,OU=Users,OU=.SE,DC=se,DC=novamedia,DC=com"

# Find disabled user accounts in the Disabled Accounts-OU and check whether they have a "whenChanged" attribute older than 60 days
$EUsers = Get-ADUser -Filter 'Enabled -eq $False' -Searchbase $OUToSearch -Properties whenChanged | Where-Object {$_.whenChanged -lt (Get-Date).adddays(-60)}

# Go through each user who's account will be removed and send the e-mail.
ForEach($EUser in $EUsers)
{
    # Get the manager of the user who's account will expire.
    $Manager = Get-ADUser -Identity $EUser -properties * | Select -ExpandProperty Manager
     
    # Checks if there is a manager assigned to the account. If there isn't, assigns SPL EUC e-mail instead.
    if ($Manager) { 
        $ManagerEmail = Get-ADUser $Manager -properties * | Select EmailAddress 
        $ManagerEmail = $ManagerEmail -replace ".*=" -replace "}.*"
    } else  {
        $ManagerEmail = 'spl_euc@postkodlotteriet.se'
    }

    # Get the users name. These variables will be used in the e-mail.
    $Userobj = $EUser | Get-ADUser -Server pradse001.se.novamedia.com -Properties Name

    # Below is the actual e-mail and information used to send the e-mail.
    $options = @{
        'To' = $ManagerEmail
        'From' = 'no-reply@postkodlotteriet.se'
        'Subject' = "$($Userobj.Name)'s konto kommer att raderas om 30 dagar."
        'SMTPServer' = 'exchange.bss.bssp-aws.se.novamedia.com'
        'Body' = "Hej,`n`n$($Userobj.Name)'s konto har nu varit nedstängt och inaktivt i 60 dagar och kommer att raderas helt om 30 dagar. Efter att kontot raderats kan det återställas i upp till 90 dagar, därefter är det borta.`n`nNotera att mailkorg och OneDrive dock finns kvar som backup i upp till sju år.`n`nVänligen kontakta EUC om kontot behöver sparas längre.  `n`nVänliga hälsningar,`nEUC Teamet"
    }
    Send-MailMessage @options -Encoding UTF8
}

# Find disabled user accounts in the Disabled Accounts-OU and check whether they have a "whenChanged" attribute older than 90 days
$DelUser = Get-ADUser -Filter 'Enabled -eq $False' -Searchbase $OUToSearch -Properties whenChanged | Where-Object {$_.whenChanged -lt (Get-Date).adddays(-90)}

# Remove the selected accounts and write it to the log.
ForEach($DelUser in $DelUsers) 
{
    $LogName = $DelUser.Name
    Remove-ADUser -Identity $DelUser -Confirm:$False
    Write-Log "$LogName's account was older than 90 days and was deleted"
}