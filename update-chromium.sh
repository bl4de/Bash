#!/bin/bash

# remove previous downloaded .zip archive
rm -rf ~/tmp/chromium_latest.zip

# download newest Chromium build
wget https://download-chromium.appspot.com/dl/Mac?type=snapshots -O ~/tmp/chromium_latest.zip

# unizp...
unzip ~/tmp/chromium_latest.zip -d ~/tmp/

# ...remove current Chromium app from Apps...
rm -rf /Applications/Chromium.app

# ...and finally copy newest build into Apps
mv -f ~/tmp/chrome-mac/Chromium.app /Applications
rm -rf ~/tmp/chromium_latest.zip
rm -rf ~/tmp/chrome-mac

echo "[+] done"

