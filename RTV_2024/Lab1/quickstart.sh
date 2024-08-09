#!/bin/bash
set -e

if [[ $UID -eq 0 ]]; then
        echo "[!] Don't run this as root."
        return 1
fi

LINK="https://releases.hashicorp.com/terraform/1.9.3/terraform_1.9.3_linux_amd64.zip"
BINDIR="/usr/bin"
FILENAME="terraform_1.9.3_linux_amd64.zip"

curl -s -o "$FILENAME" "$LINK"

unzip -qq "$FILENAME" || exit 1

sudo mv terraform $BINDIR/terraform
chmod 777 $BINDIR/terraform 

curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
rm -Rf LICENSE.txt
exit 0