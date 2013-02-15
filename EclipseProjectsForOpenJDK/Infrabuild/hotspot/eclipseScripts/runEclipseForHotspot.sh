#!/bin/bash

set -eu

#
# runEclipseForHotspot.sh - runs the Eclipse from CLI taking in a parameter (optional)
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
# $ bash runEclipseForHotspot [workspacename]                                                                    #
#                                                                                                                #
##################################################################################################################

#
# Here workspaceName contains the location of the workspace folder
# If workspaceName is blank lets assume that we want to use the current folder as the workspace folder
#

workspaceName="."
if [ "$#" -eq "0" ]; then
  echo "No workspace location has been passed in as parameter. Eclipse will be run from the current folder."
else
  workspaceName=$1
  echo "Eclipse will be run from the $workspaceName folder."
fi

#
# Run the eclipse command to load environment variables and release control
#
eclipse --data $workspaceName &
