#!/bin/sh

clear

#PART1
clear
echo "Welcome to Sam's Arch Machine Installer Script"
loadkeys us

echo "Create user profile: "
echo "Set username: "
read username
echo "Set password for $username: "
read password
echo "Set root password: "
read rootpassword
echo $username:$password >> login_details.txt
echo root:$rootpassword >> login_details.txt
echo $username >> login_details.txt

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

sed -n '67,105p;106q' SAMI.sh  > /mnt/SAMI_PART2.sh
sed -n '106,156p;157q' SAMI.sh  > /mnt/SAMI_PART3.sh
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
pacman -Sy --noconfirm xorg xorg-server xorg-xinit nitrogen picom chromium neofetch python-pywal htop wget jq xdotool dunst base-devel pamixer maim xclip libnotify pulseaudio pulseaudio-alsa alsa-utils libpulse pavucontrol gvfs ntfs-3g openssh brightnessctl noto-fonts-cjk noto-fonts-emoji noto-fonts sxiv mtpfs curl mpv rclone redshift xf86-input-synaptics pcmanfm zip unzip unrar p7zip ffmpeg imagemagick dosfstools slock arc-gtk-theme papirus-icon-theme aria2 mpd ncmpcpp rsync gvfs-mtp ranger ueberzug zsh vim zathura-cb zathura-pdf-mupdf mpc jq yt-dlp notepadqq telegram-desktop

systemctl enable NetworkManager

username=$(sed -n '3p' login_details.txt) && sed -i '3d' login_details.txt
useradd -m $username
sed -i "s/^GROUP=.*/GROUP=users/g" /etc/default/useradd
usermod -aG users $username
echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username
chpasswd < login_details.txt && rm login_details.txt

mv SAMI_PART3.sh /home/$username/
chmod +x /home/$username/SAMI_PART3.sh

echo "Arch Linux has been installed in to your system. Type reboot to reboot your system"
exit

#PART3

clear
cd ~
mkdir -p Applications Documents Downloads Cloud\ Storage/Hikari\ Drive Pictures Wallpapers Videos Screenshots Scripts Local\ Disk\ C Local\ Disk\ D Local\ Disk\ E
nmtui

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

#Status bar - slstatus
git clone https://github.com/SamIsTheFBI/slstatus.git ~/.local/src/slstatus
sudo make clean -C ~/.local/src/slstatus install

#Terminal emulator - st
git clone https://github.com/SamIsTheFBI/st.git ~/.local/src/st
sudo make clean -C ~/.local/src/st install

#AUR Helper - pikaur
git clone https://aur.archlinux.org/pikaur.git ~/.local/src/pikaur
cd ~/.local/src/pikaur
makepkg -si
cd ~
pikaur -S --noedit libxft-bgra-git jmtpfs nerd-fonts-jetbrains-mono i3lock-color

#touchpad config
sudo cp ~/.config/touchpad_config.txt /etc/X11/xorg.conf.d/70-synaptics.conf


ln -sf $HOME/.config/x11/xinitrc $HOME/.xinitrc
sudo timedatectl set-ntp true
sudo timedatectl set-timezone Asia/Calcutta

#zsh config
sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)" && ln -sf $HOME/.config/zsh/zshrc $HOME/.zshrc


echo "You are somewhat done. Type startx and press enter"
sleep 1
startx
exit

#End of File
