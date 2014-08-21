#!/bin/sh
cd /home/pi
tar cjf xbmc_userdata_$(date +%d)_$(date +%m)_$(date +%Y).tar.bz2 ./xbmc
mv xbmc_userdata_$(date +%d)_$(date +%m)_$(date +%Y).tar.bz2 /media/Seagate\ Expansion\ Drive/xbmcbackups/
sudo sync
