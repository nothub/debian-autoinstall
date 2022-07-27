# Debian HTTP Preseeding

## Usage

`iso.sh` -> Generate hands-fee iso
`serve.sh` -> Serve deployment payload

## Password

The password declared with `passwd/user-password-crypted` will not actually be used.
The user password must be defined on first ssh login.

## preseed.cfg

### Format

preseed.cfg line format: `<owner> <question name> <question type> <value>`

Put only a single space or tab between type and value, any additional whitespace will be interpreted as belonging to the
value!

A line can be split into multiple lines by appending a backslash (“\”) as the line continuation character. A good place
to split a line is after the question name; a bad place is between type and value. Split lines will be joined into a
single line with all leading/trailing whitespace condensed to a single space.

Most questions need to be preseeded using the values valid in English and not the translated values. However, there are
some questions (for example in partman) where the translated values need to be used.

### Examples

- [latest stable](https://www.debian.org/releases/stable/example-preseed.txt)
- [bullseye](https://www.debian.org/releases/bullseye/example-preseed.txt)
