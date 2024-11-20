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
top -b -d 1 -n 0 > /tmp/top_output.txt &
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

# Extract CPU and memory usage from the top output
averageCpu=$(awk '/^%Cpu/ {sum += $2; count++} END {print sum/count}' /tmp/top_output.txt)
peakCpu=$(awk '/^%Cpu/ {if ($2 > max) max=$2} END {print max}' /tmp/top_output.txt)
averageMem=$(awk '/^KiB Mem/ {sum += $8; count++} END {print sum/count}' /tmp/top_output.txt)
peakMem=$(awk '/^KiB Mem/ {if ($8 > max) max=$8} END {print max}' /tmp/top_output.txt)

# Log the time taken, disk speed, and CPU/memory usage
echo "Time taken: $timeTaken seconds"
echo "Disk speed: $diskSpeed MB/s"
echo "Average CPU usage: $averageCpu%"
echo "Peak CPU usage: $peakCpu%"
echo "Average memory usage: $averageMem KiB"
echo "Peak memory usage: $peakMem KiB"

# Clean up
rm /tmp/top_output.txt

