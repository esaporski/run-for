#!/bin/sh
# Run as root

# Install shells
pkg install --yes \
	bash \
	dash \
	ksh \
	mksh \
	oksh \
	yash \
	zsh

# Install shellspec
pkg install --yes \
	git \
	pcre2
PREFIX="/usr/local"
rm -f "${PREFIX}/bin/shellspec"
rm -rf "${PREFIX}/lib/shellspec"
curl -fsSL https://git.io/shellspec | sh -s -- --yes --prefix "$PREFIX"

# Delete `.shrc` file (causes problems with some shells)
rm -f /home/vagrant/.shrc

# Enter `/mnt` directory when SSH session starts
grep -qxF 'cd /mnt' /home/vagrant/.profile || echo "cd /mnt" >>/home/vagrant/.profile
