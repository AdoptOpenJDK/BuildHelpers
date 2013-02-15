#!/bin/bash

set -eu

#
# downloadEclipseProjectFiles.sh - download scripts and Eclipse project files from repo. 
# Takes repo location (URL) as parameter.
#
# Copyright (c) 2013, Mani Sarkar <sadhak001@gmail.com> All rights reserved.
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

##################################################################################################################
# Run Eclipse and load the workspace for Hotspot (environment variables get loaded)                              # ##################################################################################################################
#                                                                                                                #
# usage:                                                                                                         #
#                                                                                                                #
# $ bash downloadEclipseProjectFiles [download URL]                                                              #
#                                                                                                                #
##################################################################################################################

#
# Here url contains the location from where the files will be downloaded
#

url=""
if [ "$#" -eq "0" ]; then
  echo "No URL has been passed in as parameter, aborting script."
else
  url=$1

  echo "******************************************************************************************************************"
  echo "Files will be downloaded from $url."
  echo "******************************************************************************************************************"

  # wget manual (http://www.gnu.org/software/wget/manual/wget.html)
  echo "Downloading eclipseScripts..."
  mkdir -p eclipseScripts
  cd eclipseScripts
  wget --no-clobber $url/eclipseScripts/downloadEclipseProjectFiles.sh
  wget --no-clobber $url/eclipseScripts/runEclipseForHotspot.sh
  wget --no-clobber $url/eclipseScripts/updateEnvVarsForEclipseForHotspot.sh
  cd ..
  echo "..finished downloading the eclipseScripts folder and its contents."
  echo "******************************************************************************************************************"

  echo "Downloading .project..."
  wget --no-clobber $url/.project
  echo "..finished downloading the .project folder and its contents."
  echo "******************************************************************************************************************"

  echo "Downloading .cproject..."
  wget --no-clobber $url/.cproject
  echo "..finished downloading the .cproject folder and its contents."
  echo "******************************************************************************************************************"

  echo "Downloading .settings..."
  mkdir -p .settings
  cd .settings
  wget --no-clobber $url/.settings/org.eclipse.cdt.codan.core.prefs
  wget --no-clobber $url/.settings/org.eclipse.cdt.core.prefs
  wget --no-clobber $url/.settings/org.eclipse.cdt.managedbuilder.core.prefs
  cd ..
  echo "..finished downloading the .settings folder and its contents."
  echo "******************************************************************************************************************"

  echo "Downloading .metadata..."

  mkdir -p .metadata/.plugins/org.eclipse.core.runtime/.settings
  cd .metadata/.plugins/org.eclipse.core.runtime/.settings
  wget --no-clobber $url/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.cdt.managedbuilder.core.prefs 
  wget --no-clobber $url/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.cdt.ui.prj-hotspot.prefs
  cd ../../../../

  mkdir -p .metadata/.plugins/org.eclipse.debug.core/.launches
  cd .metadata/.plugins/org.eclipse.debug.core/.launches
  wget --no-clobber "$url/.metadata/.plugins/org.eclipse.debug.core/.launches/hotspot Default.launch"
  cd ../../../
  echo "..finished downloading the .metadata folder and its contents."
    echo "******************************************************************************************************************"
fi
