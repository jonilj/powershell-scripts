################################################################
# This is a simple script that will clear out the Teams cache. #
# Written by Joni Ljungqvist, 2021-11-18.                      #
################################################################

# This line is needed in order to use the presentation framework that will display the user input box.
Add-Type -AssemblyName PresentationFramework

# Ask for user input before proceeding. 
$MSGBoxInput = [System.Windows.MessageBox]::Show('Teams och Outlook kommer nu startas om. Tryck OK för att fortsätta, eller avbryt.','Fortsätt rensa cachen?','OKCancel','Info')

# Determine what to do based on user input.
Switch  ($MSGBoxInput) {
    'Yes' {
             Write-Host "User clicked OK, continuing."
             Continue
          }
    'Cancel' {
             Write-Host "User clicked Cancel, exiting."
             Exit 
             }
}

# Stop Teams and Outlook so that we can proceed with clearing the cache.
Write-Host "Stopping Teams and Outlook..."
Get-Process -ProcessName Teams, Outlook -ErrorAction SilentlyContinue | Stop-Process -Force 
Write-Host "Teams and Outlook processes have been shut down."

# Deleting the cached Teams files for the current user.
Write-Host "Deleting Teams cache..."
try {
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\blob_storage" -recurse -force | Remove-Item -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\cache" | Remove-Item -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\databases" -recurse -force | Remove-Item -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\gpucache" -force | Remove-Item -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Indexeddb" -recurse -force | Remove-Item -recurse -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Local Storage" -recurse -force | Remove-Item -recurse -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\tmp" -recurse -force | Remove-Item -Confirm:$false
        New-Item -ItemType "file" -Path $env:APPDATA\"Microsoft\teams\" -Name scriptverify.txt
        } catch {
        echo $_
}
Write-Host "Cleanup complete."

# Start the Teams and Outlook-applications again.
Write-Host "Restarting Teams and Outlook..."
Start-Process $env:LOCALAPPDATA\Microsoft\teams\current\Teams.exe
Start Outlook
Write-Host "Teams and Outlook started."