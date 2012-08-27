#!bin/sh

set -eu

#
# 02a executeBuild.sh - run a complete build, record the output into a log file and make a copy of the output image
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

echo "*********************************************************************"
echo "Do sanity check of openJDK, build all projects and record to log file"
echo "*********************************************************************"
#Execute the build
  cd ~/sources/jdk8_tl/
 make sanity
 make all &> fullBuild.log

#Move the build output for future partial builds
#This step is Mandatory if you want partial builds to work.
echo "***************************************"
echo "Make backup copy of linux-amd64"
echo "***************************************"

 mv ~/sources/jdk8_tl/build/linux-amd64 ~/sources/jdk8_tl/build/linux-amd64_backup
