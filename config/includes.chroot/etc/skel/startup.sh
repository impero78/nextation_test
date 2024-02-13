#!/bin/bash

(
cd ~
echo "one two three"
echo "four five six"
chromium www.repubblica.it
) 2>&1 | tee startup.log
