param (
    [string]$sourcePath = "C:\data",
    [string]$destinationPath = "Z:\",
    [int]$fileSizeMB = 100,
    [double]$fileSizeVariance = 0.5
)

# Create a log file to record transfer times
$logFilePath = Join-Path $sourcePath "transfer_log.txt"

# Initialize variables for total transfer time and file count
$totalTransferTime = 0
$fileCount = 0

# Get all files in the source directory
$files = Get-ChildItem -Path $sourcePath -File

$count = 0
# Loop through each file and copy it to the destination
$totalFileSize = 0
foreach ($file in $files) {
    $count  ++
    $startTime = Get-Date
    Copy-Item -Path $file.FullName -Destination $destinationPath
    $endTime = Get-Date

    # Calculate transfer time in seconds
    $transferTime = ($endTime - $startTime).TotalSeconds

    #Calculate the transfer speed
    $fileSize = (Get-Item $file.FullName).Length / 1MB
    $transferSpeedMB = $filesize/$transferTime

    # Append transfer time to the log file
    Add-Content -Path $logFilePath -Value "$($count): $($file.Name): $transferTime seconds ($($transferSpeedMB))"
    write-host "$($count): $($file.Name): $transferTime seconds ($($transferSpeedMB))"

    # Update total transfer time and file count
    $totalTransferTime += $transferTime
    $totalFileSize += $fileSize
    $fileCount++
}

# Calculate average throughput in MB/s
$averageThroughputFiles = $totalTransferTime / $fileCount
$averageThroughputMBs = [math]::Round(($totalFileSize / $totalTransferTime), 2)

# Display average throughput
write-host "Files Copied: $count"
write-host "Total transfer time: $totalTransferTime"
write-host "Total data transferred: $totalfileSize MB"
Write-Host "Average throughput: $averageThroughputFiles seconds per file"
Write-Host "Average throughput: $averageThroughputMBs MB/s"

# Clean up: Remove the log file if it exists
#if (Test-Path $logFilePath) {
#    Remove-Item -Path $logFilePath
#}
