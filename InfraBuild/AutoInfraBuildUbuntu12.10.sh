#!bin/sh

set -eu

#
# AutoInfraBuildUbuntu12.04.sh - retrieve and install all the essential bits of OpenJDK and run a test to check if it has been correctly installed.
# The script is a product of the instructions from the Adopt OpenJDK wiki page.
#
# Copyright (c) 2012 Martijn Verburg <martijn.verburg@gmail.com>, Mani Sarkar <sadhak001@gmail.com>. All rights reserved.
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
#
# This code is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 only, as
# published by the Free Software Foundation.  Oracle designates this
# particular file as subject to the "Classpath" exception as provided
# by Oracle in the LICENSE file that accompanied this code.
#
# This code is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# version 2 for more details (a copy is included in the LICENSE file that
# accompanied this code).
#
# You should have received a copy of the GNU General Public License version
# 2 along with this work; if not, write to the Free Software Foundation,
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
#

# Get Source
echo "************************************************************"
echo "Creating folder, downloading jtreg and expanding into folder"
echo "************************************************************"

 if [ ! -d "sources" ]; then
    mkdir ~/sources ;
 fi
 cd ~/sources ;
 sudo apt-get install git-core ;
 sudo apt-get install mercurial ;

 if [ ! -d "jdk8_tl" ]; then
    hg clone http://hg.openjdk.java.net/jdk8/tl jdk8_tl ;
    cd jdk8_tl/ ;
    chmod u+x get_source.sh ;
    ./get_source.sh ;
 fi

echo "************************************************************"
echo "Running configure command"
echo "************************************************************"

 # To execute the new build-infras build, run the following:
 cd ~/sources/jdk8_tl/common/makefiles ;
 bash ../autoconf/configure ;


echo "*********** *************************************************"
echo "Getting and installing essential bits for OpenJDK"
echo "************************************************************"

# get and install libararies
 sudo apt-get install build-essential openjdk-7-jdk libX11-dev libxext-dev libxrender-dev libxtst-dev libfreetype6-dev libcups2-dev libasound2-dev ccache ;

echo "************************************************************"
echo "Installing the g++-4.7-multilib"
echo "************************************************************"

# optional g++-4.7-multilib library
sudo apt-get install g++-4.7-multilib

echo "************************************************************"
echo "Creating folder, downloading jtreg and expanding into folder"
echo "************************************************************"

# Install countWarnings.awk script
 cd ~/sources/jdk8_tl/jdk/make ;
 wget https://raw.github.com/AdoptOpenJDK/BuildHelpers/master/countWarnings.awk ;
 chmod u+x countWarnings.awk ;

echo "************************************************************"
echo "Download and install createPatches.sh"
echo "************************************************************"

# Install createPatches.sh script - To aid in creating patches you can install the createPatches.sh script
 cd ~/sources/jdk8_tl/jdk ;
 wget https://raw.github.com/AdoptOpenJDK/BuildHelpers/master/createPatches.sh ;
 chmod u+x createPatches.sh ;

echo "************************************************************"
echo "Running configure command"
echo "************************************************************"

# To execute the new build-infras build, run the following:
 cd ~/sources/jdk8_tl/common/makefiles
 bash ../autoconf/configure ;

echo "************************************************************"
echo "Create JDK and J2SE images like the old build system"
echo "************************************************************"

# Make the Images
 cd ~/sources/jdk8_tl/common/makefiles ;
 make images;

echo "************************************************************"
echo "Run a complete build in Verbose mode (optional)"
echo "************************************************************"
 
# Make verbose infra build of OpenJDK 
make VERBOSE="-d -p" &> infrabuildVerboseBuild.log

