############################################################################
# This script installs latest version of LimeCRM if not already installed. #
# Joni Ljungqvist, 2022-01-26.                                             #
############################################################################

# Get latest version number of LimeCRM
$onlineJson = Invoke-WebRequest 'https://builds.lundalogik.com/api/v1/builds/limecrm-desktop/versions/' -UseBasicParsing | ConvertFrom-Json
$appVersion = $onlineJson.versions_list | Select-Object -Last 1
$appVersion = $appVersion.version

# Path to Lime if already installed and to temporary directory
$pathToLime = 'C:\Program Files (x86)\Lundalogik\Lime CRM\Lime.exe'
$tempFile = 'C:\Temp\limecrm-desktop.exe'
$tempExisted = $true

# Check whether Lime is installed or if version installed is older than the current version
if (-Not (Test-Path -path $pathToLime) -Or [version](Get-Item $pathToLime).VersionInfo.fileversion -lt [version]"$appVersion") {
    Write-Host "Version is older than current version, proceeding to install."

    # Check if a C:\Temp directory exists, otherwise create it, we will use it to store the installer there
    if (-Not (Test-Path -path C:\Temp)) {
    New-Item "C:\Temp" -ItemType "directory"
    $tempExisted = $false
    }
        # Download setup file
        Invoke-WebRequest -Uri "https://builds.lundalogik.com/api/v1/builds/limecrm-desktop/versions/$appVersion/file/?tag=released" -UseBasicParsing -OutFile $tempFile

        # Start installation
        Write-Host "Proceeding to install latest version of LimeCRM."
        Start-Process $tempFile -ArgumentList "/install","/passive","/LIMELANGUAGE=sv" -Wait
        Write-Host "LimeCRM has been installed."

        # Remove installation file if it remains
        if (Test-Path $tempFile) {
            Remove-Item $tempFile
            Write-Host "Installer was removed."
        }

        # Remove Temp-directory if it didn't exist before
        if ($tempExisted = $false) {
            Remove-Item "C:\Temp"
            Write-Host "C:\Temp was removed."
        }

        Write-Host "Exiting script."
        Exit
    }

# Check if latest version is already installed
elseIf ([version](Get-Item $pathToLime).VersionInfo.fileversion -match [version]"$appVersion") {
    Write-Host "Latest version is already installed, exiting."
    Exit
}

# Else exit the script
else {
    Write-Host "Exiting script."
    Exit
}