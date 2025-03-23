#!/bin/bash

interface="enp8s0d1"

sudo tc qdisc add dev "$interface" root netem delay 15ms


for i in {1..7}; do

  delay=$(( RANDOM % 5 + 15 ))

  sudo tc qdisc change dev "$interface" root netem delay "${delay}ms"
  
  echo "Iteration $i: Set latency to ${delay}ms on $interface"

  sleep 10
done

for i in {1..32}; do

delay=$(( RANDOM % 5 + 21 ))

  sudo tc qdisc change dev "$interface" root netem delay "${delay}ms"

  echo "Iteration $i: Set latency to ${delay}ms on $interface"

  sleep 10
done

# Optionally, remove the netem rule when finished
sudo tc qdisc del dev "$interface" root