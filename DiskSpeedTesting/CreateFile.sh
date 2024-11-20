#Storage location
storageLocation="/mnt/storage"

#File size in MB
fileSize=1024


#If the storage location does not exist, create it
if [ ! -d "$storageLocation" ]; then
  mkdir $storageLocation
fi

# Notify user about the test start and file size
echo "Starting disk speed test for file creation at $storageLocation..."
echo "File size: $fileSize MiB ($(echo "scale=2; $fileSize / 1024" | bc) GiB)"

# Start time
startTime=$(date +%s)

# Start monitoring CPU and memory usage in the background
vmstat 1 > vmstat_usage.txt &
vmstat_pid=$!

# Create a random file of size fileSize at the storageLocation
dd if=/dev/zero of=$storageLocation/testfile bs=1M count=$fileSize

# End time
endTime=$(date +%s)

# Kill the background vmstat process
kill $vmstat_pid

# Calculate the time taken
timeTaken=$((endTime - startTime))

# Calculate the disk speed in MB/s
diskSpeed=$(echo "$fileSize / $timeTaken" | bc -l)

# Extract CPU usage data
peakCpuUsage=$(awk 'NR>2 {print $13+$14}' vmstat_usage.txt | sort -nr | head -1)
averageCpuUsage=$(awk 'NR>2 {sum+=$13+$14} END {print sum/NR}' vmstat_usage.txt)

# Extract memory usage data
peakMemoryUsage=$(awk 'NR>2 {print $4}' vmstat_usage.txt | sort -nr | head -1)
averageMemoryUsage=$(awk 'NR>2 {sum+=$4} END {print sum/NR}' vmstat_usage.txt)

# Convert memory usage from KiB to MiB
peakMemoryUsageMiB=$(echo "scale=2; $peakMemoryUsage / 1024" | bc)
averageMemoryUsageMiB=$(echo "scale=2; $averageMemoryUsage / 1024" | bc)

# Log the time taken, disk speed, and CPU/memory usage
echo "Time taken: $timeTaken seconds"
echo "Disk speed: $diskSpeed MB/s"
echo "Average CPU usage: $averageCpuUsage%"
echo "Peak CPU usage: $peakCpuUsage%"
echo "Average memory usage: $averageMemoryUsageMiB MiB"
echo "Peak memory usage: $peakMemoryUsageMiB MiB"

# Clean up
rm vmstat_usage.txt

