#!/bin/sh
IP=`nmap -p22 -oG - 192.168.1.2-255 | grep open | awk '{print $2}'`
ssh pi@$IP sudo /sbin/reboot
