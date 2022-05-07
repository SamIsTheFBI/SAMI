# SAMI - SamIsTheFBI's Arch Machine Installer script

![Screenshot](https://github.com/SamIsTheFBI/SAMI/blob/screenshots/Screenshot_20220508_021833.png)

This is a script to automate the installation process of my minimal Arch setup. Calling it minimal because my laptop has poor hardware specifications (lower than potato PCs & probably higher than minimalist GNU/Linux users). The script is heavily inspired by [Bugswriter's Arch install script](https://github.com/Bugswriter/arch-linux-magic). I omitted a lot of commands which I didn't think were necessary. Just like his script, this one divides itself into 3 parts:

- Part 1: The first part prompts the user for username & password, formatting & mounting of partitions, and continues to install base packages, divide the script into 2 more parts, chroot into the new system and run Part 2 of the script.

- Part 2: This second part sets locale, hostname, and installs a bunch of packages that I use. After it's done installing specified packages, it adds the user and sets up username & password, move Part 3 of the script to the new home directory and asks user to reboot the device.

- Part 3: The final part sets up my "work environment" by cloning my dotfiles, dwm, slstatus, dmenu and st repositories. Then, it installs pikaur (an AUR helper) to further install a few more packages. Then, it configures the touchpad, set date & time and start zsh4humans script to set up the shell.

## Instructions

- Get the latest [Arch ISO](https://archlinux.org/download/) and burn it to a flash drive by using Rufus, Etcher or any other tool you prefer.
- Boot into that flash drive.
- Upon reaching the initial prompt, [connect to internet](https://wiki.archlinux.org/title/installation_guide#Connect_to_the_internet).
- Type the following:

```
pacman -Sy git
git clone https://github.com/SamIsTheFBI/SAMI
cd SAMI
chmod +x SAMI.sh
./SAMI.sh
```
- When asked for rebooting, type reboot and you can pull out your flash drive now.
- Boot into your new Arch system and after logging in, run the third part of the script with `./SAMI_PART3.sh`.
- Upon completing zsh configuration, DWM will start. If not, you must have selected yes in the login shell prompt during the zsh config & so you will have to type `startx` to start DWM.

## Troubleshooting

Check [Arch Linux Wiki Installation Guide](https://wiki.archlinux.org/title/installation_guide) because I think it's important for anyone using Arch to be familiar with Arch Wiki. And then there's [this guide](https://telegra.ph/Installing-Arch-Linux-03-24) I made on my first successful Arch install. It's newb friendly because it was written by a newb. 

## Who should use this script?

ME.

Or if you are someone who is distro-hopping and wants a different kind of "distro". Or if you're making an Arch installer script for your own rice & would actually tinker around with the script. Or if Arch wiki is daunting to look at but you are eager to install Arch manually.

This script is NOT for someone who wants to create their own Arch setup with ease because what you're actually looking for then is something like [ArchTitus](https://github.com/ChrisTitusTech/ArchTitus) or [Archfi](https://github.com/MatMoul/archfi). In my opinion no one should be making a permanent Arch setup with someone else's installer scripts, unless you're somehow happy with what they install for you.

## Why write all this?

Because I was bored. But I guess now I just want to write proper documentations. Of course there will be more updates to this and other repositories.

## Wallpaper Credits

The picture of the dahlia flower I use as wallpaper can be found in [Pexels](https://www.pexels.com/photo/red-dahlia-flower-60597).
