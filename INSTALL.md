# Install

Cheat sheet for installing Arch Linux with Btrfs. Pick the options that match the machine before starting.

----

## Options

| Step | Choices |
|---|---|
| CPU vendor | **Intel** (`intel-ucode`) or **AMD** (`amd-ucode`) |
| Bootloader | **systemd-boot** (simple, UEFI-native) or **GRUB** (needed for Secure Boot / separate ext4 `/boot`) |
| `/boot` filesystem | **FAT32 only** (default) or **separate ext4** (GRUB only, Fedora-style) |
| Secure Boot | **Skip** or **enable** via `sbctl` (GRUB only) |
| Disk encryption | **None** or **LUKS** or **LUKS + TPM2 auto-unlock** (needs TPM2 hardware) |

Commands below have no `#`/`$` prompt prefix so they can be copied and run as-is. Values in `<ANGLE_BRACKETS>` must be edited before running.

----

## Using SSH (optional)

```
systemctl start sshd.service
passwd
ip addr show
```

From another machine:
```
ssh root@<YOUR.IP.ADDRESS>
```

## Installation

```
lsblk -f
```

### Partition

```
gdisk /dev/sda
```

| LABEL | SIZE | CODE | NAME |
|---|---|---|---|
| EFI | 1GB | EF00 | EFI system partition |
| ROOT | Rest | 8300 | Linux File System |

> If using a separate ext4 `/boot`, add a third partition between EFI and ROOT: `BOOT` 1GB, code `8300`.

```
Create new GPT:
Command (? for help): o

Create a partition for EFI
Command (? for help): n
Partition number 1
Filetype EF00

Create a partition for ROOT
Command (? for help): n
Partition number 2
Filetype 8300

Write the new partitions to disk:
Command (? for help): w
```

### Format

```
mkfs.vfat -F32 -n EFI /dev/sda1
```

> If using a separate ext4 `/boot`:
> ```
> mkfs.ext4 -L BOOT /dev/sda2
> ```
> (ROOT becomes `/dev/sda3` in every step below instead of `/dev/sda2`)

> If using LUKS, encrypt the ROOT partition first, then use `/dev/mapper/cryptroot` in place of `/dev/sda2` in every step below:
> ```
> cryptsetup luksFormat /dev/sda2
> cryptsetup open /dev/sda2 cryptroot
> ```

```
mkfs.btrfs -L ROOT /dev/sda2
```

### Create, Mount and Sub Volumes

```
mount /dev/sda2 /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@swap
btrfs sub create /mnt/@home
btrfs sub create /mnt/@pkg
btrfs sub create /mnt/@log
btrfs sub create /mnt/@.snapshots
btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/@swap/swapfile
umount /mnt
```

Mount sub volumes:

```
mount -o noatime,compress=zstd,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache/pacman/pkg,.snapshots,swap,btrfs}
mount -o noatime,nodiratime,compress=zstd,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,nodiratime,compress=zstd,subvol=@pkg /dev/sda2 /mnt/var/cache/pacman/pkg
mount -o noatime,nodiratime,compress=zstd,subvol=@log /dev/sda2 /mnt/var/log
mount -o noatime,nodiratime,compress=zstd,subvol=@.snapshots /dev/sda2 /mnt/.snapshots
mount -o noatime,nodiratime,subvol=@swap /dev/sda2 /mnt/swap
mount -o noatime,compress=zstd /dev/sda2 /mnt/btrfs
```

> If using a separate ext4 `/boot`:
> ```
> mount /dev/sda2 /mnt/boot
> mkdir -p /mnt/boot/efi
> mount /dev/sda1 /mnt/boot/efi
> ```
> (EFI mounts at `/mnt/boot` directly otherwise.)

Install essential packages:
```
pacstrap -K /mnt base linux linux-firmware
```

CPU microcode (pick one):
```
pacstrap -K /mnt intel-ucode
pacstrap -K /mnt amd-ucode
```

Utilities — file system tools, network manager, text editor:
```
pacstrap -K /mnt btrfs-progs networkmanager neovim
```

Generate `/etc/fstab` with UUID:
```
genfstab -U /mnt >> /mnt/etc/fstab
```

Add the swap file entry (not picked up by `genfstab`):
```
echo "/swap/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
```

Chroot:
```
arch-chroot /mnt
```

Time:
```
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
```

Edit `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8`, then:
```
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo <YOURHOSTNAME> > /etc/hostname
```

Edit `/etc/mkinitcpio.conf`, add `btrfs`:
```
MODULES=(btrfs)
```

> If using LUKS with a password prompt, also add `encrypt` to `HOOKS=(...)`, before `filesystems`. LUKS + TPM2 auto-unlock needs `sd-encrypt` instead — see the LUKS + TPM2 section below.

```
mkinitcpio -P
```

----

## Boot Manager — Option A: systemd-boot

```
bootctl install
```

Create `/boot/loader/entries/arch.conf`:
```
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=PARTUUID=<PARTUUID-OF-ROOT-PARTITION> rootflags=subvol=@ rw
```
(Use `/amd-ucode.img` instead if on AMD.)

Get PARTUUID of ROOT partition:
```
blkid -s PARTUUID -o value /dev/sda2
```

> If using LUKS, replace `root=PARTUUID=...` with `rd.luks.name=<LUKS-UUID>=cryptroot root=/dev/mapper/cryptroot`. Get the LUKS UUID:
> ```
> blkid -s UUID -o value /dev/sda2
> ```

## Boot Manager — Option B: GRUB + Secure Boot

```
pacstrap -K /mnt grub efibootmgr sbctl
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

> `--efi-directory=/boot` assumes the default FAT32-only layout. If using a separate ext4 `/boot`, use `--efi-directory=/boot/efi` instead.

### Secure Boot with sbctl (optional)

Enable "Setup Mode" for Secure Boot in firmware first.

```
sbctl status
sbctl create-keys
sbctl enroll-keys -m
sbctl sign -s /boot/vmlinuz-linux
sbctl sign -s /boot/EFI/GRUB/grubx64.efi
```

### Fix world-accessible /boot warning

Add `fmask=0077,dmask=0077` to the `/boot` line in `/etc/fstab` (see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)).

----

```
exit
umount -R /mnt
```

Now it's time to reboot into the new system.

## LUKS + TPM2 auto-unlock (optional)

Only if the machine has a TPM2 chip and LUKS was set up above. Check first:
```
systemd-cryptenroll --tpm2-device=list
```

Enroll the TPM2:
```
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7 /dev/sda2
```

Then switch `/etc/mkinitcpio.conf` to the systemd-based hooks so unlocking happens automatically at boot — replace `encrypt` (and the `udev` hook) with:
```
HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
```
```
mkinitcpio -P
```
No kernel parameter change or `grub-mkconfig` re-run is needed — `sd-encrypt` unlocks via TPM2 automatically once enrolled.

## Create New User

```
useradd -m -g users -G wheel,power,audio,video -s /usr/bin/zsh MYUSERNAME
passwd MYUSERNAME
```

Setup sudo:
```
EDITOR=nvim visudo
```
Uncomment `%wheel ALL=(ALL:ALL) ALL`

Install AUR helper:
```
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```
