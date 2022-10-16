## Get latest version number of LimeCRM (used for detecting application in Microsoft Endpoint Manager / Intune)
$onlineJson = Invoke-WebRequest 'https://builds.lundalogik.com/api/v1/builds/limecrm-desktop/versions/' | ConvertFrom-Json
$appVersion = $onlineJson.versions_list | Select-Object -Last 1
$appVersion = $appVersion.version

$pathToLime = 'C:\Program Files (x86)\Lundalogik\Lime CRM\Lime.exe'

If ([version](Get-Item $pathToLime).VersionInfo.fileversion -match [version]"$appVersion") {
    Write-Host "Program found!"
}