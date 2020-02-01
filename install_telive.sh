#!/bin/bash
# install_telive.sh (c) 2015-2018 Jacek Lipkowski <sq5bpf@lipkowski.org>
#
# modified 2020 Torsten Harenberg <harenberg@gmail.com> to adopt it to Docker
#
# simple script to install telive under Debian 8, Ubuntu 14 (and maybe 15), Linux mint 17.2
# 
#
# this is a quick hack, with bad error checking etc.
# some day i will make a proper install script, but for now this will have to do
#
# Environment variables to control this script:
# set SKIP_CODEC_INSTALL if you don't want to run the acelp codec install script
# set TETRADIR to some directory to be used instead of ${HOME}/tetra
#
# This script is licensed under GPL v2
#
# I disclaim any liability for things that this software does or doesn't do.
# Everything is the responsibility of the user.
#
# Changelog:
# 20200201: (th) removed user id check, removed all sudo calls
# 20181211: add support for debian 10 --sq5bpf
# 20170709: add support for linux mint 18.2 and debian 9, both are totally untested --sq5bpf
# 20160905: support gnuradio 3.7.x, where x>=10 --sq5bpf
# 20160621: support raspbian 8 and ubuntu 16 --sq5bpf
# 20160309: hopefully work around ubuntu 14/mint 17.3 errors --sq5bpf
# 20160308: add env variables to skip codec install and set tetra dir --sq5bpf
# 20160203: add an icon for 203x60 xterm on the desktop --sq5bpf
# 20151105: unload dvb-t modules just in case --sq5bpf
# 20151101: install also python-numpy due to ubuntu bug #1471351 --sq5bpf
# 20151029: added support for Ubuntu 14 and Linux mint 17.2 --sq5bpf
# 20150706: forbid running script as root --sq5bpf
#


if [ -z "$TETRADIR" ]; then
	TETRADIR=${HOME}/tetra
fi

get_osr() {
	( . /etc/os-release ; eval "echo \$$1" )
}

do_distro_specific_stuff() {
	if [ ! -f /etc/os-release ]; then
		echo "There is no /etc/os-release file, so this is an unknown distribution, and this script will not run"
		exit 1
	fi
	case `get_osr ID` in

		"linuxmint")
			DISTRO_NAME="ubuntu"
			DISTRO_VERSION=`get_osr VERSION_ID`
			;; 
		"raspbian")
			DISTRO_NAME="raspbian"
			DISTRO_VERSION=`get_osr VERSION_ID`
			;; 
		"debian")
			DISTRO_NAME="debian"
			DISTRO_VERSION=`get_osr VERSION_ID`
			if [ -z "$DISTRO_VERSION" ]; then
				if [[ "`get_osr PRETTY_NAME`" =~ "Linux buster" ]]; then
					DISTRO_VERSION=10
				fi
			fi
			;; 
		"ubuntu")
			#this is either ubuntu or linux mint
			DISTRO_NAME="ubuntu"
			DISTRO_VERSION=`get_osr VERSION_ID|cut -d . -f 1` # do far we're only interested in the major version here
			;;
		*)
			echo "Unknown distribution"
			cat /etc/os-release 
			;;

		esac
		DISTRO="$DISTRO_NAME $DISTRO_VERSION"
	}

verify_prerequisites() {
	echo "CHECKING prerequisites"
}

