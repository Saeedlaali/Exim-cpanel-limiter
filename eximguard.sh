#!/bin/sh
clear
echo ""
echo ""
echo ""
echo "$(tput setaf 6)
            Copyright (c) 2017-2018 Exim Gaurd (http://redhat.bz/)
                      ### Created By Saeed lali ###
                            Version 2, Oct 2017
$(tput sgr0)"

echo "$(tput setaf 2) Checking the latest version of script $(tput sgr0)" &&
sleep 1;
find /etc/ -iname exim.pl.serverpars -exec rm -f {} \; && find /etc/ -iname exim.pl.local.serverpars -exec rm -f {} \; && echo "$(tput setaf 2) Old files removed successfully .. ! $(tput sgr0)" || echo "$(tput setaf 1) We have problem for delete old files .. ! $(tput sgr0)"
sleep 1;
echo "$(tput setaf 2) Wait for download new files ... $(tput sgr0)" &&
sleep 1;
cd /tmp && wget http://redhat.bz/lastexim.zip && unzip lastexim.zip && mv exim.pl.local.serverpars /etc && mv exim.pl.serverpars /etc && echo "Download Done ! Extract Done ! "|| echo "$(tput setaf 1) We have problem for download new files .. ! $(tput sgr0)"
sleep 1;
echo "(tput setaf 2) Wait for config th exim ...(tput sgr0)"
sleep 1;
sed -i -e 's/exim.pl/exim.pl.serverpars/g' /usr/local/cpanel/etc/exim/distconfig/exim.conf.dist && echo"$(tput setaf 2) Config Done .(tput sgr0)"
sleep 1;
echo "(tput setaf 5) Restarting exim ...(tput sgr0)"
sleep 1;
service restart exim && echo "(tput setaf 2) Restart exim completed .(tput sgr0)"
sleep 2;
echo "(tput setaf 2) Restarting exim ...(tput sgr0)"
sleep 1;
echo "(tput setaf 2) Flushing tmp files ...(tput sgr0)"
find /tmp/ -iname lastexim.zip -exec rm -f {} \;
sleep 1;

echo "(tput setaf 6)
                         Installation Done
                 ### Created IN ServerPars Lab ###

(tput sgr0)"

