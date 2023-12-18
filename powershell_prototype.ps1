# Define the path to the script's directory
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Write-Output "Script path: $scriptPath"

# Define paths to the x86 and x64 DLLs
$fileX86 = "$scriptPath\dll\x86\Windows.ApplicationModel.Store.dll"
$fileX64 = "$scriptPath\dll\x64\Windows.ApplicationModel.Store.dll"

Write-Output "Path to x86 DLL: $fileX86"
Write-Output "Path to x64 DLL: $fileX64"

$destinationX86 = "C:\Windows\System32"
$destinationX64 = "C:\Windows\SysWOW64"

Write-Output "Destination for x32 DLL: $destinationX86"
Write-Output "Destination for x64 DLL: $destinationX64"

# Create a backup directory if it doesn't exist
$backupDir = "$scriptPath\dll\backup"
if (-not (Test-Path -Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-Output "Backup directory created: $backupDir"
}

$backupDirX86 = "$scriptPath\dll\backup\x86"
if (-not (Test-Path -Path $backupDirX86)) {
    New-Item -ItemType Directory -Path $backupDirX86 | Out-Null
    Write-Output "Backup directory for x32 DLL created: $backupDirX86"
}

$backupDirX64 = "$scriptPath\dll\backup\x64"
if (-not (Test-Path -Path $backupDirX64)) {
    New-Item -ItemType Directory -Path $backupDirX64 | Out-Null
    Write-Output "Backup directory for x64 DLL created: $backupDirX64"
}

# Backup original DLL files
Copy-Item -Path "$destinationX86\Windows.ApplicationModel.Store.dll" -Destination $backupDirX86 -ErrorAction SilentlyContinue
Write-Output "x86 DLL backed up to: $backupDirX86"
Copy-Item -Path "$destinationX64\Windows.ApplicationModel.Store.dll" -Destination $backupDirX64 -ErrorAction SilentlyContinue
Write-Output "x64 DLL backed up to: $backupDirX64"

# Replace DLL files
Write-Output "Copying x86 DLL..."
Copy-Item -Path $fileX86 -Destination $destinationX86 -Force
if ($?) {
    Write-Output "x86 DLL successfully copied to: $destinationX86"
} else {
    Write-Output "Failed to copy x86 DLL to: $destinationX86"
}

Write-Output "Copying x64 DLL..."
Copy-Item -Path $fileX64 -Destination $destinationX64 -Force
if ($?) {
    Write-Output "x64 DLL successfully copied to: $destinationX64"
} else {
    Write-Output "Failed to copy x64 DLL to: $destinationX64"
}

if ($LASTEXITCODE -eq 0) {
    Write-Output "File replacement successful in $destinationX86 and $destinationX64"
} else {
    Write-Output "Failed to replace the DLL file."
}

# Add a pause-like behavior
Write-Output "Press Enter to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
