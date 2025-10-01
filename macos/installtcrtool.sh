#! /bin/sh

Install tcr
sudo mkdir -p /opt/tcr
curl -s -L https://github.com/murex/TCR/releases/download/v1.4.1/tcr_1.4.1_Darwin_arm64.tar.gz | sudo tar -xvz - -C /opt/tcr
