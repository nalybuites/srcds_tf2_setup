#!/bin/bash

##########################################################
### THIS SCRIPT MUST BE RUN AS ROOT OR WITH SUDO PERMS ###
### THIS SCRIPT HAS ONLY BEEN TESTED AGAINST UBUNTU    ###
##########################################################

INIT_DIR=`pwd`;
SCRIPT=$(readlink -f "$0");
SCRIPT_ROOT=$(dirname "$SCRIPT");
echo $SCRIPT
echo $SCRIPT_ROOT

# create a system user for source dedicated server
echo -n "**** Adding 'srcds' user... "
adduser --no-create-home --group --system --quiet srcds;
echo "Done."

# build directory structure
echo -n "**** Building /opt/srcds directory structure... "
mkdir -p /opt/srcds;
mkdir -p /opt/srcds/download;
mkdir -p /opt/srcds/scripts;
mkdir -p /opt/srcds/hlserver;
mkdir -p /opt/srcds/conf;
mkdir -p /opt/srcds/logs;
mkdir -p /var/www/tf2/replays;
echo "Done."

# download and extract steamcmd client
echo -n "**** Downloading and extracting SteamCMD client... "
wget -q -O /opt/srcds/download/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz
cd /opt/srcds/hlserver;
tar -x -z -f /opt/srcds/download/steamcmd_linux.tar.gz
echo "Done."

# copy and run steamcmd script for install
echo -n "**** Installing TF2... "
cp $SCRIPT_ROOT/tf2_update.steamcmd /opt/srcds/scripts/tf2_update.steamcmd;
/opt/srcds/hlserver/steamcmd.sh +runscript /opt/srcds/scripts/tf2_update.steamcmd;
echo "Done."

# copy init.d script into right location and link
echo -n "**** Placing init.d script... "
cp $SCRIPT_ROOT/tf2.initd /opt/srcds/scripts/tf2.initd;
if [ -e /etc/init.d/tf2 ]; then
	rm /etc/init.d/tf2;
fi
ln -s /opt/srcds/scripts/tf2.initd /etc/init.d/tf2;
echo "Done."

# copy sample mapcycle into right location and link
echo -n "**** Placing sample mapcycle... "
cp $SCRIPT_ROOT/mapcycle.txt /opt/srcds/conf/mapcycle.txt;
if [ -e /opt/srcds/hlserver/tf2/tf/cfg/mapcycle.txt ]; then
	rm /opt/srcds/hlserver/tf2/tf/cfg/mapcycle.txt;
fi
ln -s /opt/srcds/conf/mapcycle.txt /opt/srcds/hlserver/tf2/tf/cfg/mapcycle.txt;
echo "Done."

# copy sample config into right location and link
echo -n "**** Placing sample server config... "
cp $SCRIPT_ROOT/tf2_server_config.cfg /opt/srcds/conf/tf2_server_config.cfg;
ln -s /opt/srcds/conf/tf2_server_config.cfg /opt/srcds/hlserver/tf2/tf/cfg/server.cfg;
echo "Done."

# copy sample replay config into right location and link
echo -n "**** Placing sample replay config... "
cp $SCRIPT_ROOT/tf2_replay_config.cfg /opt/srcds/conf/tf2_replay_config.cfg;
ln -s /opt/srcds/conf/tf2_replay_config.cfg /opt/srcds/hlserver/tf2/tf/cfg/replay.cfg;
echo "Done."

# change ownership of directory structure to the srcds user
echo -n "**** Setting file ownership... "
chown -R srcds:srcds /opt/srcds;
chown srcds:srcds /var/www/tf2/replays;
echo "Done."

#return to original directory
cd $INIT_DIR;
