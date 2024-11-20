#!/bin/bash

# Remote Stage location
storageLocation="/mnt/azurefiles"

# File size in MB
fileSize=1024

# The OS file device
osDevice="/sda"

# If the storage location does not exist, create it
if [ ! -d "$storageLocation" ]; then
  mkdir -p $storageLocation
fi

# Output the expected file size and location
fileSizeGiB=$(echo "scale=2; $fileSize / 1024" | bc)
echo "Creating a file of size $fileSize MiB ($fileSizeGiB GiB) at $storageLocation"

# Create a file of specified size using /dev/zero and measure the time and CPU usage
outputFile="$storageLocation/testfile"
startTime=$(date +%s)

# Record CPU and memory usage in the background
vmstat 1 > vmstat_usage.txt &

# Record disk throughput and IOPS in the background
iostat -dx 1 > iostat_usage.txt &

# Create the file
dd if=/dev/zero of=$outputFile bs=1M count=$fileSize oflag=direct 2> dd_output.txt

endTime=$(date +%s)
elapsedTime=$((endTime - startTime))

# Kill the background vmstat and iostat processes
pkill vmstat
pkill iostat

# Extract transfer speed from dd output
transferSpeed=$(grep -o '[0-9.]* MB/s' dd_output.txt)

# Extract CPU usage data
peakCpuUsage=$(awk 'NR>2 {print $13+$14}' vmstat_usage.txt | sort -nr | head -1)
averageCpuUsage=$(awk 'NR>2 {sum+=$13+$14} END {print sum/NR}' vmstat_usage.txt)

# Extract memory usage data
peakMemoryUsage=$(awk 'NR>2 {print $4}' vmstat_usage.txt | sort -nr | head -1)
averageMemoryUsage=$(awk 'NR>2 {sum+=$4} END {print sum/NR}' vmstat_usage.txt)

# Extract disk throughput and IOPS data
peakThroughput=$(awk -v device="$osDevice" '$1 == device {print $6}' iostat_usage.txt | sort -nr | head -1)
averageThroughput=$(awk -v device="$osDevice" '$1 == device {sum+=$6} END {print sum/NR}' iostat_usage.txt)
peakIOPS=$(awk -v device="$osDevice" '$1 == device {print $4+$5}' iostat_usage.txt | sort -nr | head -1)
averageIOPS=$(awk -v device="$osDevice" '$1 == device {sum+=$4+$5} END {print sum/NR}' iostat_usage.txt)

# Check if local disk is impacted
localDiskImpact=$(df / | awk 'NR==2 {print $5}')

# Output the results
echo "File creation time: $elapsedTime seconds"
echo "Transfer speed: $transferSpeed"
echo "Peak CPU usage: $peakCpuUsage%"
echo "Average CPU usage: $averageCpuUsage%"
echo "Peak memory usage: $peakMemoryUsage kB"
echo "Average memory usage: $averageMemoryUsage kB"
echo "Peak disk throughput: $peakThroughput kB/s"
echo "Average disk throughput: $averageThroughput kB/s"
echo "Peak IOPS: $peakIOPS"
echo "Average IOPS: $averageIOPS"
echo "Local disk usage: $localDiskImpact"