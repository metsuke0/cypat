#!/bin/bash

# Output files in the /home directory

echo "###"
echo "Home directory files"
echo "###"

find /home -type f | grep -v '/\.' | grep -v 'cypat'

