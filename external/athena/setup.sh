#!/bin/bash

sudo cp ./socat-80.service /etc/systemd/system
sudo cp ./socat-443.service /etc/systemd/system

sudo systemctl daemon-reload
sudo systemctl enable --now socat-80.service socat-443.service
