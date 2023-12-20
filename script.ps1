# Define the content of your batch script (replace this with your actual batch script content)
$batchScriptContent = @"
@echo off
setlocal enabledelayedexpansion

REM Check for administrative privileges
>nul 2>&1 net file
if %errorlevel% neq 0 (
    echo This script requires administrative privileges.
    echo Please run the script as an administrator.
    pause
    exit /b
)

REM Check for Developer Mode
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" >nul 2>&1
if %errorlevel% neq 0 (
    echo Developer mode is not enabled on this system.
    echo Please enable Developer Mode to proceed.
    pause
    exit /b
)

REM Get the full path to the script's directory
set "scriptPath=%~dp0"
echo Script path: %scriptPath%

REM Define paths to the x32 and x64 DLLs
set "fileX86=%scriptPath%dll\x86\Windows.ApplicationModel.Store.dll"
set "fileX64=%scriptPath%dll\x64\Windows.ApplicationModel.Store.dll"

REM Check if the 'dll' folder exists and create if not
if not exist "%scriptPath%dll" (
    mkdir "%scriptPath%dll"
    echo dll folder created: "%scriptPath%dll"
)

echo Path to x86 DLL: %fileX86%
echo Path to x64 DLL: %fileX64%

set "destinationX86=C:\Windows\System32"
set "destinationX64=C:\Windows\SysWOW64"

echo Destination for x86 DLL: %destinationX86%
echo Destination for x64 DLL: %destinationX64%

REM Create a backup directory if it doesn't exist
set "backupDir=%scriptPath%dll\backup"
if not exist "%backupDir%" (
    mkdir "%backupDir%"
    echo Backup directory created: "%backupDir%"
)

REM Function to backup DLL files
:BackupDLL
set "arch=x86"
set "backupDirArch=%backupDir%\%arch%"
set "destinationArch=!destination%arch%!"

if not exist "!backupDirArch!" (
    mkdir "!backupDirArch!"
    echo Backup directory for %arch% DLL created: "!backupDirArch!"
    REM Backup original DLL file
    copy /Y "!destinationArch!\Windows.ApplicationModel.Store.dll" "!backupDirArch!" > nul
    echo %arch% DLL backed up to: "!backupDirArch!"
)

set "arch=x64"
set "backupDirArch=%backupDir%\%arch%"
set "destinationArch=!destination%arch%!"

if not exist "!backupDirArch!" (
    mkdir "!backupDirArch!"
    echo Backup directory for %arch% DLL created: "!backupDirArch!"
    REM Backup original DLL file
    copy /Y "!destinationArch!\Windows.ApplicationModel.Store.dll" "!backupDirArch!" > nul
    echo %arch% DLL backed up to: "!backupDirArch!"
)

REM Check if Backup folder exists and ask for restoration
if exist "%backupDir%" (
    set /p "choice=Backup folder exists. Do you want to restore? [Y/N]: "
    if /I "!choice!"=="Y" (
        robocopy "%backupDir%\x86" "%destinationX86%" Windows.ApplicationModel.Store.dll
        if %errorlevel% equ 0 (
        echo x86 DLL successfully restored to: "%destinationX86%"
        ) else (
            echo Failed to restore x86 DLL to: "%destinationX86%"
        )

        robocopy "%backupDir%\x64" "%destinationX64%" Windows.ApplicationModel.Store.dll
        if %errorlevel% equ 0 (
            echo x64 DLL successfully restored to: "%destinationX64%"
        ) else (
            echo Failed to restore x64 DLL to: "%destinationX64%"
        )
    ) else (
        REM Replace DLL file
        echo Copying x86 DLL...
        robocopy "%scriptPath%dll\x86" "%destinationX86%" Windows.ApplicationModel.Store.dll
        if %errorlevel% equ 0 (
            echo x86 DLL successfully copied to: "%destinationX86%"
        ) else (
            echo Failed to copy x86 DLL to: "%destinationX86%"
        )

        echo Copying x64 DLL...
        robocopy "%scriptPath%dll\x64" "%destinationX64%" Windows.ApplicationModel.Store.dll
        if %errorlevel% equ 0 (
            echo x64 DLL successfully copied to: "%destinationX64%"
        ) else (
            echo Failed to copy x64 DLL to: "%destinationX64%"
        )

        if not errorlevel 1 (
            echo File replacement successful in "%destinationX86%" and "%destinationX64%"
        ) else (
            echo Failed to replace the DLL file.
        )

    )
)

:end
endlocal
pause

"@

# Convert the batch script content to Base64
$encodedBatchScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($batchScriptContent))

# Decode and execute the batch script content using cmd.exe (Command Prompt)
$encodedBatchScript | Out-File -FilePath $env:TEMP\MCBE_crack.bat -Encoding ASCII
cmd.exe /c $env:TEMP\MCBE_crack.bat
