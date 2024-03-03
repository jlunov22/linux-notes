# Arch-install-note

Quick note to Arch Linux Disotro

----

## Installation

=====

## Issues:

### Boot Loader Alert
⚠️ Mount point '/boot' which backs the random seed file is world accessible, which is a security hole! ⚠️
⚠️ Random seed file '/boot/loader/.#bootctlrandom-seed25**************' is world accessible, which is a security hole! ⚠️

Solution: Change /etc/fstab /boot (/EFI) fmask=0077, dmask=0077 


### Ambient Sensor not working

'https://github.com/mikhail-m1/illuminanced'


### DBeaver JDK Version 17+ 

"archlinux-java status"

"# archlinux-java set <JAVA_ENV_NAME>"

### USB HDD has No Write Access

 -Environment: KDE(Plasma) 
 
 -Mounted USB HDD fs: Btrfs
 
 Solution: Chmod 777 /run/media/[User ID]/[Mounted Device ID]

 
