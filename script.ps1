# Check if the current user has administrative privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Relaunch the script with elevated permissions
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-File $($MyInvocation.MyCommand.Path)"
    Exit
}
# Set Execution Policy to RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# Stop processes using Windows.ApplicationModel.Store.dll in System32 and SysWOW64 directories
$storeDllProcesses = @(
    Get-Process | Where-Object { $_.Modules.ModuleName -eq "Windows.ApplicationModel.Store.dll" }
)

foreach ($process in $storeDllProcesses) {
    try {
        Stop-Process -Id $process.Id -Force
        Write-Host "Stopped process $($process.ProcessName) (ID: $($process.Id))"
    } catch {
        Write-Host "Failed to stop process $($process.ProcessName) (ID: $($process.Id))"
    }
}

# Get the full path to the script's directory
$scriptPath = $PSScriptRoot
Write-Host "Script path: $scriptPath"


# Check if the 'dll' folder exists and create if not
if (-not (Test-Path -Path "$scriptPath\dll")) {
New-Item -Path "$scriptPath\dll" -ItemType Directory | Out-Null
    New-Item -Path "$scriptPath\dll\x86" -ItemType Directory | Out-Null
    New-Item -Path "$scriptPath\dll\x64" -ItemType Directory | Out-Null
    Write-Host "dll folders created: $scriptPath\dll"
}

# Define the URL to download the file from
$urlX86 = "https://cdn.discordapp.com/attachments/1162443244630712480/1184190542196768778/Windows.ApplicationModel.Store.dll?ex=65944ce2&is=6581d7e2&hm=c78b81eda9f7e9ebf95319856a34ab501b6c95e815f02ad0ea9070d3f3a5e014&"
$urlX64 = "https://cdn.discordapp.com/attachments/1162443244630712480/1184190583896543332/Windows.ApplicationModel.Store.dll?ex=65944cec&is=6581d7ec&hm=af3475cb2ebdf8388fb58385a5804286512e8bf7dca5e6cf748cc4857a0ce366&"

# Define the destination path for the downloaded file
$downloadDestinationX86 = Join-Path -Path $scriptPath -ChildPath "dll\x86\Windows.ApplicationModel.Store.dll"
$downloadDestinationX64 = Join-Path -Path $scriptPath -ChildPath "dll\x64\Windows.ApplicationModel.Store.dll"

# Function to download files
function DownloadDLLs {
    param(
        [string]$url,
        [string]$destination
    )

    try {
        Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing
        Write-Host "File downloaded to: $destination"
    } catch {
        Write-Host "Failed to download the file."
    }
}

# Download the files if they don't exist
if (-not (Test-Path -Path $downloadDestinationX86)) {
    DownloadDLLs -url $urlX86 -destination $downloadDestinationX86
}

if (-not (Test-Path -Path $downloadDestinationX64)) {
    DownloadDLLs -url $urlX64 -destination $downloadDestinationX64
}

# Define paths to the x32 and x64 DLLs
$fileX86 = Join-Path -Path $scriptPath -ChildPath "dll\x86\Windows.ApplicationModel.Store.dll"
$fileX64 = Join-Path -Path $scriptPath -ChildPath "dll\x64\Windows.ApplicationModel.Store.dll"

Write-Host "Path to x86 DLL: $fileX86"
Write-Host "Path to x64 DLL: $fileX64"

$destinationX86 = "C:\Windows\System32"
$destinationX64 = "C:\Windows\SysWOW64"

Write-Host "Destination for x86 DLL: $destinationX86"
Write-Host "Destination for x64 DLL: $destinationX64"

# Take ownership of DLL files
takeown /F $fileX86
takeown /F $fileX64

# Grant permissions to the current user
icacls $fileX86 /grant administrators:F
icacls $fileX64 /grant administrators:F

# Verify permissions and ownership
Get-Acl $fileX86 | Format-List
Get-Acl $fileX64 | Format-List

# Check if Backup folder exists and ask for restoration
if (Test-Path -Path "$scriptPath\dll") {
    $choice = Read-Host "DLL folder exists. Do you want to restore? [Y/N]"

    if ($choice -eq "Y" -or $choice -eq "y") {

        # Create a backup directory if it doesn't exist
        $backupDir = Join-Path -Path $scriptPath -ChildPath "dll\backup"
        if (-not (Test-Path -Path $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory | Out-Null
            New-Item -Path "$backupDir\x86" -ItemType Directory | Out-Null
            New-Item -Path "$backupDir\x64" -ItemType Directory | Out-Null
            Write-Host "Backup directory created: $backupDir"
        }


        $originalUrlX86 = "https://cdn.discordapp.com/attachments/722343984080617513/1186979655710937198/Windows.ApplicationModel.Store.dll?ex=659537f2&is=6582c2f2&hm=6b7e0b1e468a03a3a6464b232ab213cc7e036ff781502334ed9f345a44203aa2&"
        $originalUrlX64 = "https://cdn.discordapp.com/attachments/722343984080617513/1186979612455088158/Windows.ApplicationModel.Store.dll?ex=659537e8&is=6582c2e8&hm=e3f2e374430ac6a85e305adadacc4cabd8aa1ba5b9d4c4f678c77a6399fbd220&"
        
        $originalDownloadDestinationX86 = Join-Path -Path $scriptPath -ChildPath "dll\backup\x86\Windows.ApplicationModel.Store.dll"
        $originalDownloadDestinationX64 = Join-Path -Path $scriptPath -ChildPath "dll\backup\x64\Windows.ApplicationModel.Store.dll"

        # Download the files if they don't exist
        if (-not (Test-Path -Path $originalDownloadDestinationX86)) {
            DownloadDLLs -url $originalUrlX86 -destination $originalDownloadDestinationX86
        }

        if (-not (Test-Path -Path $originalDownloadDestinationX64)) {
            DownloadDLLs -url $originalUrlX64 -destination $originalDownloadDestinationX64
        }

        try {
            Copy-Item -Path "$backupDir\x86\Windows.ApplicationModel.Store.dll" -Destination $destinationX86 -Force
            Write-Host "x86 DLL successfully restored to: $destinationX86"

        } catch {
            Write-Host "Failed to restore x86 DLL to: $destinationX86"

        }

        try{
            Copy-Item -Path "$backupDir\x64\Windows.ApplicationModel.Store.dll" -Destination $destinationX64 -Force
            Write-Host "x64 DLL successfully restored to: $destinationX64"
        } catch {
            Write-Host "Failed to restore x64 DLL to: $destinationX64"
        }

    } else {
        # Replace DLL file
        Write-Host "Copying x86 DLL..."
        try {
            Copy-Item -Path "$scriptPath\dll\x86\Windows.ApplicationModel.Store.dll" -Destination $destinationX86 -Force -ErrorAction Stop
            Write-Host "x86 DLL successfully copied to: $destinationX86"
        } catch {
            Write-Host "Failed to copy x86 DLL to: $destinationX86"
            Write-Host "Error: $_.Exception.Message"
        }
        Write-Host "Copying x64 DLL..."
        try {
            Copy-Item -Path "$scriptPath\dll\x86\Windows.ApplicationModel.Store.dll" -Destination $destinationX86 -Force -ErrorAction Stop
            Write-Host "x86 DLL successfully copied to: $destinationX86"
        } catch {
            Write-Host "Failed to copy x86 DLL to: $destinationX86"
            Write-Host "Error: $_.Exception.Message"
        }
    }
}

# End of script
pause


