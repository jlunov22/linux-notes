# Arch-install-note
Installing Arch Linux with Btrfs, systemd-boot and KDE

----

## Using SSH (optional)

Start SSH:

``# systemctl start sshd.service``

Set a password for root:

``# passwd``

Look up the IP address:

`` # ip addr show``

Connect via SSH:

`` # ssh root@<YOUR.IP.ADDRESS> ``



## Installation

```
lsblk-f

```

### Partition 

# gdisk /dev/sda

| LABEL | SIZE | CODE | NAME |
|---|---|---|---|
| BOOT | 1GB | EF00 | EFI system partition |
| ROOT | Rest | 8300 | Linux File System |

```
Create new GPT:

Command (? for help): o

Create a partition for EFI

Command (? for help): n
Partition number 1
Filetype EF00

Create a partition for ROOT

Command (? for help): n
Partation number 2
Filetype 8300

Write the new partitions to disk:

Command (? for help): w
```

### Format 

FAT32 Label: EFI
``# mkfs.vfat -F32 -n EFI /dev/sda1``

Btrfs Label: ROOT
``# mkfs.btrfs -L ROOT /dev/mapper/luks``

### Create, Mount and Sub Volumes

```
# mount /dev/sda2 /mnt
# btrfs sub create /mnt/@
# btrfs sub create /mnt/@swap
# btrfs sub create /mnt/@home
# btrfs sub create /mnt/@pkg
# btrfs sub create /mnt/@log
# btrfs sub create /mnt/@.snapshots
# btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/@swap/swapfile
# umount /mnt
```
Mount sub volumes

```
# mount -o noatime,compress=zstd,subvol=@ /dev/sda2 /mnt
# mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots,btrfs}
# mount -o noatime,nodiratime,compress=zstd,subvol=@home /dev/sda2 /mnt/home
# mount -o noatime,nodiratime,compress=zstd,subvol=@pkg /dev/sda2 /mnt/var/cache/pacman/pkg
# mount -o noatime,nodiratime,compress=zstd,subvol=@log /dev/sda2 /mnt/var/log
# mount -o noatime,nodiratime,compress=zstd,subvol=@.snapshots /dev/sda2 /mnt/var/.snapshots
# mount -o noatime,nodiratime,compress=zstd,subvol=@swap /dev/swap
```

Install essential packages
``# pacstrap -K /mnt base linux linux-firmware``

CPU micro-code, utilify for file system, network manager, text editor
``# pacstrap -K /mnt intel-ucode btrfs-progs networkmanager neovim``

Generate /etc/fstab with UUID
``# genfstab -U /mnt >> /mnt/etc/fstab``

Chroot
``# arch-chroot /mnt``
Time
```
# ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
# hwclock --systohc
```

Edit /etc/locale.gen and uncomment en_US.UTF-8 UTF-8
``# locale-gen``

```
# echo "LANG=en_US.UTF-8" > /etc/locale.conf
# echo <YOURHOSTNAME> > /etc/hostname
```
Add btrfs to Initramfs
``MOUDLES=(btrfs)``

``# mkinitcpio -P``

## Boot Manager
Install systemd-boot
``# bootctl install``

Create file /boot/loader/entries/arch.conf and fill it with:
```
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=PARTUUID=<PARTUUID-OF-ROOT-PARTITION> rootflags=subvol=@ rw rootfs=btrfs
```
Get PARTUUID of ROOT partation
``# blkid -s PARTUUID -o value /dev/sda2``


Type ``exit`` to exit chroot

``# umount -R /mnt/`` to unmount all volumes

Now its time to reboot into the new system

## Create New User
```
# useradd -m -g users -G wheel,power,audio,video -s /usr/bin/zsh MYUSERNAME
passwd MYUSERNAME
```

Setup sudo

``# export EDITOR=nvim visudo``
Uncommend ``%wheel ALL=(ALL:ALL) ALL``

Install Aur
```
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```



=====

> [!NOTE]
> Useful information that users should know, even when skimming content.

> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.


> [!TIP]
> Backup with rsync in local drive 

``$ rsync -av --delete /Directory1/ /Directory2/``


## Issues:

### Boot Loader Alert
⚠️ Mount point '/boot' which backs the random seed file is world accessible, which is a security hole! ⚠️
⚠️ Random seed file '/boot/loader/.#bootctlrandom-seed25**************' is world accessible, which is a security hole! ⚠️

Solution: Change /etc/fstab /boot (/EFI) fmask=0077, dmask=0077 


### Ambient Sensor not working (Asus Zenbook)

Install AUR:[illuminanced](https://github.com/mikhail-m1/illuminanced)


### DBeaver JDK Version 17+ 

"archlinux-java status"

"# archlinux-java set <JAVA_ENV_NAME>"

### USB HDD has No Write Access

 -Environment: KDE(Plasma) 
 -Mounted USB HDD fs: Btrfs
 
 Solution: ``Chmod 777 /run/media/[User ID]/[Mounted Device ID]``

 
