#!/bin/bash

# Tenha certeza que voce tem o qemu-nbd instalado e funcionando.

# IMPORTANTE: Esse método não se dá muito bem com snapshots. 
# Crie uma nova máquina virtual sem nenhum snapshot se precisar.

# IMPORTANTE 2: Sempre desmonte a partição antes de iniciar a VM 
# e desligue-a através do comando shutdown no Virtual Box para
# evitar corrupção de arquivos. 

# Faça cópias/backups da VDI e use git. Caso você inicie 
# a VM sem antes desmontar a partição, a imagem será corrompida.

# Como usar: 
#     - Defina o local onde o script vai montar a partição a partir da VDI (.vdi)
#     - Execute "mount_minix.sh modprobe" para ativar o módulo do kernel com as configurações corretas
#     - Use "mount_minix.sh m" para montar (transformar a VDI numa partição da sua máquina)
#     - Use "mount_minix.sh u" para desmontar (converter a partição para .vdi)

minix_vdi="/home/lucas/VirtualBox VMs/Minix3/Minix3.vdi"
mountpoint="/mnt/minix"

if [ "$EUID" -ne 0 ]
  then sudo $0 $1
  exit
fi

if [ "$1" == "modprobe" ]; then
    rmmod nbd
    sleep 2
    modprobe nbd max_part=16
    exit
fi

if [ "$1" == "m" ]; then
    #rmmod nbd
    #modprobe nbd max_part=16
    #sleep 1
    qemu-nbd -c /dev/nbd0 "$minix_vdi"
    mount -t minix /dev/nbd0p5 "$mountpoint"
    mount -t minix /dev/nbd0p7 "$mountpoint/usr"
    exit
fi

if [ "$1" == "u" ] ; then
    umount -l "$mountpoint/usr"
    umount -l "$mountpoint"
    qemu-nbd -d /dev/nbd0
    exit
fi

echo "Missing argument: expepected m (mount) or u (umount)"
