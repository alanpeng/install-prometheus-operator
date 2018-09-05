#!/bin/bash
set -e

chmod +x ./download-source-code.sh ./get-online-images-list.sh ./save-offline-images.sh
./download-source-code.sh
./get-online-images-list.sh
./save-offline-images.sh
