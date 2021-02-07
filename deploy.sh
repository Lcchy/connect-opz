#!/bin/bash

sudo cp 99-digitakt.rules /etc/udev/rules.d/
sudo cp digitakt-jack-audio.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo udevadm control --reload-rules && udevadm trigger

