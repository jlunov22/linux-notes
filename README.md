# linux-notes

Personal notes and journal for Linux setup, fixes, and issues encountered along the way.

## Index

- [fcitx5 install notes](fcitx5-install-note.md)
- [Arknights on Linux](Game/Arknights-On-Linux.md)
- [KVM — Bliss14 setup](kvm/bliss14/README.md)
- [Arch Linux install cheat sheet](arch-linux/INSTALL.md) ([troubleshooting](arch-linux/TROUBLESHOOTING.md))

## Journal

Dated log of issues and how they were resolved.

### 2026-01-28 — KDE freezes right after login

- **Issue:** KDE freezes right after login.
- **Reference:** [ddcutil#581](https://github.com/rockowitz/ddcutil/issues/581)
- **Temporary workaround:** add kernel parameter `amdgpu.dcdebugmask=0x10`
- **Fix:** caused by the `ddcutil` library; resolved in a newer release — update `ddcutil`.
