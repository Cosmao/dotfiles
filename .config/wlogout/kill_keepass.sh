#!/bin/bash
killall -q keepassxc >/dev/null 2>&1
while pgrep -x keepassxc >/dev/null; do sleep 0.1; done
systemctl hibernate
