#!/bin/bash

(
cd ~
. fetch-config.sh
. load-config.sh
read -p "Press any key to close..."
) 2>&1 | tee startup.log
