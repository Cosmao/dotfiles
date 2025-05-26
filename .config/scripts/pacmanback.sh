#!/bin/bash

paccache -rk1
pacman -Qdtq > ~/pkgorphans.txt
pacman -Qqe > ~/pkglist.txt
echo "Delete stuff older than 30 days?"
trash-empty 30
