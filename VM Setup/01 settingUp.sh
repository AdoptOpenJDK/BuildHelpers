#!bin/sh

set -eu

#
# 01 settingUp.sh - retrieve and install all the essential bits needed to setup the OpenJDK projects.
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

cd /home/openjdk;

# Set up directory structure
echo "Set up directory structure";
 mkdir ~/sources;
 cd ~/sources;

#Install git client
#Git is used for submitting patches view then Patch Review GitHub project.
echo "Install git client";
 sudo apt-get install git-core ;
#(enter password and say Y)

#Install mercurial DVCS client
echo "Install mercurial client"
 sudo apt-get install mercurial;
# (enter password and say Y)

# Clone the repo
echo "*********************************"
echo "Clone the repo"
echo "*********************************"
 cd ~/sources;
 hg clone http://hg.openjdk.java.net/jdk8/tl jdk8_tl ;

sleep;

# Get the rest of the source code
echo "*********************************"
echo "Get rest of the source code"
echo "*********************************"
 cd ~/sources/jdk8_tl/;
 chmod u+x get_source.sh;
 ./get_source.sh;

# Build
#You need to install a minimum set of packages in order to build the 
#OpenJDK
echo "*********************************"
echo "Build"
echo "*********************************"
 sudo apt-get install build-essential openjdk-7-jdk libX11-dev libxext-dev; 
 sudo apt-get install libxrender-dev libxtst-dev libfreetype6-dev libcups2-dev libasound2-dev;
 sudo apt-get install ant gawk;

#You can install an optional package to speed up c++ builds
echo "**************************************"
echo "Install package to speed up c++ builds"
echo "**************************************"
 sudo apt-get install ccache;

#Set default environment
#Execute the following:

# vi ~/.bashrc << might not need it as the below script handles it

#And append:
# export LANG=C
echo "***************************************"
echo "Adding environment variables to .bashrc"
echo "***************************************"
echo "append export LANG=C"
echo "export LANG=C" >> ~/.bashrc;

# export ALT_BOOTDIR=/usr/lib/jvm/java-7-openjdk-amd64
echo "append export ALT_BOOTDIR=...."
echo "export ALT_BOOTDIR=/usr/lib/jvm/java-7-openjdk-amd64" >> ~/.bashrc;

echo "***************************************"
echo "Sourcing .bashrc"
echo "***************************************"
# Then source the new default env settings
echo "source bashrc"
source ~/.bashrc;