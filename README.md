# Arch-install-note
Installing Arch Linux with Btrfs, systemd-boot and KDE

----

## Using SSH (optional)

Start SSH:

 # systemctl start sshd.service

Set a password for root:

> # passwd

Look up the IP address:

> # ip addr show

Connect via SSH:

' # ssh root@<YOUR.IP.ADDRESS> '



## Installation

### Partition 

gdisk /dev/sda

| LABEL | SIZE | CODE | NAME |
|---|---|---|---|
| BOOT | 1GB | EF00 | EFI system partition |
| ROOT | Rest | 8300 | Linux File System |



### Format 




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


### Ambient Sensor not working

[Ambient Sensor](https://github.com/mikhail-m1/illuminanced)


### DBeaver JDK Version 17+ 

"archlinux-java status"

"# archlinux-java set <JAVA_ENV_NAME>"

### USB HDD has No Write Access

 -Environment: KDE(Plasma) 
 -Mounted USB HDD fs: Btrfs
 
 Solution: ``Chmod 777 /run/media/[User ID]/[Mounted Device ID]``

 
