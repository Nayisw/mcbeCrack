@echo off

REM Get the current directory of the script
set "scriptPath=%~dp0"
echo Script path: %scriptPath%

REM Check if the 'dll' folder exists and create it if not
if not exist "%scriptPath%\dll" (
    mkdir "%scriptPath%\dll"
    mkdir "%scriptPath%\dll\x86"
    mkdir "%scriptPath%\dll\x64"
    echo dll folders created: %scriptPath%\dll
)

REM Define URLs for file downloads
set "urlX86=https://cdn.discordapp.com/attachments/1162443244630712480/1184190542196768778/Windows.ApplicationModel.Store.dll?ex=65944ce2&is=6581d7e2&hm=c78b81eda9f7e9ebf95319856a34ab501b6c95e815f02ad0ea9070d3f3a5e014&"
set "urlX64=https://cdn.discordapp.com/attachments/1162443244630712480/1184190583896543332/Windows.ApplicationModel.Store.dll?ex=65944cec&is=6581d7ec&hm=af3475cb2ebdf8388fb58385a5804286512e8bf7dca5e6cf748cc4857a0ce366&"

REM Define download destinations
set "downloadDestinationX86=%scriptPath%\dll\x86\Windows.ApplicationModel.Store.dll"
set "downloadDestinationX64=%scriptPath%\dll\x64\Windows.ApplicationModel.Store.dll"

REM Function to download files
:DownloadDLLs
set "url=%~1"
set "destination=%~2"

echo Downloading %url% to %destination%
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%url%', '%destination%')"

REM Download files if they don't exist
if not exist "%downloadDestinationX86%" call :DownloadDLLs "%urlX86%" "%downloadDestinationX86%"
if not exist "%downloadDestinationX64%" call :DownloadDLLs "%urlX64%" "%downloadDestinationX64%"

REM Define paths to the x32 and x64 DLLs
set "fileX86=%scriptPath%\dll\x86\Windows.ApplicationModel.Store.dll"
set "fileX64=%scriptPath%\dll\x64\Windows.ApplicationModel.Store.dll"

echo Path to x86 DLL: %fileX86%
echo Path to x64 DLL: %fileX64%

REM Define destinations for x86 and x64 DLLs
set "destinationX86=C:\Windows\System32"
set "destinationX64=C:\Windows\SysWOW64"

echo Destination for x86 DLL: %destinationX86%
echo Destination for x64 DLL: %destinationX64%

REM Check if Backup folder exists and ask for restoration
if exist "%scriptPath%\dll" (
    set /p "choice=DLL folder exists. Do you want to restore? [Y/N]: "

    if /i "%choice%"=="Y" (
        REM Create a backup directory if it doesn't exist
        if not exist "%scriptPath%\dll\backup" (
            mkdir "%scriptPath%\dll\backup"
            mkdir "%scriptPath%\dll\backup\x86"
            mkdir "%scriptPath%\dll\backup\x64"
            echo Backup directory created: %scriptPath%\dll\backup
        )

        set "originalUrlX86=https://cdn.discordapp.com/attachments/722343984080617513/1186979655710937198/Windows.ApplicationModel.Store.dll?ex=659537f2&is=6582c2f2&hm=6b7e0b1e468a03a3a6464b232ab213cc7e036ff781502334ed9f345a44203aa2&"
        set "originalUrlX64=https://cdn.discordapp.com/attachments/722343984080617513/1186979612455088158/Windows.ApplicationModel.Store.dll?ex=659537e8&is=6582c2e8&hm=e3f2e374430ac6a85e305adadacc4cabd8aa1ba5b9d4c4f678c77a6399fbd220&"
        
        set "originalDownloadDestinationX86=%scriptPath%\dll\backup\x86\Windows.ApplicationModel.Store.dll"
        set "originalDownloadDestinationX64=%scriptPath%\dll\backup\x64\Windows.ApplicationModel.Store.dll"

        REM Download the files if they don't exist
        if not exist "%originalDownloadDestinationX86%" call :DownloadDLLs "%originalUrlX86%" "%originalDownloadDestinationX86%"
        if not exist "%originalDownloadDestinationX64%" call :DownloadDLLs "%originalUrlX64%" "%originalDownloadDestinationX64%"

        echo Copying x86 DLL...
        copy /Y "%scriptPath%\dll\backup\x86\Windows.ApplicationModel.Store.dll" "%destinationX86%"
        if %errorlevel% equ 0 (
            echo x86 DLL successfully restored to: %destinationX86%
        ) else (
            echo Failed to restore x86 DLL to: %destinationX86%
        )

        echo Copying x64 DLL...
        copy /Y "%scriptPath%\dll\backup\x64\Windows.ApplicationModel.Store.dll" "%destinationX64%"
        if %errorlevel% equ 0 (
            echo x64 DLL successfully restored to: %destinationX64%
        ) else (
            echo Failed to restore x64 DLL to: %destinationX64%
        )
    ) else (
        REM Replace DLL files
        echo Copying x86 DLL...
        copy /Y "%scriptPath%\dll\x86\Windows.ApplicationModel.Store.dll" "%destinationX86%"
        if %errorlevel% equ 0 (
            echo x86 DLL successfully copied to: %destinationX86%
        ) else (
            echo Failed to copy x86 DLL to: %destinationX86%
        )

        echo Copying x64 DLL...
        copy /Y "%scriptPath%\dll\x64\Windows.ApplicationModel.Store.dll" "%destinationX64%"
        if %errorlevel% equ 0 (
            echo x64 DLL successfully copied to: %destinationX64%
        ) else (
            echo Failed to copy x64 DLL to: %destinationX64%
        )

        if %errorlevel% neq 0 (
            echo Failed to replace the DLL file.
        ) else (
            echo File replacement successful in %destinationX86% and %destinationX64%
        )
    )
)

pause
