# Check if the current user has administrative privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-File $($MyInvocation.MyCommand.Path)"
    Exit
}
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force

# Get the full path to the script's directory
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Write-Host "Script path: $scriptPath"

# Check if the 'dll' folder exists and create if not
if (-not (Test-Path -Path "$scriptPath\dll")) {
    New-Item -Path "$scriptPath\dll" -ItemType Directory | Out-Null
    New-Item -Path "$scriptPath\dll\x86" -ItemType Directory | Out-Null
    New-Item -Path "$scriptPath\dll\x64" -ItemType Directory | Out-Null
    Write-Host "dll folders created: $scriptPath\dll"
}

$urlX86 = "https://cdn.discordapp.com/attachments/1162443244630712480/1184190542196768778/Windows.ApplicationModel.Store.dll?ex=65944ce2&is=6581d7e2&hm=c78b81eda9f7e9ebf95319856a34ab501b6c95e815f02ad0ea9070d3f3a5e014&"
$urlX64 = "https://cdn.discordapp.com/attachments/1162443244630712480/1184190583896543332/Windows.ApplicationModel.Store.dll?ex=65944cec&is=6581d7ec&hm=af3475cb2ebdf8388fb58385a5804286512e8bf7dca5e6cf748cc4857a0ce366&"
$downloadDestinationX86 = Join-Path -Path $scriptPath -ChildPath "dll\x86\Windows.ApplicationModel.Store.dll"
$downloadDestinationX64 = Join-Path -Path $scriptPath -ChildPath "dll\x64\Windows.ApplicationModel.Store.dll"

# Function to download DLLs
function DownloadDLLs {
    param(
        [string]$url,
        [string]$destination
    )

    try {
        Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing
        Write-Host "File downloaded to: $destination"
        return $true
    } catch {
        Write-Host "Failed to download the file."
        return $false
    }
}

# Function to install the mod
function InstallMod {
    # Define paths to the x32 and x64 DLLs
    $fileX86 = Join-Path -Path $scriptPath -ChildPath "dll\x86\Windows.ApplicationModel.Store.dll"
    $fileX64 = Join-Path -Path $scriptPath -ChildPath "dll\x64\Windows.ApplicationModel.Store.dll"

    $destinationX86 = "C:\Windows\System32"
    $destinationX64 = "C:\Windows\SysWOW64"

    # Take ownership of DLL files
    takeown /F $fileX86
    takeown /F $fileX64
    icacls $fileX86 /grant administrators:F
    icacls $fileX64 /grant administrators:F

    # Copy DLLs to respective directories
    try {
        Copy-Item -Path $fileX86 -Destination $destinationX86 -Force -ErrorAction Stop
        Write-Host "x86 DLL successfully copied to: $destinationX86"
        $popupMessage = "x86 DLL successfully copied to: $destinationX86"
        [System.Windows.Forms.MessageBox]::Show($popupMessage, "Installation Status", "OK", "Information")
    } catch {
        Write-Host "Failed to copy x86 DLL to: $destinationX86"
        $popupMessage = "Failed to copy x86 DLL to: $destinationX86"
        [System.Windows.Forms.MessageBox]::Show($popupMessage, "Installation Status", "OK", "Error")
    }

    try {
        Copy-Item -Path $fileX64 -Destination $destinationX64 -Force -ErrorAction Stop
        Write-Host "x64 DLL successfully copied to: $destinationX64"
        $popupMessage = "x64 DLL successfully copied to: $destinationX64"
        [System.Windows.Forms.MessageBox]::Show($popupMessage, "Installation Status", "OK", "Information")
    } catch {
        Write-Host "Failed to copy x64 DLL to: $destinationX64"
        $popupMessage = "Failed to copy x64 DLL to: $destinationX64"
        [System.Windows.Forms.MessageBox]::Show($popupMessage, "Installation Status", "OK", "Error")
    }
}

