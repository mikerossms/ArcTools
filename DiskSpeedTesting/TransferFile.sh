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
        
        # Start top in batch mode to capture CPU and memory usage
        top -b -d 1 -n 2 -p $$ > top_output.txt &
        top_pid=$!
        
        # Copy the file
        cp "$file" "$folderDestination"
        
        # Stop top
        kill $top_pid
        
        end_time=$(date +%s.%N)
        
        speed=$(calculate_speed $file_size $start_time $end_time)
        file_size_mib=$(echo "scale=2; $file_size / 1024 / 1024" | bc)
        file_size_gib=$(echo "scale=2; $file_size / 1024 / 1024 / 1024" | bc)
        
        # Extract CPU and memory usage from top_output.txt
        peak_memory=$(grep "KiB Mem" top_output.txt | tail -1 | awk '{print $6}')
        average_memory=$(grep "KiB Mem" top_output.txt | tail -1 | awk '{print $8}')
        peak_cpu=$(grep "Cpu(s)" top_output.txt | tail -1 | awk '{print $2}')
        average_cpu=$(grep "Cpu(s)" top_output.txt | tail -1 | awk '{print $2}')
        
        echo "File: $(basename "$file") - Size: $file_size_gib GiB ($file_size_mib MiB) - Speed: $speed MB/s"
        echo "Peak Memory Usage: $peak_memory KB"
        echo "Average Memory Usage: $average_memory KB"
        echo "Peak CPU Usage: $peak_cpu %"
        echo "Average CPU Usage: $average_cpu %"
        
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