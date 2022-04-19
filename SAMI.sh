#!/bin/sh

clear

#PART1
clear
echo "Welcome to Sam's Arch Machine Installer Script"
loadkeys us

timedatectl set-ntp true
timedatectl set-timezone Asia/Calcutta
lsblk
echo "Which drive to use?"
read drive
echo "In the next screen, note down which partitions you want to use as EFI, filesystem and swap. These will be required and you better not mess with the paths/device. Opening in 9s..."
sleep 1
cfdisk $drive
echo "Which partition to format for Linux Filesystem?"
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
echo "Is this labeled as an EFI System partition (usually labeled in case an OS is already present)? [yes/no]"
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

sed -n '58,99p;100q' SAMI.sh  > /mnt/SAMI_PART2.sh
sed -n '100,149p;150q' SAMI.sh  > /mnt/SAMI_PART3.sh

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
pacman -Sy --noconfirm xorg xorg-server xorg-xinit nitrogen picom chromium neofetch python-pywal htop wget jq xdotool dunst base-devel pamixer maim xclip libnotify pulseaudio pulseaudio-alsa alsa-utils libpulse pavucontrol gvfs ntfs-3g openssh brightnessctl noto-fonts-cjk noto-fonts-emoji noto-fonts sxiv mtpfs ttf-nerd-fonts-symbols curl mpv rclone redshift xf86-input-synaptics pcmanfm zip unzip unrar p7zip ffmpeg imagemagick dosfstools slock arc-gtk-theme papirus-icon-theme aria2 mpd ncmpcpp rsync gvfs-mtp ranger ueberzug zsh vim zathura-cb zathura-pdf-mupdf mpc jq yt-dlp notepadqq

systemctl enable NetworkManager

echo "Enter username: "
read username
useradd -m $username
passwd $username
sed -i "s/^GROUP=.*/GROUP=users/g" /etc/default/useradd
usermod -aG users $username
echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username
echo "Make the root password:"
passwd

mv SAMI_PART3.sh /home/$username/
chmod +x /home/$username/SAMI_PART3.sh

echo "Arch Linux has been installed in to your system. Type reboot to reboot your system"
exit

#PART3

clear
cd $HOME
mkdir -p Applications Documents Downloads Cloud\ Storage/Hikari\ Drive Pictures Wallpapers Videos Screenshots Scripts Local\ Disk\ C Local\ Disk\ D Local\ Disk\ E
nmtui

#Dotfiles
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/SamIsTheFBI/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles

#Window Manager - dwm
git clone https://github.com/SamIsTheFBI/dwm.git $HOME/.local/src/dwm
sudo make clean -C $HOME/.local/src/dwm install

#App Launcher - dmenu
git clone https://github.com/SamIsTheFBI/dmenu.git $HOME/.local/src/dmenu
sudo make clean -C $HOME/.local/src/dmenu install

#Status bar - slstatus
git clone https://github.com/SamIsTheFBI/slstatus.git $HOME/.local/src/slstatus
sudo make clean -C $HOME/.local/src/slstatus install

#Terminal emulator - st
git clone https://github.com/SamIsTheFBI/st.git $HOME/.local/src/st
sudo make clean -C $HOME/.local/src/st install

#Getting paru (AUR Helper)
git clone https://aur.archlinux.org/paru.git $HOME/.local/src/paru
cd $HOME/.local/src/paru
makepkg -si
cd $HOME
paru -S --skipreview libxft-bgra-git jmtpfs nerd-fonts-jetbrains-mono i3lock-color

#zsh config
sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
sudo ln -sf $HOME/.config/zsh/zshrc $HOME/.zshrc

#touchpad config
sudo mv $HOME/.config/touchpad_config.txt /etc/X11/xorg.conf.d/70-synaptics.conf
rm -rf $HOME/.config/touchpad_config.txt

sudo ln -sf $HOME/.config/x11/xinitrc $HOME/.xinitrc
sudo timedatectl set-ntp true
sudo timedatectl set-timezone Asia/Calcutta
echo "You are somewhat done. DWM should start in a second."
sleep 1
startx
exit
#End of File
