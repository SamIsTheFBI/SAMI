#!/bin/sh

clear

#PART1
clear
echo "Welcome to Sam's Arch Machine Installer Script"
loadkeys us

echo "Create your user profile: "
echo "Set username: "
read username
echo "Set password for $username: "
read -s password
echo "Set root password: "
read -s rootpassword
echo $username:$password >> login_details.txt
echo root:$rootpassword >> login_details.txt
echo $username >> login_details.txt

echo "In the next screen, note down which partitions you want to use as EFI, filesystem and swap. These will be required and you better not mess with the paths/device. Opening in 9s..."
sleep 9
cfdisk $drive
echo "Which partition to format for Linux Filesystem? [/dev/sda1|sda2|...|sdb1|sdb2|...]"
read linuxfs
mkfs.ext4 $linuxfs
echo "Make swap partition? [y/n]"
read ans
if [[ $ans == y ]]; then
 echo "Which partition for swap?"
 read swap
 mkswap $swap
 swapon $swap
fi
lsblk
echo "Which partition for EFI?"
read efi
echo "Is it labeled as an EFI System partition (usually labeled in case an OS is already present)? [yes/no]"
read ans
if [[ $ans == no ]]; then
 mkfs -vfat $efi
fi

mount $linuxfs /mnt
mkdir -p /mnt/boot/efi
mount $efi /mnt/boot/efi

pacman -Sy --noconfirm archlinux-keyring
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf
pacstrap /mnt nano git base linux linux-firmware networkmanager dhcpcd ifplugd wpa_supplicant iwd netctl sudo grub efibootmgr os-prober

genfstab -U /mnt >> /mnt/etc/fstab

sed -n '64,102p;103q' SAMI.sh  > /mnt/SAMI_PART2.sh
sed -n '103,146p;147q' SAMI.sh  > /mnt/SAMI_PART3.sh
mv login_details.txt /mnt/
chmod +x /mnt/SAMI_PART2.sh
chmod +x /mnt/SAMI_PART3.sh

arch-chroot /mnt ./SAMI_PART2.sh
exit


#PART2

clear

systemctl enable NetworkManager

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "arch" >> /etc/hostname

echo "127.0.0.1  localhost" >> /etc/hosts
echo "::1  localhost" >> /etc/hosts
echo "127.0.1.1  arch.localdomain  arch" >> /etc/hosts

echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCHMACHINE
grub-mkconfig -o /boot/grub/grub.cfg
sleep 5
pacman -Sy --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf
pacman -Sy --needed --noconfirm xorg xorg-server xorg-xinit xorg-xrdb nitrogen chromium neofetch python-pywal htop wget jq paplay xdotool dunst base-devel pamixer maim xclip libnotify pulseaudio pulseaudio-alsa alsa-utils libpulse pavucontrol gvfs ntfs-3g openssh brightnessctl noto-fonts-cjk noto-fonts-emoji sxiv mtpfs curl mpv rclone redshift xf86-input-synaptics nemo zip unzip unrar p7zip ffmpeg imagemagick dosfstools arc-gtk-theme papirus-icon-theme aria2 mpd ncmpcpp rsync gvfs-mtp ranger ueberzug zsh nvim zathura-cb zathura-pdf-mupdf mpc jq yt-dlp rofi jgmenu

systemctl enable NetworkManager

username=$(sed -n '3p' login_details.txt) && sed -i '3d' login_details.txt
useradd -m $username
sed -i "s/^GROUP=.*/GROUP=users/g" /etc/default/useradd
usermod -aG users $username
echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username
chpasswd < login_details.txt && rm -rf login_details.txt

mv SAMI_PART3.sh /home/$username/
chmod +x /home/$username/SAMI_PART3.sh

echo "Arch Linux has been installed in to your system. Type reboot to reboot your system"
exit

#PART3

clear
cd ~
mkdir -p Applications Documents Downloads Cloud\ Storage/Hikari\ Drive Pictures Wallpapers Videos Screenshots Scripts Local\ Disk\ C Local\ Disk\ D Local\ Disk\ E
nmtui
sudo rm -rf /SAMI_PART2.sh /login_details.txt
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
