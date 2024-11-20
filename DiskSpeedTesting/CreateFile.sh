#Storage location
storageLocation="/mnt/storage"

#File size in MB
fileSize=1024

#If the storage location does not exist, create it
if [ ! -d "$storageLocation" ]; then
  mkdir $storageLocation
fi

# Start time
startTime=$(date +%s)

# Create a random file of size fileSize at the storageLocation
dd if=/dev/zero of=$storageLocation/testfile bs=1M count=$fileSize

# End time
endTime=$(date +%s)

# Calculate the time taken
timeTaken=$((endTime - startTime))

# Calculate the disk speed in MB/s
diskSpeed=$(echo "$fileSize / $timeTaken" | bc -l)

# Log the time taken and disk speed
echo "Time taken: $timeTaken seconds"
echo "Disk speed: $diskSpeed MB/s"

