#!/bin/bash
# Usage
# $1 Set to 1 if you want to install numpy, scipy and nibabel, 0 otherwise.
# $2 Set to 1 if you want to install Mrtrix, 0 otherwise.
if [[ $# -lt 2 ]]
then
    echo "Missing some params. Please read the header of the script."
    exit 1
fi

# Add the Neuro-Debian repo to our own.
#wget -O- http://neuro.debian.net/lists/quantal.us-nh | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
#sudo apt-key adv --recv-keys --keyserver pgp.mit.edu 2649A5A9
#sudo apt-get update > out_update_apt.txt

# C++ building
echo 
echo "*************************"
echo "Installing basic C++ compilation tools"
echo "*************************"
echo
sudo apt-get install -y cmake cmake-data cmake-qt-gui
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
    wget https://dl.dropbox.com/u/53085014/utils/mrtrix-0.2.10_2012-02-10.tar.bz2
    tar -xvjf mrtrix-0.2.10_2012-02-10.tar.bz2
    
    # Get the patch files
    wget https://dl.dropbox.com/u/53085014/utils/patch_select_cmdline
    patch mrtrix-0.2.10/lib/file/dicom/select_cmdline.cpp patch_select_cmdline

    wget https://dl.dropbox.com/u/53085014/utils/patch_mrtrix_h
    patch mrtrix-0.2.10/lib/mrtrix.h patch_mrtrix_h

    # Build
    cd mrtrix-0.2.10/
    ./build
    sudo ./build install

    cd ../..
    rm -rf temp
fi




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

