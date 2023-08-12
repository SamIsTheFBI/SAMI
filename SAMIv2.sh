loadkeys us # or kblayout="$(localectl list-keymaps | fzf)"

TTY_NORMAL="\e[0m"
TTY_SCRIPT="\e[30;48;5;6m \e[0m"
TTY_USER="\e[30;48;5;5m \e[0m"
TTY_NOTE="\e[30;48;5;2m \e[0m"
TTY_INVERT="\e[7m"

echo -e "${TTY_SCRIPT} Hello there! I will guide you in your Arch Linux installation!\n"

echo -e "${TTY_SCRIPT} Firstly, tell me which drive to use?"
echo -e "${TTY_NOTE} It should be something like sda, sdb... or nvme0n1, nvme0n2... ${TTY_NORMAL}\n"
lsblk

echo -e "\n${TTY_USER} Your answer:"
read drive

echo -e "\n${TTY_SCRIPT} In the next screen, note down which partitions you want to use as the following\n\
${TTY_SCRIPT}${TTY_INVERT} EFI ${TTY_NORMAL} \n\
${TTY_SCRIPT}${TTY_INVERT} File System ${TTY_NORMAL} Where your /home and everything is gonna stay \n\
${TTY_SCRIPT}${TTY_INVERT} swap ${TTY_NORMAL} This is where your programs go when they can't fit in RAM.\n\n\
These will be required and you have to be careful with the paths/device. Opening in 9s..."

sleep 9
cfdisk /dev/$drive

echo -e "\n${TTY_SCRIPT} Which partition to format for Linux Filesystem?"
echo -e "${TTY_USER} Your answer:"
read linuxfs
echo -e "\n${TTY_SCRIPT} Formatting to ext4 format..."
mkfs.ext4 $linuxfs
echo -e "${TTY_SCRIPT} DONE!"

echo -e "\n${TTY_SCRIPT} Which partition for swap?"
echo -e "${TTY_USER} Your answer:"
read swap
echo -e "\n${TTY_SCRIPT} Making swap space.."
mkswap $swap
swapon $swap
echo -e "${TTY_SCRIPT} DONE!"

echo -e "\n${TTY_SCRIPT} Which partition for EFI?"
echo -e "${TTY_USER} Your answer:"
read efi

echo -e "\n${TTY_SCRIPT} Is this labeled as an EFI System partition? [YES/NO]"
echo -e "${TTY_NOTE} It is usually labeled in case an OS is already present."
read ans
[[ ${ans} == NO ]] && echo -e "\n${TTY_SCRIPT} Making swap space.." && mkfs.vfat $efi && echo -e "${TTY_SCRIPT} DONE!" 

mount $linuxfs /mnt
echo -e "\n${TTY_SCRIPT} Mounted file system to /mnt ..."

mkdir -p /mnt/boot/efi
mount $efi /mnt/boot/efi
echo -e "${TTY_SCRIPT} Mounted EFI to /mnt/boot/efi ..."

pacman -Sy --noconfirm archlinux-keyring sed

echo -e "\n${TTY_SCRIPT} Preparing pacman to install packages..."
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf


echo -e "${TTY_SCRIPT} Fetching base packages..."
pacstrap /mnt base base-devel linux linux-firmware networkmanager sudo grub efibootmgr os-prober sed fzf ntfs-3g wpa_supplicant wget
echo -e "${TTY_SCRIPT} DONE!"

echo -e "${TTY_SCRIPT} Generating fstab..."
genfstab -U /mnt > /mnt/etc/fstab
echo -e "${TTY_SCRIPT} DONE!"

sed -n '79,132p' ./SAMIv2.sh  >> /mnt/SAMI_PART2.sh
sed -n '133,$p' ./SAMIv2.sh  >> /mnt/SAMI_PART3.sh
chmod +x /mnt/SAMI_PART2.sh && chmod +x /mnt/SAMI_PART3.sh
arch-chroot /mnt ./SAMI_PART2.sh
rm -rf /mnt/SAMI_PART2.sh
exit

#Part 2

TTY_NORMAL="\e[0m"
TTY_SCRIPT="\e[30;48;5;6m \e[0m"
TTY_USER="\e[30;48;5;5m \e[0m"
TTY_NOTE="\e[30;48;5;2m \e[0m"
TTY_INVERT="\e[7m"

sudo systemctl enable NetworkManager
echo -e "\n${TTY_SCRIPT} Yay! You're on the second phase of installing Arch Linux. How great is that?"
echo -e "${TTY_SCRIPT} Now we'll be setting up your timezone, username, password and root password" && sleep 3s

echo -e "\n${TTY_SCRIPT} Enter password for root user:"
passwd

echo -e "\n${TTY_SCRIPT} Enter your desired username: (no spaces please!)"
echo -e "${TTY_USER} Your answer:"
read USERNAME
useradd -m $USERNAME

echo -e "\n${TTY_SCRIPT} Enter password for the current user ${USERNAME}:"
passwd $USERNAME

echo -e "${TTY_SCRIPT} Adding ${USERNAME} & creating /home/${USERNAME}..."
sed -i "s/^GROUP=.*/GROUP=users/g" /etc/default/useradd
usermod -aG users ${USERNAME}
echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
echo -e "${TTY_SCRIPT} DONE!"

echo -e "\n${TTY_SCRIPT} Setting up locale settings to en_US..."
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo -e "${TTY_SCRIPT} DONE!"

