# SAMI - SamIsTheFBI's Arch Machine Installer script

![neofetch ig. The RAM usage is high because of 8 different tabs in Chromium](https://telegra.ph/file/9dbe74f9c6a5cbfde2a16.png)

This script installs my somewhat minimal Arch setup. Emphasis on "somewhat minimal" because my laptop has poor hardware specifications (lower than potato PCs & probably higher than minimalist GNU/Linux users).  The script is heavily inspired by [Bugswriter's Arch install script](https://github.com/Bugswriter/arch-linux-magic) and I omitted a lot of commands which either I didn't think were necessary or could be skipped. Just like his script, this one divides itself into 3 parts:

- Part1: This part will ask for your desired username & password, ask for making, formatting & mounting partitions, install base packages, divide main script into 2 more, chroot into the new system and run script part 2.

- Part2: This part sets locale, sets hostname, installs a bunch of packages that I use, sets up username & password, move script part 3 to the new home directory and asks user to reboot the device.

- Part3: This part sets up my "work environment" by cloning my dotfiles, dwm, slstatus, dmenu and st repositories. Then, it installs pikaur (AUR helper) to further install a few more packages, configures touchpad,  set date & time and start zsh4humans script.


## Instructions

- Make a bootable flash drive by using Rufus, Etcher or any other tool you prefer.
- Boot into that pure Arch bootable flash drive.
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

Check [Arch Linux Wiki Installation Guide](https://wiki.archlinux.org/title/installation_guide) because I think it's important for anyone using Arch to be used to Arch Wiki. And then there's [this guide](https://telegra.ph/Installing-Arch-Linux-03-24) I made on my first successful Arch install. It's newb friendly because it was written by a newb.

## Who should use this script?

ME.

Or if you are someone who is distro-hopping and wants a different kind of "distro". Or if you're making an Arch installer script for your own rice & would actually tinker around with the script. Or if Arch wiki is daunting to look at but you are eager to install Arch manually.

This script is NOT for someone who wants to create their own Arch setup with ease because what you're actually looking for then is something like [ArchTitus](https://github.com/ChrisTitusTech/ArchTitus) or [Archfi](https://github.com/MatMoul/archfi). In my opinion no one should be making a permanent Arch setup with someone else's installer scripts, unless you're somehow happy with what they install for you.

## Why write all this?

\> Feel bored \
\> Realise the need for installer script since I mess with my system a lot \
\> Watch a couple of YouTube videos & read a bit of Arch Wiki \
\> Give the script a cool name like [LARBS](https://github.com/LukeSmithxyz/LARBS) \
\> Put it on GitHub \
\> Feel cooler 

## Wallpaper Artwork Credits

The wallpaper I used is a Koishi fanart I found on Pixiv drawn by [農民◆joeManyODw](https://www.pixiv.net/en/users/1568891).
