# debian-autoinstall

Generate customized Debian ISO images for automatic deployments.

## Build

Run `build.sh` to generate a hands-free iso image.

### Example

```
./build.sh -u "hub" -n "mainframe" -d "hub.lol"
```

### Flags

```
-u <username>    Admin username
-p <password>    Admin password
-n <hostname>    Machine hostname
-d <domain>      Machine domain
-i <iso_url>     ISO download URL
-s <sign_key>    ISO pgp sign key
-v               Enable verbose mode
-h               Display this help message
```

### Password

If the `-p` flag is not set, a random admin password will be generated.

## Debug in VM

While running the installer, press `ctrl`+`alt`+`f4` to show the installers log output.
To switch back to the installers graphical interface, press `ctrl`+`alt`+`f1`.
Switch to any other TTY for an interactive shell.
