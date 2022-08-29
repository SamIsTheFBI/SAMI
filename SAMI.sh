#!/bin/sh

[ -z "$(ls /sys/firmware/efi/efivars)" ] && BOOTMODE='BIOS' || BOOTMODE='UEFI'

#PART1 - Base Install
clear
loadkeys us
echo -e "Welcome to Sam's Arch Machine Installer Script\n\nBoot Mode: ${BOOTMODE}\n"
echo -e "Create your user profile: "
echo -e "Username: "
read USERNAME
echo -e "Password for ${USERNAME}: "
read PASSWORD
echo -e "Set root password: "
read ROOTPASSWORD
echo ${USERNAME}:${PASSWORD} >> login_details.txt
echo root:${ROOTPASSWORD} >> login_details.txt
echo ${USERNAME} >> login_details.txt
echo -e "Set a hostname: "
read HOSTNAME
echo ${HOSTNAME} >> login_details.txt
echo ${BOOTMODE} >> login_details.txt
clear

echo -e "cfdisk will launch now. There, set up partitions."
echo -e "Swap Partition: >=2GB\nEFI Partition: >=256MB\nLinux Filesystem: Rest of the space"
echo -e "The paths for these partitions will be required in further steps\n\n"
echo -e "Launching cfdisk in 5s..\n"
sleep 5

cfdisk

for ((i = 0; i < 1; )); do
  clear && lsblk -lp
  echo -e "Which partition to format for Linux Filesystem?\n[/dev/sda1|sda2|...|sdb1|sdb2|...]"
  read LINUXFS
  [ ! -e ${LINUXFS} ] && echo -e "Given location does not exist!" || i=2
done

echo -e "Formatting Linux Filesystem partition..\n"
mkfs.ext4 ${LINUXFS}
echo -e "Mounting Linux Filesystem partition..\n"
mount ${LINUXFS} /mnt

echo -e "Make Swap?\n[y/Yes/YES/n/No/NO]"
read ANS
case "${ANS}" in
  y|yes|YES|Yes)
    for ((i = 0; i < 1; )); do
      clear && lsblk -lp
      echo -e "Which partition for swap?\n[/dev/sda1|sda2|...|sdb1|sdb2|...]"
      read SWAP
      [ ! -e ${SWAP} ] && echo -e "Given location does not exist!\n" || i=2
    done
    echo -e "Creating Swap partition...\n"
    mkswap ${SWAP}
    swapon ${SWAP}
    ;;
  n|no|NO|No)
    echo -e "No swap partition will be created.\n"
    ;;
  *) echo -e "Invalid option. Exiting..\n"
  ;;
esac

for ((i = 0; i < 1; )); do
     clear && lsblk -lp
     echo -e "Path to EFI partition:\n[/dev/sda1|sda2|...|sdb1|sdb2|...]"
     read EFI
     [ ! -e ${EFI} ] && echo -e "Given location does not exist!" && continue || i=2
done

if [[ "${BOOTMODE}" == 'BIOS' ]]; then
  for ((i = 0; i < 1; )); do
       echo -e "Path to EFI disk:\n[/dev/sda|sdb|sdc|...]"
       read GRUBIOS
       [ ! -e ${GRUBIOS} ] && echo -e "Given location does not exist!" && continue || i=2
       echo ${GRUBIOS} >> login_details.txt
  done
fi
      
echo -e "Format EFI partition? Enter 'No' if an EFI partition was already present before this installation and you want to dual boot\n[y/Yes/YES/n/No/NO]"
read ANS
case "${ANS}" in
  y|yes|YES|Yes)
    echo -e "Formatting EFI partition..\n"
    [[ "${BOOTMODE}" == 'UEFI' ]] && mkfs.fat -F32 ${EFI} || mkfs.ext2 ${EFI}
    ;;
  n|no|NO|No)
    echo -e "EFI partition will not be formatted.\n"
    ;;
  *) 
    echo -e "Invalid option. Exiting..\n"
    ;;
esac

[[ "${BOOTMODE}" == 'UEFI' ]] && EFIDIR=/mnt/boot/efi || EFIDIR=/mnt/boot
mkdir -p ${EFIDIR}
echo -e "Mounting EFI partition..\n"
mount ${EFI} ${EFIDIR}

clear

echo -e "Updating Arch Linux Keyring..\n"
pacman -Sy --noconfirm archlinux-keyring
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

echo -e "Downloading necessary packages..\n"
pacstrap /mnt nano git base linux grub linux-firmware networkmanager dhcpcd ifplugd wpa_supplicant sudo efibootmgr os-prober net-tools sed openssh vim

echo -e "Generating fstab file..\n"
genfstab -U /mnt >> /mnt/etc/fstab

