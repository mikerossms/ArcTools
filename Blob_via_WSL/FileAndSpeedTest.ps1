$smallFilesSize = 100
$smallFilesNum = 100

$largeFilesSize = 3000
$largeFilesNumber = 20

$writeSource = "D:\datawrite"
$writeDrive = "Z:"
$writeDestination = "$writeDrive\"

$readSource = $writeDestination
$readDrive = "D:"
$readDestination = "$readDrive\dataread"


#check to see if the Mount-WSLBlobNFS powershell command is available
if (-not (Get-Command -Name Mount-WSLBlobNFS)) {
    Write-Host "Mount-WSLBlobNFS module not found. Please refer to the README.md file for installation instructions."
    exit
}

#Check to see if there is a blob mount point
$status = Get-SmbMapping -LocalPath $writeDrive
if (-not $status) {
    Write-Host "Blob mount point not found. Please refer to the README.md file for installation instructions."
    exit
}

#Check the state of the mount point
if ($status.Status -eq "Unavailable") {
    Write-Host "The Blob Mount point is currently unavailable.  Attempting to remount."
    Assert-PipelineWSLBlobNFS

    #Check the state again, it should now be "OK"
    if ($status.Status -eq "OK") {
        Write-Host "The Blob Mount point is now mounted."
    }
}

Write-Host "Starting Tests" -ForegroundColor Green

#Create the small files
Write-Host "Generating small files"
./generate-files.ps1 -targetFolder $writeSource -numFiles $smallFilesNum -fileSizeMB $smallFilesSize

$smallFilesCreated = Get-ChildItem -Path $writeSource | Measure-Object | Select-Object -ExpandProperty Count

if ($smallFilesCreated -eq $smallFilesNum) {
    Write-Host "Small files created successfully"
} else {
    Write-Host "Error: Small files not created"
}

#Upload the small files
Write-Host "Uploading small files"
./transfer-files.ps1 -sourcePath $writeSource -destinationPath $writeDestination

#Check to see if the read path exists and create it if not
if (-not (Test-Path -Path $readDestination)) {
    try {
        New-Item -Path $readDestination -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Host "Failed to create folder $readDestination. Error: $_"
        exit
    }
}

#Download the small files
Write-Host "Downloading small files"
./transfer-files.ps1 -sourcePath $readSource -destinationPath $readDestination


#Delete the small files
Write-Host "Deleting small files: $writeSource, $writeDestination and $readDestination"
Remove-Item -Path $writeSource\* -Force
Remove-Item -Path $writeDestination\* -Force
Remove-Item -Path $readDestination\* -Force


#Create the large files
Write-Host "Generating large files"
./generate-files.ps1 -targetFolder $writeSource -numFiles $largeFilesNum -fileSizeMB $largeFilesSize

$largeFilesCreated = Get-ChildItem -Path $writeSource | Measure-Object | Select-Object -ExpandProperty Count

if ($largeFilesCreated -eq $smallFilesNum) {
    Write-Host "Large files created successfully"
} else {
    Write-Host "Error: Large files not created"
}

#Upload the large files
Write-Host "Uploading large files"
./transfer-files.ps1 -sourcePath $writeSource -destinationPath $writeDestination

#Check to see if the read path exists and create it if not
if (-not (Test-Path -Path $readDestination)) {
    try {
        New-Item -Path $readDestination -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Host "Failed to create folder $readDestination. Error: $_"
        exit
    }
}

#Download the large files
Write-Host "Downloading large files"
./transfer-files.ps1 -sourcePath $readSource -destinationPath $readDestination


#Delete the small files
Write-Host "Deleting large files: $writeSource, $writeDestination and $readDestination"
Remove-Item -Path $writeSource\* -Force
Remove-Item -Path $writeDestination\* -Force
Remove-Item -Path $readDestination\* -Force