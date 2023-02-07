#############################################################################################################
# This script will look for accounts that expire within 30 days and e-mail a notification to their manager. #
# Partly compiled, partly written by Joni Ljungqvist, 2021-03-12.                                           #
#############################################################################################################

## Check for users who' account will expire within 30 days.
$Users = Search-ADAccount -UsersOnly -AccountExpiring -TimeSpan 31:0:0:0.0

## Go through each user who's account will expire.
foreach($User in $Users)
{
    ## Get the manager of the user who's account will expire.
    $Manager = Get-ADUser -Identity $User -properties * | Select -ExpandProperty Manager
     
    ## Checks if there is a manager assigned to the account. If there isn't, assigns SPL EUC e-mail instead.
    ## Line 19 will trim the string to only include the e-mail address.
    if ($Manager) { 
        $ManagerEmail = Get-ADUser $Manager -properties * | Select EmailAddress 
        $ManagerEmail = $ManagerEmail -replace ".*=" -replace "}.*"
    } else  {
        $ManagerEmail = '[redacted]'
    }


    ## Get the users properties and expiry date. These variables will be used in the e-mail.
    $Userobj = $User | Get-ADUser -Server [AD-server] -Properties Name,AccountExpirationDate
    $ExpiryDate = $($Userobj.AccountExpirationDate.tostring(“dd/MM/yyyy”))


    ## Below is the actual e-mail and information used to send the e-mail.
    $options = @{
        'To' = $ManagerEmail
        'From' = '[redacted]'
        'Subject' = "$($Userobj.Name)'s account will expire $ExpiryDate"
        'SMTPServer' = '[redacted]'
        'Body' = "[redacted]"
    }
    Send-MailMessage @options -Encoding UTF8
}
