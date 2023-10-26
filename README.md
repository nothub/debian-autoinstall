# debian-autoinstall

Generate customized Debian iso images for automatic (preseeded) deployments.

## Usage

Run `build.sh` to generate the hands-free iso image.

## Password

The password declared by `passwd/user-password-crypted` will be discarded!
The user is prompted for a new password on first login.

## Debug in VM

While running the installer, press ctrl+alt+f4 to show `in-target` log output.
