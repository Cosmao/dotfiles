#!/bin/bash

paccache -rk1
pacman -Qdtq > ~/pkgorphans.txt
pacman -Qqe > ~/pkglist.txt
