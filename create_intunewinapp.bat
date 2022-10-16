@echo off
:: Please modify the paths below to suit your needs (path to the IntuneWinAppUtil.exe app, Source Folder and Output Folder)
SET winAppUtil=C:\Temp\Intune-Win32-App-Packaging-Tool-master\IntuneWinAppUtil.exe
SET sourceFolder=C:\Temp\IntunePackageSource
SET outputFolder=C:\Temp\IntunePackageOutput

:: Information that is displayed when running the script
echo Automates the creation of intunewinapps. Edit the file should the paths not match your needs.
echo:
echo Path to IntuneWinAppUtil.exe: %winAppUtil%
echo Current source folder: %sourceFolder%
echo Current output folder %outputFolder%
echo:

:: Do not modify the information below unless needed
SET /p installFile="Please input the name of the install file: "
%winAppUtil% -c %sourceFolder% -s %installFile% -o %outputFolder% -q