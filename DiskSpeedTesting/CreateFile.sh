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
top -b -d 1 > /tmp/top_usage.txt &
top_pid=$!

# Create a random file of size fileSize at the storageLocation
dd if=/dev/zero of=$storageLocation/testfile bs=1M count=$fileSize

# End time
endTime=$(date +%s)

# Kill the background top process
kill $top_pid

# Calculate the time taken
timeTaken=$((endTime - startTime))

# Calculate the disk speed in MB/s
diskSpeed=$(echo "$fileSize / $timeTaken" | bc -l)

# Extract CPU usage data
peakCpuUsage=$(grep '%Cpu(s)' top_usage.txt | awk '{print $2}' | sort -nr | head -1)
averageCpuUsage=$(grep '%Cpu(s)' top_usage.txt | awk '{print $2}' | awk '{sum+=$1} END {print sum/NR}')

# Extract memory usage data
peakMemoryUsage=$(grep 'KiB Mem' top_usage.txt | awk '{print $6}' | sort -nr | head -1)
averageMemoryUsage=$(grep 'KiB Mem' top_usage.txt | awk '{print $6}' | awk '{sum+=$1} END {print sum/NR}')



# Log the time taken, disk speed, and CPU/memory usage
echo "Time taken: $timeTaken seconds"
echo "Disk speed: $diskSpeed MB/s"
echo "Average CPU usage: $averageCpuUsage%"
echo "Peak CPU usage: $peakCpuUsage%"
echo "Average memory usage: $averageMemoryUsage KiB"
echo "Peak memory usage: $peakMemoryUsage KiB"

# Clean up
rm /tmp/top_output.txt