# Splitting install script to later use after chrooting and in post installation
sed -n '127,169p;170q' SAMI.sh  > /mnt/SAMI_PART2.sh
sed -n '170,217p;218q' SAMI.sh  > /mnt/SAMI_PART3.sh
cp login_details.txt /mnt/
chmod +x /mnt/SAMI_PART2.sh
chmod +x /mnt/SAMI_PART3.sh

arch-chroot /mnt ./SAMI_PART2.sh
exit

#PART2 - Post-Chroot

clear

systemctl enable NetworkManager

pacman -Sy --needed --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf

GRUBIOS=$(sed -n '6p' login_details.txt) && sed -i '6d' login_details.txt
BOOTMODE=$(sed -n '5p' login_details.txt) && sed -i '5d' login_details.txt
HOSTNAME=$(sed -n '4p' login_details.txt) && sed -i '4d' login_details.txt
USERNAME=$(sed -n '3p' login_details.txt) && sed -i '3d' login_details.txt

echo -e "Setting locale to en_US...\n"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo -e "Setting hostname...\n"
echo "${HOSTNAME}" >> /etc/hostname
echo "127.0.0.1  localhost" >> /etc/hosts
echo "::1  localhost" >> /etc/hosts
echo "127.0.1.1  ${HOSTNAME}.localdomain  ${HOSTNAME}" >> /etc/hosts

pacman -Sy --needed --noconfirm grub efibootmgr
echo -e "Configuring grub menu...\n"
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
[[ "${BOOTMODE}" == 'UEFI' ]] && grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCHMACHINE || grub-install ${GRUBIOS}
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "Adding user profile...\n"
useradd -m ${USERNAME}
sed -i "s/^GROUP=.*/GROUP=users/g" /etc/default/useradd
usermod -aG users ${USERNAME}
echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
chpasswd < login_details.txt && rm -rf login_details.txt

mv SAMI_PART3.sh /home/${USERNAME}/
chmod +x /home/${USERNAME}/SAMI_PART3.sh

printf "\e[1;32mArch Linux has been installed. Type reboot to reboot your system.\e[0m\nYou can check your login details by typing cat login_details.txt\n"
rm -rf SAMI_PART2.sh && exit

#PART3 - Ricing
sudo systemctl enable --now NetworkManager; sudo systemctl start --now NetworkManager
cd ~
nmtui

pacman -Sy --needed --noconfirm xorg xorg-server xorg-xinit xorg-xrdb nitrogen chromium neofetch python-pywal htop wget jq xdotool dunst base-devel pamixer maim xclip libnotify pulseaudio pulseaudio-alsa alsa-utils libpulse pavucontrol gvfs ntfs-3g openssh brightnessctl noto-fonts-cjk noto-fonts-emoji sxiv mtpfs curl mpv rclone redshift xf86-input-synaptics nemo zip unzip unrar p7zip ffmpeg imagemagick dosfstools arc-gtk-theme papirus-icon-theme aria2 mpd ncmpcpp rsync gvfs-mtp ranger ueberzug zsh neovim zathura-cb zathura-pdf-mupdf mpc jq yt-dlp rofi jgmenu

#Dotfiles
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/SamIsTheFBI/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles

#Window Manager - dwm
git clone https://github.com/SamIsTheFBI/dwm.git ~/.local/src/dwm
sudo make clean -C ~/.local/src/dwm install

#App Launcher - dmenu
git clone https://github.com/SamIsTheFBI/dmenu.git ~/.local/src/dmenu
sudo make clean -C ~/.local/src/dmenu install

#Status bar - dwmblocks-async
git clone https://github.com/SamIsTheFBI/dwmblocks-async.git ~/.local/src/dwmblocks-async
sudo make clean -C ~/.local/src/dwmblocks install

#Terminal emulator - st
git clone https://github.com/SamIsTheFBI/st.git ~/.local/src/st
sudo make clean -C ~/.local/src/st install

#AUR Helper - pikaur
git clone https://aur.archlinux.org/pikaur.git ~/.local/src/pikaur
cd ~/.local/src/pikaur
makepkg -si
cd ~
pikaur -S --noedit libxft-bgra jmtpfs nerd-fonts-jetbrains-mono i3lock-color mpd-mpris picom-animations-git

#touchpad config
sudo cp ~/.config/touchpad_config.txt /etc/X11/xorg.conf.d/70-synaptics.conf

ln -sf $HOME/.config/x11/xinitrc $HOME/.xinitrc
sudo timedatectl set-ntp true
sudo timedatectl set-timezone Asia/Calcutta
sudo timedatectl set-local-rtc 1 --adjust-system-clock

echo "You are somewhat done. Press startx to start DWM"
sleep 1

exit
# End of script
