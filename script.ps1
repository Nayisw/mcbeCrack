# Get the full path to the script's directory
$scriptPath = $PSScriptRoot
Write-Host "Script path: $scriptPath"

# Define paths to the x32 and x64 DLLs
$fileX86 = Join-Path -Path $scriptPath -ChildPath "dll\x86\Windows.ApplicationModel.Store.dll"
$fileX64 = Join-Path -Path $scriptPath -ChildPath "dll\x64\Windows.ApplicationModel.Store.dll"

# Check if the 'dll' folder exists and create if not
if (-not (Test-Path -Path "$scriptPath\dll")) {
    New-Item -Path "$scriptPath\dll\x86" -ItemType Directory | Out-Null
    New-Item -Path "$scriptPath\dll\x64" -ItemType Directory | Out-Null
    Write-Host "dll folders created: $scriptPath\dll"
}

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

# Define the URL to download the file from
$urlX86 = "https://github.com/Nayisw/mcbeCrack/raw/main/dll/x86/Windows.ApplicationModel.Store.dll"
$urlX64 = "https://github.com/Nayisw/mcbeCrack/raw/main/dll/x64/Windows.ApplicationModel.Store.dll"

# Define the destination path for the downloaded file
$downloadDestinationX86 = Join-Path -Path $scriptPath -ChildPath "dll\x86\Windows.ApplicationModel.Store.dll"
$downloadDestinationX64 = Join-Path -Path $scriptPath -ChildPath "dll\x64\Windows.ApplicationModel.Store.dll"

# Download the files if they don't exist
if (-not (Test-Path -Path $downloadDestinationX86)) {
    DownloadDLLs -url $urlX86 -destination $downloadDestinationX86
}

if (-not (Test-Path -Path $downloadDestinationX64)) {
    DownloadDLLs -url $urlX64 -destination $downloadDestinationX64
}


$fileX86 = "$scriptPath\dll\x86" 
$fileX64 = "$scriptPath\dll\x64"


Write-Host "Path to x86 DLL: $fileX86"
Write-Host "Path to x64 DLL: $fileX64"

$destinationX86 = "C:\Windows\System32"
$destinationX64 = "C:\Windows\SysWOW64"

Write-Host "Destination for x86 DLL: $destinationX86"
Write-Host "Destination for x64 DLL: $destinationX64"

# Create a backup directory if it doesn't exist
$backupDir = Join-Path -Path $scriptPath -ChildPath "dll\backup"
if (-not (Test-Path -Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory | Out-Null
    Write-Host "Backup directory created: $backupDir"
}

# Function to backup DLL files
function BackupDLL {
    param(
        [string]$arch
    )

    $backupDirArch = Join-Path -Path $backupDir -ChildPath $arch
    $destinationArch = if ($arch -eq "x86") { $destinationX86 } else { $destinationX64 }

    if (-not (Test-Path -Path $backupDirArch)) {
        New-Item -Path $backupDirArch -ItemType Directory | Out-Null
        Write-Host "Backup directory for $arch DLL created: $backupDirArch"
        # Backup original DLL file
        Copy-Item -Path "$destinationArch\Windows.ApplicationModel.Store.dll" -Destination $backupDirArch -Force
        Write-Host "$arch DLL backed up to: $backupDirArch"
    }
}

# Backup x86 DLL
BackupDLL -arch "x86"

# Backup x64 DLL
BackupDLL -arch "x64"

# Check if Backup folder exists and ask for restoration
if (Test-Path -Path $backupDir) {
    $choice = Read-Host "Backup folder exists. Do you want to restore? [Y/N]"

    if ($choice -eq "Y" -or $choice -eq "y") {
        Copy-Item -Path "$backupDir\x86\Windows.ApplicationModel.Store.dll" -Destination $destinationX86 -Force
        if ($?) {
            Write-Host "x86 DLL successfully restored to: $destinationX86"
        } else {
            Write-Host "Failed to restore x86 DLL to: $destinationX86"
        }

        Copy-Item -Path "$backupDir\x64\Windows.ApplicationModel.Store.dll" -Destination $destinationX64 -Force
        if ($?) {
            Write-Host "x64 DLL successfully restored to: $destinationX64"
        } else {
            Write-Host "Failed to restore x64 DLL to: $destinationX64"
        }
    } else {
        # Replace DLL file
        Write-Host "Copying x86 DLL..."
        Copy-Item -Path "$scriptPath\dll\x86\Windows.ApplicationModel.Store.dll" -Destination $destinationX86 -Force
        if ($?) {
            Write-Host "x86 DLL successfully copied to: $destinationX86"
        } else {
            Write-Host "Failed to copy x86 DLL to: $destinationX86"
        }

        Write-Host "Copying x64 DLL..."
        Copy-Item -Path "$scriptPath\dll\x64\Windows.ApplicationModel.Store.dll" -Destination $destinationX64 -Force
        if ($?) {
            Write-Host "x64 DLL successfully copied to: $destinationX64"
        } else {
            Write-Host "Failed to copy x64 DLL to: $destinationX64"
        }

        if (-not $?) {
            Write-Host "Failed to replace the DLL file."
        } else {
            Write-Host "File replacement successful in $destinationX86 and $destinationX64"
        }
    }
}

# End of script
pause
