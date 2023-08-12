# SAMI - SamIsTheFBI's Arch Machine Installer script

![Screenshot](https://user-images.githubusercontent.com/70562711/173168308-aa33e90d-bf1a-4031-b462-553ca70d3d10.png)

This is a script to automate the installation process of my minimal Arch setup. Calling it minimal because my laptop has poor hardware specifications (lower than potato PCs & probably higher than minimalist GNU/Linux users). The script is heavily inspired by [Bugswriter's Arch install script](https://github.com/Bugswriter/arch-linux-magic). I omitted a lot of commands which I didn't think were necessary. Just like his script, this one divides itself into 3 parts:

- Part 1: The first part is for formatting & mounting of partitions, and continues to install base packages, divide the script into 2 more parts, chroot into the new system, and run Part 2 of the script.

- Part 2: This second part sets username, password, locale, hostname, and configures grub along with ***my desired user permissions***.

- Part 3: This part prepares to set up my "work environment" by cloning my dotfiles, and other required repositories. Then, it installs a lot of programs using `pacman` (the package manager in Arch distributions). It also uses `yay` (an AUR helper) to further install a few more packages from the AUR. Then, it configures the touchpad to use the older synaptics driver for the circular scroll feature that I absolutely love, set date & time, start some Systemd services, and start zsh4humans script to set up the shell.

- Part 4: The zsh4humans quits the running script so have to have a Part 4. This final script makes sure my dotfiles are correctly migrated. Makes a backup if found conflicting files. Also, this part runs the grub configuration again in case you want to dual boot with Windows on your device.

## Instructions

- Get the latest [Arch ISO](https://archlinux.org/download/) and burn it to a flash drive by using Rufus, Etcher or any other tool you prefer.
- Boot into that flash drive.
- Upon reaching the initial prompt, [connect to internet](https://wiki.archlinux.org/title/installation_guide#Connect_to_the_internet).
- Type the following:

```
pacman -Sy git
git clone https://github.com/SamIsTheFBI/SAMI
cd SAMI
chmod +x SAMIv2.sh
./SAMIv2.sh
```

## Troubleshooting

Check [Arch Linux Wiki Installation Guide](https://wiki.archlinux.org/title/installation_guide) because I think it's important for anyone using Arch to be familiar with Arch Wiki. 

## Who should use this script?

ME.

Or if you are someone who is trying out others' Arch setups. Or if you're making an Arch installer script for your own rice & would actually tinker around with the script. Or if Arch Wiki is daunting to look at but you are eager to install Arch manually.

This script is NOT for someone who wants to create their own Arch setup with ease because what you're actually looking for then is something like [archinstall](https://man.archlinux.org/man/extra/archinstall/archinstall.1.en) or [Archfi](https://github.com/MatMoul/archfi). Unless you're happy with what they install for you, you should install Arch the traditional way.

## Why write all this?

Because I was bored. But I guess now I just want to write proper documentation. Of course, there will be more updates to this and other repositories.

## Wallpaper Credits

[Link to the wallpaper in the screenshot above.](https://nordthemewallpapers.com/Backgrounds/16-9/All/img/3mcg97oyotu61.jpg)
