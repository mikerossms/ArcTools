#Folder location of file to transfer
folderLocation="/mnt/storage"

#Folder destination for files
folderDestination="/mnt/azurefiles"

# Function to calculate transfer speed
calculate_speed() {
    local file_size=$1
    local start_time=$2
    local end_time=$3
    local duration=$(echo "$end_time - $start_time" | bc)
    local speed=$(echo "scale=2; $file_size / $duration / 1024 / 1024" | bc)
    echo $speed
}

# Initialize variables
total_size=0
total_time=0
file_count=0

# Copy files and calculate transfer speed
for file in "$folderLocation"/*; do
    if [ -f "$file" ]; then
        file_size=$(stat -c%s "$file")
        start_time=$(date +%s.%N)
        cp "$file" "$folderDestination"
        end_time=$(date +%s.%N)
        
        speed=$(calculate_speed $file_size $start_time $end_time)
        echo "File: $(basename "$file") - Speed: $speed MB/s"
        
        total_size=$(echo "$total_size + $file_size" | bc)
        total_time=$(echo "$total_time + $end_time - $start_time" | bc)
        file_count=$((file_count + 1))
    fi
done

# Calculate overall average throughput speed
if [ $file_count -gt 0 ]; then
    average_speed=$(echo "scale=2; $total_size / $total_time / 1024 / 1024" | bc)
    echo "Average Speed: $average_speed MB/s"
    echo "Total Transfer Time: $total_time seconds"
else
    echo "No files to transfer."
fi