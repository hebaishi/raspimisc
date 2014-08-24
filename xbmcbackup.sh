#!/bin/sh
cd /home/pi
sudo initctl stop xbmc
tar czf xbmc_userdata_$(date +%d)_$(date +%m)_$(date +%Y).tar.gz ./xbmc
mv xbmc_userdata_$(date +%d)_$(date +%m)_$(date +%Y).tar.gz /media/Seagate\ Expansion\ Drive/xbmcbackups/
sudo sync
