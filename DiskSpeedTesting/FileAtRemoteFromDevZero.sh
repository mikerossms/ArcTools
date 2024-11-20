#Remote Stage location
storageLocation="/mnt/azurefiles"

#File size in MB
fileSize=1024

#If the storage location does not exist, create it
if [ ! -d "$storageLocation" ]; then
  mkdir $storageLocation
fi

# Output the expected file size and location
fileSizeGiB=$(echo "scale=2; $fileSize / 1024" | bc)
echo "Creating a file of size $fileSize MiB ($fileSizeGiB GiB) at $storageLocation"

# Create a file of specified size using /dev/zero and measure the time and CPU usage
outputFile="$storageLocation/testfile"
startTime=$(date +%s)

# Record CPU and memory usage in the background
vmstat 1 > vmstat_usage.txt &

# Create the file
dd if=/dev/zero of=$outputFile bs=1M count=$fileSize oflag=direct 2> dd_output.txt

endTime=$(date +%s)
elapsedTime=$((endTime - startTime))

# Kill the background vmstat process
pkill vmstat

# Extract transfer speed from dd output
transferSpeed=$(grep -o '[0-9.]* MB/s' dd_output.txt)

# Extract CPU usage data
peakCpuUsage=$(awk 'NR>2 {print $13}' vmstat_usage.txt | sort -nr | head -1)
averageCpuUsage=$(awk 'NR>2 {print $13}' vmstat_usage.txt | awk '{sum+=$1} END {print sum/NR}')

# Extract memory usage data
peakMemoryUsage=$(awk 'NR>2 {print $4}' vmstat_usage.txt | sort -nr | head -1)
averageMemoryUsage=$(awk 'NR>2 {print $4}' vmstat_usage.txt | awk '{sum+=$1} END {print sum/NR}')

# Check if local disk is impacted
localDiskImpact=$(df / | awk 'NR==2 {print $5}')

# Output the results
echo "File creation time: $elapsedTime seconds"
echo "Transfer speed: $transferSpeed"
echo "Peak CPU usage: $peakCpuUsage%"
echo "Average CPU usage: $averageCpuUsage%"
peakMemoryUsageMB=$(echo "scale=2; $peakMemoryUsage / 1024" | bc)
averageMemoryUsageMB=$(echo "scale=2; $averageMemoryUsage / 1024" | bc)
echo "Peak memory usage: $peakMemoryUsageMB MB"
echo "Average memory usage: $averageMemoryUsageMB MB"
echo "Local disk usage: $localDiskImpact"

rm vmstat_usage.txt