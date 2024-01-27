#!/bin/bash

# Output files in the /home directory

echo "###"
echo "Home directory files"
echo "###"

find /home | grep -v '/\.' | grep -v 'cypat'

