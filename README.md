#Rishi Sreekar rcheb001
#Kush Ise kise001
# A-Demonstration-of-Edge-Computing-with-Distributed-Cloudlets

Live migration allows you to move a running VM from one KVM host to another with minimal downtime. This is useful in scenarios like:
	•	Load balancing between hosts
	•	Maintenance on a host without interrupting running workloads
	•	Demonstrating a fog/cloud computing environment in which VMs can be moved closer to edge devices

Requirements
	•	4 hosts running a Linux distribution that supports KVM
	•	Administrative privileges (sudo) on each host.
	•	qemu-kvm, libvirt-bin, virtinst, and bridge-utils installed on all hosts.

**Setup**

Install and Configure KVM and Libvirt
	
1.	Update system packages (on each host):

sudo apt-get update
sudo apt-get install -y qemu-kvm libvirt-bin virtinst bridge-utils

2.	Enable and start libvirtd (on each host):
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

3.	Configure libvirt to listen for TCP connections (on each host):
Edit /etc/libvirt/libvirtd.conf and ensure the following lines are set:

listen_tls = 0
listen_tcp = 1
auth_tcp = "none"

 •	Edit /etc/default/libvirtd and set:
 libvirtd_opts="--listen"

•	Restart the service for changes to take effect:
sudo systemctl restart libvirtd

Create a VM Image
	1.	Download an Ubuntu cloud image 

 cd /var/lib/libvirt/images
sudo wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img \
     -O myvm.img


Create and Start the VM
Use virt-install to create a VM:
sudo virt-install \
    --name myvm \
    --ram 2048 \
    --vcpus 2 \
    --disk path=/var/lib/libvirt/images/myvm.img,size=10 \
    --cdrom /path/to/ubuntu-20.04.iso \
    --network bridge=br0 \
    --graphics none

On cloud introduce latency of 300ms
sudo tc qdisc add dev enp8s0d1 root netem delay 300ms

On cloud introduce latency of 20ms
sudo tc qdisc add dev enp8s0d1 root netem delay 20ms

On cloud introduce latency of 20ms
sudo tc qdisc add dev enp8s0d1 root netem delay 20ms

Based on the latency the VM migrates to the host with the lowest latency.
