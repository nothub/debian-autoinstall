# debian-autoinstall

Generate customized Debian ISO images for automatic deployments.

## Usage

Run `build.sh` to generate a hands-free ISO image.

```
./build.sh [-u username] [-p password] [-n hostname] [-d domain] [-a package] [-i iso_url] [-s sign_key] [-o path] [-x] [-z] [-v] [-h]
```

### Dependencies

Start a [devbox](https://www.jetify.com/devbox) [shell](https://www.jetify.com/devbox/docs/quickstart/#launch-your-development-environment) with:

```sh
devbox shell --pure
```

Or install all dependencies on a Debian 12 system:

```sh
sudo apt update
sudo apt install curl git gnupg pwgen whois xorriso
```

### Clone repo

Clone this repository and `cd` into it.

```sh
git clone https://github.com/nothub/debian-autoinstall.git
cd debian-autoinstall
```

### SSH keys

To include SSH keys for remote access, add them to the `configs/authorized_keys` file.

```sh
curl -fsSLo configs/authorized_keys https://github.com/nothub.keys
echo "ssh-ed25519 AAAA... foo" >> configs/authorized_keys
echo "ssh-ed25519 AAAA... bar" >> configs/authorized_keys
```

### Build ISO

```sh
# set user and password
./build.sh -u 'hub' -p 'changeme'
# set hostname and domain
./build.sh -n 'calculon' -d 'example.org'
# include additional apt packages
./build.sh -a 'strace' -a 'unattended-upgrades'
```

### Flags

```
-u <username>    Admin username
-p <password>    Admin password
-n <hostname>    Machine hostname
-d <domain>      Machine domain
-a <package>     Additional apt package
-i <iso_url>     ISO download URL
-s <sign_key>    ISO pgp sign key
-o <out_file>    ISO output file
-x               Power off after install
-z               Sudo without password
-v               Enable verbose mode
-h               Display this help message
```

### Password

If the `-p` flag is not set, a random admin password will be generated, printed to stdout and written to `<out_file>.auth`.

### Hostname

If the `-n` flag is not set, a hostname will be generated at installation.
The hostname will be based on the installed machines mac addresses.

### Restart

If the `-x` flag is not set, the machine will restart after the installation is finished.

## Preseed Config

For an extended example, check:
https://www.debian.org/releases/bookworm/example-preseed.txt

## Debug in VM

While running the installer, press `ctrl`+`alt`+`f4` to show the installers log output.
To switch back to the installers graphical interface, press `ctrl`+`alt`+`f1`.
Switch to any other TTY for an interactive shell.
