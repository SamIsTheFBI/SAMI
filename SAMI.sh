#!/bin/sh

[ -z "$(ls /sys/firmware/efi/efivars)" ] && echo -e "This script works only if you boot in UEFI mode!" && exit

#PART1 - Base Install
clear
loadkeys us
echo -e "Welcome to Sam's Arch Machine Installer Script\n\n"
echo -e "Create your user profile: "
echo -e "Username:\n> "
read username
echo -e "Password for $username:\n> "
read password
echo -e "Set root password:\n> "
read rootpassword
echo $username:$password >> login_details.txt
echo root:$rootpassword >> login_details.txt
echo $username >> login_details.txt
echo -e "Set a hostname:\n> "
read hostname
echo $hostname >> login_details.txt
clear

echo -e "cfdisk will launch now. There, set up partitions."
echo -e "Swap Partition: >=2GB\nEFI Partition: >=256MB\nLinux Filesystem: Rest of the space"
echo -e "The paths for these partitions will be required in further steps\n\n"
echo "Launching cfdisk in 5s..\n"
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

echo -e "Make Swap?\n[y/Yes/YES/n/No/NO]\n> "
read ANS
case "${ANS}" in
  y|yes|YES|Yes)
    for ((i = 0; i < 1; )); do
      clear && lsblk -lp
      echo -e "Which partition for swap?\n[/dev/sda1|sda2|...|sdb1|sdb2|...]\n> "
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

echo -e "Create & format EFI partition? Enter 'No' if an EFI partition was already present before this installation and you want to dual boot\n[y/Yes/YES/n/No/NO]\n> "
read ANS
case "${ANS}" in
  y|yes|YES|Yes)
    for ((i = 0; i < 1; )); do
      clear && lsblk -lp
      echo -e "Path to EFI partition:\n[/dev/sda1|sda2|...|sdb1|sdb2|...]\n> "
      read EFI
      [ ! -e ${EFI} ] && echo -e "Given location does not exist!" || i=2
    done
    echo -e "Formatting EFI partition..\n"
    mkfs.fat -F32 ${EFI}
    mkdir -p /mnt/boot/efi
    echo -e "Mounting EFI partition..\n"
    mount ${EFI} /mnt/boot/efi
    ;;
  n|no|NO|No)
    echo -e "EFI partition will not be formatted.\n"
    ;;
  *) 
    echo -e "Invalid option. Exiting..\n"
    ;;
esac

clear

echo -e "Updating Arch Linux Keyring..\n"
pacman -Sy --noconfirm archlinux-keyring
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf

echo -e "Downloading necessary packages..\n"
pacstrap /mnt nano git base linux linux-firmware networkmanager dhcpcd ifplugd wpa_supplicant iwd netctl sudo grub efibootmgr os-prober sed 

echo -e "Generating fstab file..\n"
genfstab -U /mnt >> /mnt/etc/fstab

# Splitting install script to later use after chrooting and in post installation
sed -n '111,150p;151q' SAMI.sh  > /mnt/SAMI_PART2.sh
sed -n '151,196p;197q' SAMI.sh  > /mnt/SAMI_PART3.sh
mv login_details.txt /mnt/
chmod +x /mnt/SAMI_PART2.sh
chmod +x /mnt/SAMI_PART3.sh

arch-chroot /mnt ./SAMI_PART2.sh
exit

#PART2 - Post-Chroot

clear

systemctl enable NetworkManager

pacman -Sy --needed --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf

hostname=$(sed -n '4p' login_details.txt) && sed -i '4d' login_details.txt
username=$(sed -n '3p' login_details.txt) && sed -i '3d' login_details.txt

echo -e "Setting locale to en_US...\n"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo -e "Setting hostname...\n"
echo "$hostname" >> /etc/hostname
echo "127.0.0.1  localhost" >> /etc/hosts
echo "::1  localhost" >> /etc/hosts
echo "127.0.1.1  $hostname.localdomain  $hostname" >> /etc/hosts

echo -e "Configuring grub menu...\n"
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCHMACHINE
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "Adding user profile...\n"
useradd -m $username
sed -i "s/^GROUP=.*/GROUP=users/g" /etc/default/useradd
usermod -aG users $username
echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username
chpasswd < login_details.txt

mv SAMI_PART3.sh /home/$username/
chmod +x /home/$username/SAMI_PART3.sh

printf "\e[1;32mArch Linux has been installed. Type reboot to reboot your system.\e[0m"
exit

#PART3 - Ricing

cd ~
nmtui

sudo rm -rf /SAMI_PART2.sh /login_details.txt
pacman -Sy --needed --noconfirm xorg xorg-server xorg-xinit xorg-xrdb nitrogen chromium neofetch python-pywal htop wget jq xdotool dunst base-devel pamixer maim xclip libnotify pulseaudio pulseaudio-alsa alsa-utils libpulse pavucontrol gvfs ntfs-3g openssh brightnessctl noto-fonts-cjk noto-fonts-emoji sxiv mtpfs curl mpv rclone redshift xf86-input-synaptics nemo zip unzip unrar p7zip ffmpeg imagemagick dosfstools arc-gtk-theme papirus-icon-theme aria2 mpd ncmpcpp rsync gvfs-mtp ranger ueberzug zsh neovim zathura-cb zathura-pdf-mupdf mpc jq yt-dlp rofi jgmenu

#Dotfiles
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/SamIsTheFBI/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles

#Window Manager - dwm
sudo make clean -C ~/.local/src/dwm install

#App Launcher - dmenu
sudo make clean -C ~/.local/src/dmenu install

#Status bar - dwmblocks-async
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
