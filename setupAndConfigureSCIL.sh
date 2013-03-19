#!/bin/bash
# Usage
# $1 Set to 1 if you want to install numpy, scipy and nibabel, 0 otherwise.
# $2 Set to 1 if you want to install Mrtrix, 0 otherwise.
# $3 Set to 1 if you want to install the Brainvisa suite, 0 otherwise.
# $4 Set to 1 if you want to install Freesurfer, 0 otherwise.
# $5 Set to 1 if you want to install FSL 5.0, 0 otherwise.
# $6 Set to 1 if you want to configure the Fibernavigator's dependencies, 0 otherwise.
if [[ $# -lt 6 ]]
then
    echo "Missing some params. Please read the header of the script."
    exit 1
fi

# Add the Neuro-Debian repo to our own.
wget -O- http://neuro.debian.net/lists/quantal.us-nh | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver pgp.mit.edu 2649A5A9
sudo apt-get update > out_update_apt.txt

# C++ building
echo 
echo "*************************"
echo "Installing basic C++ compilation tools"
echo "*************************"
echo
sudo apt-get install -y cmake cmake-data cmake-qt-gui cmake-curses-gui
sudo apt-get install -y g++ build-essential
sudo apt-get install -y gfortran
sudo apt-get install -y git

# Python
echo
echo "*************************"
echo "Installing basic Python tools."
echo "*************************"
echo
sudo apt-get install -y python-dev python-pip python-virtualenv python-setuptools

# Numpy, Scipy, Nibabel
if [[ $1 == 1 ]]
then
    echo
    echo "*************************"
    echo "Pip installing numpy, scipy and nibabel."
    echo "*************************"
    echo
    sudo apt-get install -y python-numpy
    sudo apt-get install -y python-scipy
    sudo pip install nibabel
fi

# Mrtrix
# Ideally, we would use the NeuroDebian repo, but Mrtrix
# is not currently packaged for Quantzal...
if [[ $2 == 1 ]]
then
    echo
    echo "*************************"
    echo "Downloading, configuring and installing Mrtrix."
    echo "*************************"
    echo
    sudo apt-get install -y libglib2.0-dev libgtk2.0-dev libglibmm-2.4-dev libgtkmm-2.4-dev libgtkglext1-dev libgsl0-dev libgl1-mesa-dev libglu1-mesa-dev

    mkdir temp
    cd temp
    wget https://dl.dropbox.com/u/53085014/utils/mrtrix-0.2.11_2013-03-13.tar.bz2
	tar -xvjf mrtrix-0.2.11_2013-03-13.tar.bz2

    # Build
    cd mrtrix-0.2.11/
    ./build
    sudo ./build install

    cd ../..
    rm -rf temp
fi

# Brainvisa
if [[ $3 == 1 ]]
then
	echo
	echo "*************************"
    echo "Downloading and installing the Brainvisa suite."
    echo "*************************"
    echo

	# This download will be deleted only at the end of the script, to make sure the user does not need to re-download it if something fails.	
	wget -O /tmp/brainvisa-Mandriva-2008.0-x86_64-4.3.0-2012_09_03.tar.bz2 -c ftp://ftp.cea.fr/pub/dsv/anatomist/binary/brainvisa-Mandriva-2008.0-x86_64-4.3.0-2012_09_03.tar.bz2
	cd /tmp/
	tar -xjf brainvisa-Mandriva-2008.0-x86_64-4.3.0-2012_09_03.tar.bz2
	sudo mv brainvisa-4.3.0/ /usr/local/
fi

# Freesurfer
if [[ $4 == 1 ]]
then
	echo
	echo "*************************"
    echo "Downloading and installing Freesurfer."
    echo "*************************"
    echo

	wget -c -O /tmp/freesurfer-Linux-centos6_x86_64-stable-pub-v5.2.0.tar.gz ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/5.2.0/freesurfer-Linux-centos6_x86_64-stable-pub-v5.2.0.tar.gz
	cd /tmp/
	tar -xzf freesurfer-Linux-centos6_x86_64-stable-pub-v5.2.0.tar.gz
	sudo mv freesurfer/ /usr/local/

	# Get the licence
	cd ~
	mkdir temp
	cd temp/
	wget https://dl.dropbox.com/u/53085014/utils/fs_licence
	mv fs_licence /usr/local/freesurfer/.license
    cd ..
	rm -r -f temp/
fi

# FSL 5.0
if [[ $5 == 1 ]]
then
	echo
	echo "*************************"
    echo "Downloading and installing FSL."
    echo "*************************"
    echo

	sudo apt-get install -y fsl
	sudo ln -s /usr/share/fsl/5.0/ /usr/local/fsl
fi

# Fibernavigator dependencies
if [[ $6 == 1 ]]
then
	echo
	echo "*************************"
    echo "Installing the Fibernavigator's dependencies."
    echo "*************************"
    echo
	sudo apt-get install -y libwxbase2.8-dev libwxbase2.8-0 wx2.8-headers libwxgtk2.8-0 libwxgtk2.8-dev
	sudo apt-get install -y libglew1.8 libglew-dev
fi

# Help messages at the end of the script
echo
echo
echo "*************************"
echo "END OF INSTALLATION NOTES"
echo "*************************"
if [[ $2 == 1 ]]
then
    echo
    echo "- Do not forget that you can change Mrtrix's multicpu config"
    echo "  in /etc/mrtrix.conf"
fi

if [[ $3 == 1 ]]
then
	echo
	echo "- To be able to use Brainvisa / Anatomist when starting a new console, make"
	echo "  sure to add the following lines to your .bashrc"
	echo "    ###### Brainvisa ######"
	echo "    export BRAINVISA=/usr/local/brainvisa-4.3.0/"
	printf '    export PATH=$PATH:$BRAINVISA/bin'
	echo
fi

if [[ $4 == 1 ]]
then
	echo
	echo "- To be able to use Freesurfer when starting a new console, make"
	echo "  sure to add the following lines to your .bashrc"
	echo "    ###### Freesurfer ######"
	echo "    export FREESURFER_HOME=/usr/local/freesurfer"
	echo '	  source $FREESURFER_HOME/SetUpFreeSurfer.sh'
fi

if [[ $5 == 1 ]]
then
	echo
	echo "- To be able to use FSL when starting a new console, make"
	echo "  sure to add the following lines to your .bashrc"
	echo "    ###### FSL ######"
	echo "    export FSLDIR=/usr/local/fsl"
	echo '    export PATH=$PATH:${FSLDIR}/bin'
	echo '    . ${FSLDIR}/etc/fslconf/fsl.sh'
fi

if [[ $6 == 1 ]]
then
	echo
	echo "- The Fibernavigator's dependencies have been installed."
	echo "  You will still need to checkout the code and compile it."
	echo "  See https://github.com/scilus/fibernavigator"
fi

# If we reach the end of the script, we can delete temporary files.
# We won't delete them, we'll tell the user to do it.
if [[ $3 == 1 ]]
then
    echo
    echo "-  If installation was completed, you can delete"
    echo "   /tmp/brainvisa-Mandriva-2008.0-x86_64-4.3.0-2012_09_03.tar.bz2"
    echo "   or you can keep it if you think you will need to reinstall later."
fi

# Remove Freesurfer archive
if [[ $4 == 1 ]]
then
    echo
    echo "-  If installation was completed, you can delete"
    echo "   /tmp/freesurfer-Linux-centos6_x86_64-stable-pub-v5.2.0.tar.gz"
    echo "   or you can keep it if you think you will need to reinstall later."
fi

# General warning
echo
echo "In some cases, if some apps (Brainvisa, Fibernavigator) crash when using display functions,"
echo "try enabling the Nvidia closed source drivers."

echo
echo "Done"
echo
