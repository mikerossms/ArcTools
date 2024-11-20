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
highest_peak_cpu=0

# Copy files and calculate transfer speed
for file in "$folderLocation"/*; do
    if [ -f "$file" ]; then
        file_size=$(stat -c%s "$file")
        file_size_mib=$(echo "scale=2; $file_size / 1024 / 1024" | bc)
        file_size_gib=$(echo "scale=2; $file_size / 1024 / 1024 / 1024" | bc)
        echo "Transferring file: $(basename "$file")"
        echo "Path: $file"
        echo "Size: $file_size_gib GiB ($file_size_mib MiB)"
        
        start_time=$(date +%s.%N)
        
        # Start vmstat in background to capture CPU and memory usage
        vmstat 1 > vmstat_output.txt &
        vmstat_pid=$!
        
        # Copy the file
        cp "$file" "$folderDestination"
        
        # Stop vmstat
        kill $vmstat_pid
        
        end_time=$(date +%s.%N)
        
        speed=$(calculate_speed $file_size $start_time $end_time)
        file_size_mib=$(echo "scale=2; $file_size / 1024 / 1024" | bc)
        file_size_gib=$(echo "scale=2; $file_size / 1024 / 1024 / 1024" | bc)
        
        # Extract CPU and memory usage from vmstat_output.txt
        peak_memory=$(awk 'NR>2 {print $4}' vmstat_output.txt | sort -n | tail -1)
        average_memory=$(awk 'NR>2 {sum+=$4} END {print sum/NR}' vmstat_output.txt)
        peak_cpu=$(awk 'NR>2 {print $13+$14}' vmstat_output.txt | sort -n | tail -1)
        average_cpu=$(awk 'NR>2 {sum+=$13+$14} END {print sum/NR}' vmstat_output.txt)
        
        echo "File: $(basename "$file") - Size: $file_size_gib GiB ($file_size_mib MiB) - Speed: $speed MB/s"
        peak_memory_mb=$(echo "scale=2; $peak_memory / 1024" | bc)
        average_memory_mb=$(echo "scale=2; $average_memory / 1024" | bc)
        echo "Peak Memory Usage: $peak_memory_mb MB"
        echo "Average Memory Usage: $average_memory_mb MB"
        echo "Peak CPU Usage: $peak_cpu %"
        echo "Average CPU Usage: $average_cpu %"
        
        # Update highest peak CPU usage
        if (( $(echo "$peak_cpu > $highest_peak_cpu" | bc -l) )); then
            highest_peak_cpu=$peak_cpu
        fi
        
        total_size=$(echo "$total_size + $file_size" | bc)
        total_time=$(echo "$total_time + $end_time - $start_time" | bc)
        file_count=$((file_count + 1))

        rm vmstat_output.txt
    fi
done

# Calculate overall average throughput speed
if [ $file_count -gt 0 ]; then
    average_speed=$(echo "scale=2; $total_size / $total_time / 1024 / 1024" | bc)
    echo .
    echo "Average Speed: $average_speed MB/s"
    echo "Total Transfer Time: $total_time seconds"
    echo "Highest Peak CPU Usage: $highest_peak_cpu %"
else
    echo "No files to transfer."
fi