echo -e "\n${TTY_SCRIPT} Setting up hostname..."
echo -e "${TTY_SCRIPT} Choose a name for your device."
read HOSTNAME
echo "${HOSTNAME}" >> /etc/hostname
echo "127.0.0.1  localhost" >> /etc/hosts
echo "::1  localhost" >> /etc/hosts
echo "127.0.1.1  ${HOSTNAME}.localdomain  ${HOSTNAME}" >> /etc/hosts
echo -e "${TTY_SCRIPT} DONE!"

echo -e "${TTY_SCRIPT} Preparing grub for installation..."
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "${TTY_SCRIPT} DONE!"
mv SAMI_PART3.sh /home/$USERNAME
echo -e "\n${TTY_SCRIPT} Finally you have installed Arch Linux on your PC!"
echo -e "${TTY_SCRIPT} What's left now is to customize it to suit your needs."
echo -e "${TTY_SCRIPT} Shutdown, remove the Arch installation medium, boot into ArchLinux through the Grub bootloader menu and rice your system!" && umount -R /mnt

#PART3 - Ricing

sudo systemctl enable --now NetworkManager
sudo systemctl enable --now wpa_supplicant

sudo sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/g" /etc/pacman.conf
sudo pacman -Sy --noconfirm --needed archlinux-keyring
sudo pacman -Sy --noconfirm --needed xorg xorg-server xorg-xinit nitrogen neofetch python-pywal htop wget jq xdotool dunst base-devel pamixer maim xclip libnotify pulseaudio-alsa alsa-utils libpulse pavucontrol gvfs ntfs-3g openssh brightnessctl noto-fonts-cjk noto-fonts-emoji noto-fonts ttf-jetbrains-mono-nerd sxiv mtpfs curl mpv rclone redshift xf86-input-synaptics nemo zip unzip unrar p7zip ffmpeg imagemagick dosfstools slock arc-gtk-theme papirus-icon-theme aria2 mpd ncmpcpp gvfs-mtp ranger ueberzug zsh zathura-cb zathura-pdf-mupdf mpc yt-dlp pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-docs wireplumber arandr bluez blueman bluez-libs bluez-utils gpick harfbuzz gd neovim slim samba screenkey git copyq redshift jgmenu base-devel grep gawk playerctl exa rofi

# build dwm
git clone https://github.com/samisthefbi/dwm .local/src/dwm
sudo make -C $HOME/.local/src/dwm install && sudo rm -rf $HOME/.local/src/dwm/config.h

# build dmenu
git clone https://github.com/samisthefbi/dmenu .local/src/dmenu
sudo make -C $HOME/.local/src/dmenu install && sudo rm -rf $HOME/.local/src/dmenu/config.h

# build st
git clone https://github.com/samisthefbi/st .local/src/st
sudo make -C $HOME/.local/src/st install && sudo rm -rf $HOME/.local/src/st/config.h

# build dwmblocks-async
git clone https://github.com/samisthefbi/dwmblocks-async .local/src/dwmblocks-async
sudo make -C $HOME/.local/src/dwmblocks-async install

# Yay AUR helper
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si && cd .. && rm -r yay-bin

# AUR packages
yay -S picom-animations-git libxft-bgra mpd-mpris wsdd2 i3lock-color

sudo cp ~/.config/touchpad_config.txt /etc/X11/xorg.conf.d/70-synaptics.conf

sudo systemctl enable slim
sudo systemctl enable bluetooth
sudo systemctl enable smb
sudo systemctl enable wsdd2
systemctl enable --user mpd
systemctl enable --user mpd-mpris

sudo pacman -Sy --needed --noconfirm tzdata
TIMEZONE="$(tzselect)"
sudo timedatectl set-timezone ${TIMEZONE}

sed -n '183,$p' ./SAMI_PART3.sh  >> ./SAMI_PART4.sh
# zsh4humans
wget --timeout=5 https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install && sh install && sh ./SAMI_PART4.sh

# Migrate dotfiles
cd $HOME
git clone --bare https://github.com/samisthefbi/dotfiles $HOME/.dotfiles

function dots {
	git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME} $@
}

dots checkout
if [ $? == 0 ]; then
	echo "All is good"
else
	echo "Backing up conflicting pre-existing files to ~/dots-backup ..."
	mkdir -p $HOME/dots-backup
	dots checkout 2>&1 | grep -E "\s+\." | awk -F '\t' {'print $2'} | xargs -I{} echo {} | awk -F '/' 'BEGIN{OFS="/"}; {NF--}; {print $0}' | xargs -I{} mkdir -p ${HOME}/dots-backup/{}
	dots checkout 2>&1 | grep -E "\s+\." | awk -F '\t' {'print $2'} | xargs -I{} mv {} $HOME/dots-backup/{}
fi
dots checkout
dots config status.showUntrackedFiles no

echo -e "${TTY_SCRIPT} Are you trying to dual boot with a Windows OS? [YES/NO]"
read ans
if [[ ${ans} == YES ]]; then
	echo -e "${TTY_NOTE} You need to mount any one Windows partition first to be able to detect it."
	echo -e "${TTY_NOTE} Running cfdisk in 5s, please note the path to any one Windows partition."
	echo -e "${TTY_NOTE} It should be something like /dev/sda1, /dev/sda2... ${TTY_NORMAL}"
	echo -e "${TTY_NOTE} or /dev/nvme0n1p1, /dev/nvme0n1p2... ${TTY_NORMAL}" 
	sleep 5s
	sudo cfdisk

	echo -e "\n${TTY_USER} Your answer:"
	read WIN_PART
	mkdir -p ${HOME}/Windows
	sudo ntfs-3g ${WIN_PART} ${HOME}/Windows &
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
