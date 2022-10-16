#########################################################################################################################
# This script installs GlobalProtect if it's not installed, and will reinstall GlobalProtect if it's already installed. #
# Written by Joni Ljungqvist, 2021-12-23.                                                                               #
#########################################################################################################################
 
# File paths to check for installation status of GlobalProtect
$filePath = "C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPA.exe"
$fileMSI = "C:\Program Files\Palo Alto Networks\GlobalProtect\globalprotect.msi"
 
# Set uninstall and install arguments for GlobalProtect
$installArg = '/i "C:\Program Files\Palo Alto Networks\GlobalProtect\globalprotect.msi" /q PORTAL=portalAddress'
$uninstallArg = '/x "C:\Program Files\Palo Alto Networks\GlobalProtect\globalprotect.msi" /q'
 
# Check if MSI exists, if it doesn't, create directory and download file
if(-Not (Test-Path -path $fileMSI)) {
    Write-Host "MSI-file doesn't exist, proceeding to download MSI-file."
    # Check if directory exists, otherwise create it
    if(-Not (Test-Path -path "C:\Program Files\Palo Alto Networks\GlobalProtect")) {
        New-Item "C:\Program Files\Palo Alto Networks\GlobalProtect" -ItemType "directory"
    }
    Invoke-WebRequest -Uri "https://msiaddresspath.com" -OutFile "C:\Program Files\Palo Alto Networks\GlobalProtect\globalprotect.msi"
}
 
# Check if GlobalProtect is installed
if(Test-Path -path $filePath)
{
    Write-Host "GlobalProtect is installed, proceeding to uninstall and then reinstall GlobalProtect."
    # Uninstall GlobalProtect using existing MSI-file
    Start-Process msiexec.exe -ArgumentList $uninstallArg -Wait
    Write-Host "GlobalProtect has been uninstalled. Proceeding to reinstall GlobalProtect."
    # Install GlobalProtect using existing MSI-file
    Start-Process msiexec.exe -ArgumentList $installArg -Wait
    Write-Host "GlobalProtect has been installed."
}
else {
    Write-Host "GlobalProtect is not installed, proceeding to install."
    Start-Process msiexec.exe -ArgumentList $installArg -Wait
    Write-Host "GlobalProtect has been installed."
}
 
# Creates a file which is used to verify that the script worked
New-Item "C:\Program Files\Palo Alto Networks\GlobalProtect\reinstalled.txt" -ItemType "file" -Force