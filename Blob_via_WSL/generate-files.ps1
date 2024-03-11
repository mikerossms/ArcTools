param (
    [string]$targetFolder = "C:\data",
    [int]$numFiles = 100,
    [int]$fileSizeMB = 100,
    [double]$fileSizeVariance = 0.5
)

$minSize = $fileSizeMB * $fileSizeVariance
$maxSize = $fileSizeMB + $minSize

$maxSpaceRequired = $maxSize * $numFiles

# Check available disk space
write-host "Checking available disk space in $targetFolder"
$diskSpace = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Root -ieq $targetFolder.Substring(0,3)}
if ($diskSpace.Free -lt $maxSpaceRequired) {
    Write-Host "Insufficient disk space in $targetFolder."
    exit
}

# Check the folder exists and if not create it
if (-not (Test-Path -Path $targetFolder)) {
    try {
        New-Item -Path $targetFolder -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Host "Failed to create folder $targetFolder. Error: $_"
        exit
    }
}


# Generate files
write-host "Generating $numFiles files in $targetFolder"
for ($i = 1; $i -le $numFiles; $i++) {
    # Generate a random 12-character filename
    $randomName = -join ((65..90) + (97..122) | Get-Random -Count 12 | ForEach-Object { [char]$_ })

    # Create a random file size between 20MiB and 50MiB
    $randomSize = Get-Random -Minimum ($($minSize)*(1024*1024)) -Maximum ($($maxSize)*(1024*1024))

    # Construct the full file path
    $filePath = Join-Path -Path $targetFolder -ChildPath "$randomName.file"

    # Create an empty file with the specified size
    New-Item -Path $filePath -ItemType File -Force | Out-Null
    Set-Content -Path $filePath -Value $null
    $fileStream = [System.IO.File]::OpenWrite($filePath)
    $fileStream.SetLength($randomSize)
    $fileStream.Close()
}

Write-Host "$numFiles files created in $targetFolder."
