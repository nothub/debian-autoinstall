# debian-autoinstall

Generate customized Debian ISO images for automatic deployments.

## Usage

Run `build.sh` to generate a hands-free iso image.

```
./build.sh [-u username] [-p password] [-n hostname] [-d domain] [-a package] [-i iso_url] [-s sign_key] [-o path] [-v] [-h]
```

### Requirements

The following command installs all requirements to use the tool on a Debian based system:

```sh
sudo apt update
sudo apt install curl git gnupg pwgen whois xorriso
```

### Example

```sh
git clone https://github.com/nothub/debian-autoinstall.git
cd debian-autoinstall
# customize authorized ssh keys
curl -sSLo configs/authorized_keys https://github.com/nothub.keys
# set user and password
./build.sh -u 'hub' -p 'changeme'
# set hostname and domain
./build.sh -n 'calculon' -d 'home.arpa'
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
-v               Enable verbose mode
-h               Display this help message
```

### Password

If the `-p` flag is not set, a random admin password will be generated.

## Debug in VM

While running the installer, press `ctrl`+`alt`+`f4` to show the installers log output.
To switch back to the installers graphical interface, press `ctrl`+`alt`+`f1`.
Switch to any other TTY for an interactive shell.
