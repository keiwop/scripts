#!/usr/bin/zsh
cd /boot
mv vmlinuz-linux-arch vmlinuz-linux-arch.back
mv vmlinuz-linux vmlinuz-linux-arch
mv initramfs-linux-arch.img initramfs-linux-arch.img.back
mv initramfs-linux.img initramfs-linux-arch.img
