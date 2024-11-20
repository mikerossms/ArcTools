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
top -b -d 1 > top_usage.txt &

# Create the file
dd if=/dev/zero of=$outputFile bs=1M count=$fileSize oflag=direct 2> dd_output.txt

endTime=$(date +%s)
elapsedTime=$((endTime - startTime))

# Kill the background top process
pkill top

# Extract transfer speed from dd output
transferSpeed=$(grep -o '[0-9.]* MB/s' dd_output.txt)

# Extract CPU usage data
peakCpuUsage=$(grep '%Cpu(s)' top_usage.txt | awk '{print $2}' | sort -nr | head -1)
averageCpuUsage=$(grep '%Cpu(s)' top_usage.txt | awk '{print $2}' | awk '{sum+=$1} END {print sum/NR}')

# Extract memory usage data
peakMemoryUsage=$(grep 'KiB Mem' top_usage.txt | awk '{print $6}' | sort -nr | head -1)
averageMemoryUsage=$(grep 'KiB Mem' top_usage.txt | awk '{print $6}' | awk '{sum+=$1} END {print sum/NR}')

# Check if local disk is impacted
localDiskImpact=$(df / | awk 'NR==2 {print $5}')

# Output the results
echo "File creation time: $elapsedTime seconds"
echo "Transfer speed: $transferSpeed"
echo "Peak CPU usage: $peakCpuUsage%"
echo "Average CPU usage: $averageCpuUsage%"
echo "Peak memory usage: $peakMemoryUsage KB"
echo "Average memory usage: $averageMemoryUsage KB"
echo "Local disk usage: $localDiskImpact"
