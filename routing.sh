#!/bin/bash
# Candidate destination nodes
nodes=("10.10.1.2" "10.10.1.4" "10.10.1.3")

# Array of VMs to migrate
vms=("vm1" "vm2" "mynatvm")

for vm in "${vms[@]}"; do
  echo "------------------------------------------------------"
  echo "Evaluating migration for VM: $vm"

  best_node=""
  lowest_latency=1000000

  for node in "${nodes[@]}"; do
    # Ping once with 1 second timeout; capture output containing 'time='
    result=$(ping -c 1 -W 1 "$node" | grep 'time=')
    if [ -z "$result" ]; then
      echo "  Node $node unreachable."
      continue
    fi

    # Extract latency value (in ms)
    latency=$(echo "$result" | sed -n 's/.*time=\([0-9.]*\) ms.*/\1/p')
    echo "  Latency to $node: ${latency} ms"

    # Compare using awk 
    if [ "$(awk -v lat="$latency" -v low="$lowest_latency" 'BEGIN {print (lat < low) ? "yes" : "no"}')" = "yes" ]; then
      lowest_latency="$latency"
      best_node="$node"
    fi
  done

  if [ "$vm" == "mynatvm" ]; then
    forced_result=$(ping -c 1 -W 1 "10.10.1.3" | grep 'time=')
    if [ -n "$forced_result" ]; then
      forced_latency=$(echo "$forced_result" | sed -n 's/.*time=\([0-9.]*\) ms.*/\1/p')
      lowest_latency="$forced_latency"
    else
      lowest_latency="N/A"
    fi
    best_node="10.10.1.3"
  fi

  if [ -z "$best_node" ]; then
    echo "No candidate node reachable for VM $vm. Skipping migration."
    continue
  fi

  if [ "$lowest_latency" = "N/A" ]; then
    echo "Selected destination for $vm: $best_node"
  else
    echo "Selected destination for $vm: $best_node (Latency: ${lowest_latency} ms)"
  fi

  # Construct the destination URI for TCP-based migration
  DESTINATION_URI="qemu+tcp://${best_node}/system"
  echo "Initiating migration of $vm to $best_node..."

 # Start timer
  start_time=$(date +%s)

  # Run migration command
  sudo virsh migrate --live --unsafe --verbose --persistent --copy-storage-all "$vm" "$DESTINATION_URI"
  status=$?

  end_time=$(date +%s)
  elapsed=$(( end_time - start_time ))
  if [ $status -eq 0 ]; then
    echo "Migration of $vm completed successfully in ${elapsed} seconds."
  else
    echo "Migration of $vm failed with exit code $status after ${elapsed} seconds."
  fi

done

echo "All VM migrations attempted."