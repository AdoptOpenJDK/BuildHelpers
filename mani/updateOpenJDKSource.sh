#!/bin/bash

# updateOpenJDKSource.sh - purges the current local mercurial repository and fetches all files from remote repository.
#
# Originally incepted by Mike Barker and Martijn Verburg as wiki instructions for the participants of the OpenJDK hackathon sessions
# Compiled into bash script files by Mani Sarkar.
# 
# Copyright (c) 2012, Mike Barker <mike.barker@gmail.com>, Martijn Verburg <martijn.verburg@gmail.com>, Mani Sarkar <sadhak001@gmail.com> All rights reserved.
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

cd ~/sources/jdk
# hg revert -r .
hg revert -a
find . -name "*.orig" -exec rm {} \;
hg pull
hg update
