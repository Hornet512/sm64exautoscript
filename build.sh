function pause() {
	if [ "$*" == "" ]; then
		read -p "Hornet, please add a pause prompt.
I mean, how do you mess this up?"
	else
		read -p "$*"
	fi
}
ENTERTOCLOSE="Press ENTER to close..."
function waitdebug() {
	echo I\'m going to keep this window open so you can save the contents of this
	echo window to a text document for debugging purposes.
	pause $ENTERTOCLOSE
	exit
}
function openbuildpath() {
	echo OK\! Opening build path...
	if [ ! -d ./build/us_pc ]; then
		echo Error\! The build path doesn\'t exist!
		echo That\'s very strange, since the compile was successful...
		echo You might want to report this as an issue in the Github repository...
		pause $ENTERTOCLOSE
		exit
	else
		open ./build/us_pc
		waitdebug
	fi
}
function checkfordelerror() {
	if [ -e ./sm64ex ]; then
		echo Error\! Failed to delete old sm64ex folder\!
		echo Is it read-only?
		pause $ENTERTOCLOSE
		exit
	fi
}
echo Automated installer for SM64EX.
if [ ! -e ./rom.z64 ]; then
	echo Error\! You need to provide a byteswapped ROM file in the same folder as this script, named "rom.z64"
	pause $ENTERTOCLOSE
	exit
fi
while true; do
	read -p "Do you want to build SM64EX? " yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
	esac
done
sudo -p "Please enter your password to start installing dependencies and build SM64EX: " apt install build-essential bsdmainutils git python3 libglew-dev libsdl2-dev
if [ -e ./sm64ex ]; then
	echo The folder sm64ex already exists, deleting...
	rm -rf ./sm64ex
	checkfordelerror
fi
git clone https://github.com/sm64pc/sm64ex.git -b nightly
if [ ! -e ./sm64ex ]; then
	echo Error\! The folder that I tried to create doesn\'t exist\! Please check your internet connection or your drive and try again.
	pause $ENTERTOCLOSE
	exit
fi
cp ./rom.z64 ./sm64ex/baserom.us.z64
if [ ! -e ./sm64ex/baserom.us.z64 ]; then
	echo Error\! The ROM didn\'t copy to the source folder\! Please check the ROM file and install folder in the script path.
	pause $ENTERTOCLOSE
	exit
fi
cd sm64ex
make -j4 VERSION=us TARGET_BITS=64 BETTERCAMERA=1 NODRAWINGDISTANCE=1 TEXTURE_FIX=1 EXT_OPTIONS_MENU=1 DISCORDRPC=1
if [ -e ./build/us_pc/sm64.us.f3dex2e ]; then
	echo Done!
	while true; do
		read -p "Do you want to see the output folder? " yn
		case $yn in
			[Yy]* ) openbuildpath;;
			[Nn]* ) waitdebug;;
			* ) echo "Please answer yes or no (or y/n).";;
		esac
	done
	exit
else
	echo Error\! The program failed to compile\!
	waitdebug
fi
exit
