cat bliss14_start.sh    
#!/bin/bash

VARS_FILE="$HOME/VMs/bliss14/bliss14_OVMF_VARS.fd"
DISK_FILE="$HOME/VMs/bliss14/disks/Bliss14.qcow2"
 ISO_FILE="$HOME/Downloads/Bliss-Surface-v14.10.3-x86_64-OFFICIAL-foss-20241013.iso"

qemu-system-x86_64 \
  -enable-kvm \
  -M q35 \
  -m 8192 -smp 4 -cpu host \
  -bios /usr/share/ovmf/x64/OVMF.4m.fd \
  -drive file="$DISK_FILE",if=virtio,format=qcow2 \
  -cdrom "$ISO_FILE" \
  -usb \
  -device virtio-tablet \
  -device virtio-keyboard \
  -device qemu-xhci,id=xhci \
  -machine vmport=off \
  -device virtio-vga-gl -display sdl,gl=on \
  -audiodev pipewire,id=snd0 \
  -device ich9-intel-hda \
  -device hda-duplex,audiodev=snd0 \
  -net nic,model=virtio-net-pci -net user,hostfwd=tcp::4444-:5555