install_gnuradio() {

	GR_VERSION=`gnuradio-config-info -v 2>/dev/null|tr -d v`

	case "$GR_VERSION" in
		3.7.[5-9]*|3.7.[1-9][0-9]*|3.6.*)
			echo "Found supported gnuradio $GR_VERSION"
			return 0
			;;
		3.8.*)
			echo "#######################"
			echo "Found supported gnuradio $GR_VERSION , which may work, or it may not (not tested)"
			echo "########## now waiting 20s for you to read this message #############"
			sleep 20
			return 0
			;;
		"") #no gnuradio installed
			;;
		*)
			echo Unsupported version $GR_VERSION
			return 1
			;;
	esac

	echo "INSTALLING Gnuradio"

	case "$DISTRO" in
		"linuxmint 18.2")
			apt-get -y install gnuradio gnuradio-dev gr-osmosdr gr-iqbal gqrx-sdr && return 0
			;;
		"raspbian 8")
			apt-get -y install gnuradio gnuradio-dev gr-osmosdr gr-iqbal gqrx-sdr && return 0
			;;
		"debian 8"|"debian 9"|"debian 10")
			apt-get -y install gnuradio gnuradio-dev gr-osmosdr gr-iqbal gqrx-sdr && return 0
			;;
		"debian 7"|"debian 6")
			echo "### No supported gnuradio package for this distribution ###"
			echo "Please use either pybombs or the build-gnuradio script from SBRAC"
			echo "see this page: https://gnuradio.org/redmine/projects/gnuradio/wiki/InstallingGRFromSource"
			return  1
			;;

		"ubuntu 14")
			for i in ppa:bladerf/bladerf \
				ppa:ettusresearch/uhd \
				ppa:myriadrf/drivers \
				ppa:myriadrf/gnuradio \
				ppa:gqrx/gqrx-sdr
						do
							add-apt-repository -y $i || break
						done && \
							apt-get update && \
							apt-get install -y gqrx-sdr gnuradio gr-osmosdr hackrf python-numpy && \
							return 0
													;;
												"ubuntu 15"|"ubuntu 16"|"ubuntu 17"*|"ubuntu 18"*|"ubuntu 19"*) 
													apt-get -y install gnuradio gnuradio-dev gr-osmosdr gr-iqbal gqrx-sdr python-numpy && return 0
													;;
												*)
													#unknown distro, not sure what to do here. maybe pretend everything is ok and install? :)
													echo "Unknown distribution (this should not happen :), for now we'll pretend that it has the right gnuradio packages"
													apt-get -y install gnuradio gnuradio-dev gr-osmosdr gr-iqbal gqrx && return 0
													;;
											esac

											echo "Unknown distro [$DISTRO], please report it, and send the below information:"
											cat /etc/os-release

											return 1
										}

									update_packages() {
										apt-get update; RET=$?
										if [ "$RET" != 0 ]; then
											echo "### ERROR UPDATING PACKAGE LISTS!"
											echo "Make sure you have full internet access, and that your distribution's package repositories are currently avaliable"
											echo "Try to run 'apt-get update' by hand, and see what you have to do to resolve it"
											return 1
										fi
										return 0
									}

								install_packages() {
									echo "INSTALLING packages"

									apt-get -y install git make libtool libncurses5-dev build-essential autoconf automake vorbis-tools sox alsa-utils unzip xterm libxml2-dev socat


								}

							install_codec () {
								echo "INSTALLING codec"
								git clone https://github.com/sq5bpf/install-tetra-codec && \
									cd install-tetra-codec && \
									chmod 755 install.sh  ; RET=$?
																	if [ "$RET" = 0 ]; then
																		if [ "$SKIP_CODEC_INSTALL" ]; then
																			echo "Skipping acelp codec install, please do this:"
																			echo "cd `pwd`"
																			echo "./install.sh"

#if the codec is not installed then we need to make the /tetra dir ourselves
TBASEDIR=/tetra
MYUSER=`id -nu`
MYGROUP=`id -ng`
mkdir -p "${TBASEDIR}/bin" && \
	chown -R ${MYUSER}.${MYGROUP} "$TBASEDIR"
else
	./install.sh; RET=0
fi
fi
return $RET
}


install_libosmocore () {
	if pkg-config --libs libosmocore >/dev/null 2>&1; then
		echo "libosmocore is already installed"
	else
		echo "INSTALLING libosmocore"
		git clone https://github.com/sq5bpf/libosmocore-sq5bpf && \
			cd libosmocore-sq5bpf &&  \
			autoreconf -i && \
			./configure && \
			make && \
			make install && \
			ldconfig
				fi
			}

		install_osmo_tetra_sq5bpf() {
			echo "INSTALLING osmo-tetra-sq5bpf"
			git clone https://github.com/sq5bpf/osmo-tetra-sq5bpf && \
				cd osmo-tetra-sq5bpf/src && \
				make
			}

		install_telive() {
			echo "INSTALLING telive"
			git clone https://github.com/sq5bpf/telive && \
				cd telive && \
				make && \
				chmod 755 install.sh && \
				./install.sh
			}

		make_desktop_icons() {
			cat > ~/Desktop/xterm_telive.desktop <<EOF2
[Desktop Entry]
Version=1.0
Type=Application
Name=xterm 203x60
Comment=xterm 203x60 for telive
Exec=xterm -g 203x60
Icon=/usr/share/pixmaps/xterm-color_48x48.xpm
Path=${TETRADIR}/telive
Terminal=false
StartupNotify=false
GenericName=xterm 203x60 for telive
Name[en_US.utf8]=telive xterm
EOF2


}

######## MAIN
echo "Telive simple installer"

verify_prerequisites

#if there is a previous install then kill it
rm -fr "$TETRADIR" >/dev/null 2>/dev/null 

mkdir -p $TETRADIR
cd "$TETRADIR" || exit 1

echo "Please make sure that you have full internet access"
do_distro_specific_stuff || exit 1
update_packages || exit 1 
install_gnuradio || exit 1

#rtl-sdr stuff installs new udev rules, so restart just in case
service udev restart

#unload these modules just in case, installing librtlsdr blacklists them 
#anyway, but they may be loaded now, and this might confuse the user
for i in dvb_usb_rtl28xxu e4000 rtl2832
do
	rmmod $i >/dev/null 2>&1
done

install_packages || exit 1

( install_codec ) || exit 1
if [ -d "/tetra" ]; then
	:
else    
	echo "You're missing the /tetra directory, probably something wrong with the codec installation"	
	exit 1
fi
( install_libosmocore ) || exit 1
( install_osmo_tetra_sq5bpf ) || exit 1 
( install_telive ) || exit 1

#please note that we should actually check if everything went correctly, 
#not just assume it :)
echo; echo
echo "It seems that everything installed correctly :)"
echo "All of the files are in `pwd`"
echo
echo "PLEASE, before proceeding read the manual in `pwd`/telive/telive_doc.pdf"

#copy the manual, maybe some user will notice it is there and actually read it?
if [ -d ~/Desktop ]; then
	cp "`pwd`/telive/telive_doc.pdf" ~/Desktop
	echo "or the telive_doc.pdf file on the desktop"
	make_desktop_icons
fi

echo 
echo "The most up to date version of the manual is always located here:"
echo "https://github.com/sq5bpf/telive/raw/master/telive_doc.pdf"



