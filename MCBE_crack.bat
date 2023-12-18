@echo off
setlocal enabledelayedexpansion

echo Starting the script...

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

echo Path to x86 DLL: %fileX86%
echo Path to x64 DLL: %fileX64%

set "destinationX86=C:\Windows\System32"
set "destinationX64=C:\Windows\SysWOW64"

echo Destination for x32 DLL: %destinationX32%
echo Destination for x64 DLL: %destinationX64%

REM Create a backup directory if it doesn't exist
set "backupDir=%scriptPath%dll\backup"
if not exist "%backupDir%" (
    mkdir "%backupDir%"
    echo Backup directory created: "%backupDir%"
)
set "backupDirX86=%scriptPath%dll\backup\x86"
if not exist "%backupDirX86%" (
    mkdir "%backupDirX86%"
    echo Backup directory for x32 DLL created: "%backupDirX86%"
)

set "backupDirX64=%scriptPath%dll\backup\x64"
if not exist "%backupDirX64%" (
    mkdir "%backupDirX64%"
    echo Backup directory for x64 DLL created: "%backupDirX64%"
)

REM Backup original DLL file
copy /Y "%destinationX86%\Windows.ApplicationModel.Store.dll" "%backupDirX86%" > nul
echo x86 DLL backed up to: "%backupDirX86%"
copy /Y "%destinationX64%\Windows.ApplicationModel.Store.dll" "%backupDirX64%" > nul
echo x64 DLL backed up to: "%backupDirX64%"

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

pause
