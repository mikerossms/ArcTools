#Remote Stage location
storageLocation="/mnt/azurefiles"

#File size in MB
fileSize=1024

#If the storage location does not exist, create it
if [ ! -d "$storageLocation" ]; then
  mkdir $storageLocation
fi

# Create a file of specified size using /dev/zero and measure the time and CPU usage
outputFile="$storageLocation/testfile"
startTime=$(date +%s)

# Record CPU usage in the background
mpstat -P ALL 1 > cpu_usage.txt &

# Create the file
dd if=/dev/zero of=$outputFile bs=1M count=$fileSize oflag=direct 2> dd_output.txt

endTime=$(date +%s)
elapsedTime=$((endTime - startTime))

# Kill the background mpstat process
pkill mpstat

# Extract transfer speed from dd output
transferSpeed=$(grep -o '[0-9.]* MB/s' dd_output.txt)

# Extract CPU usage data
peakCpuUsage=$(grep 'all' cpu_usage.txt | awk '{print $3}' | sort -nr | head -1)
averageCpuUsage=$(grep 'all' cpu_usage.txt | awk '{print $3}' | awk '{sum+=$1} END {print sum/NR}')

# Output the results
echo "File creation time: $elapsedTime seconds"
echo "Transfer speed: $transferSpeed"
echo "Peak CPU usage: $peakCpuUsage%"
echo "Average CPU usage: $averageCpuUsage%"