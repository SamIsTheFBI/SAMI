#!/bin/sh

clear

#PART1

echo "Welcome to Sam's Arch Machine Installer Script"
loadkeys us

timedatectl set-ntp true
timedatectl set-timezone Asia/Calcutta
lsblk
echo "Which drive to use?"
read drive
echo "In the next screen, note down which partitions you want to use as EFI, filesystem and swap. These will be required and you better not mess with the paths/device. Opening in 9s..."
sleep 9
cfdisk $drive
echo "Which partition to format for Linux Filesystem?"
read linuxfs
mkfs.ext4 $linuxfs
echo "Make swap partition? [y/n]"
read ans
if [ "$ans" == 'y' ]; then
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
if [ "$ans" == 'no' ]; then
	mkfs -vfat $efi
fi

mount $linuxfs /mnt
mkdir -p /mnt/boot/efi
mount $efi /mnt/boot/efi

pacman -Sy --noconfirm archlinux-keyring
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf
pacstrap /mnt nano git base linux linux-firmware networkmanager dhcpcd ifplugd wpa_supplicant iwd netctl sudo

genfstab -U /mnt >> /mnt/etc/fstab

sed -n '54,96p;97q' SAMIS.sh  > /mnt/SAMIS_PART2.sh
chmod +x /mnt/SAMIS_PART2.sh

arch-chroot /mnt ./SAMIS_PART2.sh
exit


#PART2

clear

systemctl enable NetworkManager

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "arch" >> /etc/hostname

echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		arch.localdomain  arch" >> /etc/hosts

echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCHMACHINE
grub-mkconfig -o /boot/grub/grub.cfg
sleep 5
pacman -Sy --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf
pacman -Sy --noconfirm xorg xorg-server xorg-xinit nitrogen picom chromium neofetch python-pywal htop wget jq xdotool dunst base-devel pamixer maim xclip libnotify pulseaudio pulseaudio-alsa alsa-utils libpulse pavucontrol gvfs ntfs-3g openssh brightnessctl noto-fonts-cjk noto-fonts-emoji noto-fonts sxiv mtpfs ttf-nerd-fonts-symbols curl mpv rclone redshift xf86-input-synaptics pcmanfm zip unzip unrar p7zip ffmpeg imagemagick dosfstools slock arc-gtk-theme papirus-icon-theme aria2 mpd ncmpcpp xdg-user-dirs rsync gvfs-mtp ranger ueberzug

systemctl enable NetworkManager

echo "Enter username: "
read username
useradd -m $username
sed -i "s/^GROUP=.*/GROUP=users/g" /etc/default/useradd
usermod -aG users $username
echo "username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username
echo "Make the root password:"
passwd

ai3_path=/home/$username/SAMIS_PART3.sh
sed -n '97,139p;140q' SAMIS_PART2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path

echo "Arch Linux has been installed in to your system. Type reboot to reboot your system"


#PART3

clear
cd $HOME

git clone --separate-git-dir=$HOME/.dotfiles https://github.com/samistheretard/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
git clone https://github.com/SamIsTheRetard/dwm.git ~/.local/src/dwm
sudo make clean -C ~/.local/src/dwm install
git clone https://github.com/SamIsTheRetard/dmenu.git ~/.local/src/dmenu
sudo make clean -C ~/.local/src/dmenu install
git clone https://github.com/SamIsTheRetard/slstatus.git ~/.local/src/slstatus
sudo make clean -C ~/.local/src/slstatus install
git clone https://github.com/SamIsTheRetard/st.git ~/.local/src/st
sudo make clean -C ~/.local/src/st install

git clone https://aur.archlinux.org/paru.git ~/.local/src/paru
cd ~/.local/src/paru
makepkg -si
cd ..
paru -S libxft-bgra-git jmtpfs nerd-fonts-jetbrains-mono

ln -s ~/.config/x11/xinitrc .xinitrc
echo "What do you want to use for setting up zsh? zsh4human[1] Oh-My-ZSH[2]
read ans
if [ "$ans" == '1' ]; then
	if command -v curl >/dev/null 2>&1; then
	  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
	else
	  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
	fi
	echo "alias dotfiles='/usr/sbin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> .zshrc
	echo "path+=(/home/samisthefbi/.local/bin)" >> .zshrc
	echo "export PATH" >> .zshrc
elif
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
alias tmpdots='/usr/sbin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
tmpdots config --local status.showUntrackedFiles no

echo "You are somewhat done. Restart X & hope for the best!"

exit

#End of file