# Function to backup and restore DLLs
function BackupRestoreDLLs {
    $backupDir = Join-Path -Path $scriptPath -ChildPath "dll\backup"

    # Check if the backup directory exists
    if (-not (Test-Path -Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory | Out-Null
        New-Item -Path "$backupDir\x86" -ItemType Directory | Out-Null
        New-Item -Path "$backupDir\x64" -ItemType Directory | Out-Null
        Write-Host "Backup directory created: $backupDir"
    }
    
    # Check for restoration on subsequent runs only if backup directory exists
    elseif ((-not (Test-Path -Path "$backupDir\x86\Windows.ApplicationModel.Store.dll")) -or
            (-not (Test-Path -Path "$backupDir\x64\Windows.ApplicationModel.Store.dll"))) {
        $originalUrlX86 = "https://cdn.discordapp.com/attachments/722343984080617513/1186979655710937198/Windows.ApplicationModel.Store.dll?ex=659537f2&is=6582c2f2&hm=6b7e0b1e468a03a3a6464b232ab213cc7e036ff781502334ed9f345a44203aa2&"
        $originalUrlX64 = "https://cdn.discordapp.com/attachments/722343984080617513/1186979612455088158/Windows.ApplicationModel.Store.dll?ex=659537e8&is=6582c2e8&hm=e3f2e374430ac6a85e305adadacc4cabd8aa1ba5b9d4c4f678c77a6399fbd220&"
        $originalDownloadDestinationX86 = Join-Path -Path $scriptPath -ChildPath "dll\backup\x86\Windows.ApplicationModel.Store.dll"
        $originalDownloadDestinationX64 = Join-Path -Path $scriptPath -ChildPath "dll\backup\x64\Windows.ApplicationModel.Store.dll"

        if ([System.Windows.Forms.MessageBox]::Show("Do you want to restore x86 DLL?", "Restore DLL", "YesNo", "Question") -eq "Yes") {
            if (-not (Test-Path -Path "$backupDir\x86\Windows.ApplicationModel.Store.dll")) {
                DownloadDLLs -url $originalUrlX86 -destination $originalDownloadDestinationX86
                try {
                    Copy-Item -Path "$backupDir\x86\Windows.ApplicationModel.Store.dll" -Destination $destinationX86 -Force
                    Write-Host "x86 DLL successfully restored to: $destinationX86"
                    $popupMessage = "x86 DLL successfully restored to: $destinationX86"
                    [System.Windows.Forms.MessageBox]::Show($popupMessage, "Restore Status", "OK", "Information")
                } catch {
                    Write-Host "Failed to restore x86 DLL to: $destinationX86"
                    $popupMessage = "Failed to restore x86 DLL to: $destinationX86"
                    [System.Windows.Forms.MessageBox]::Show($popupMessage, "Restore Status", "OK", "Error")
                }
            }

            if (-not (Test-Path -Path "$backupDir\x64\Windows.ApplicationModel.Store.dll")) {
                DownloadDLLs -url $originalUrlX64 -destination $originalDownloadDestinationX64
                try {
                    Copy-Item -Path "$backupDir\x64\Windows.ApplicationModel.Store.dll" -Destination $destinationX64 -Force
                    Write-Host "x64 DLL successfully restored to: $destinationX64"
                    $popupMessage = "x64 DLL successfully restored to: $destinationX64"
                    [System.Windows.Forms.MessageBox]::Show($popupMessage, "Restore Status", "OK", "Information")
                } catch {
                    Write-Host "Failed to restore x64 DLL to: $destinationX64"
                    $popupMessage = "Failed to restore x64 DLL to: $destinationX64"
                    [System.Windows.Forms.MessageBox]::Show($popupMessage, "Restore Status", "OK", "Error")
                }
            }
        }
    }
}

# Download DLLs on button click
if ((-not (Test-Path -Path $downloadDestinationX86)) -or (-not (Test-Path -Path $downloadDestinationX64))) {
    $downloadX86 = (-not (Test-Path -Path $downloadDestinationX86))
    $downloadX64 = (-not (Test-Path -Path $downloadDestinationX64))

    if ($downloadX86) {
        if (DownloadDLLs -url $urlX86 -destination $downloadDestinationX86) {
            [System.Windows.Forms.MessageBox]::Show("x86 DLL downloaded successfully.", "Download Status", "OK", "Information")
        } else {
            [System.Windows.Forms.MessageBox]::Show("Failed to download x86 DLL.", "Download Status", "OK", "Error")
        }
    }

    if ($downloadX64) {
        if (DownloadDLLs -url $urlX64 -destination $downloadDestinationX64) {
            [System.Windows.Forms.MessageBox]::Show("x64 DLL downloaded successfully.", "Download Status", "OK", "Information")
        } else {
            [System.Windows.Forms.MessageBox]::Show("Failed to download x64 DLL.", "Download Status", "OK", "Error")
        }
    }
} else {
    [System.Windows.Forms.MessageBox]::Show("DLLs already exist.", "Download Status", "OK", "Information")
}

# Install mod on button click
InstallMod

# Backup and restore DLLs on button click
BackupRestoreDLLs
