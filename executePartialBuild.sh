#!/bin/bash

set -eu

#
# executePartialBuild.sh - performs a partial or incremental build (not full make) of 
# the openJDK, depending on the changes to the source.
# 
# Copyright (c) 2012 Martijn Verburg <martijn.verburg@gmail.com>. All rights reserved.
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

export ALT_JDK_IMPORT_PATH=/home/openjdk/sources/jdk8_tl/build/linux-amd64_backup/j2sdk-image
echo "Exported ALT_JDK_IMPORT_PATH as $ALT_JDK_IMPORT_PATH"
echo "Executing partial build make JAVAC_MAX_WARNINGS=true JAVAC_WARNINGS_FATAL= OTHER_JAVACFLAGS="-Xmaxwarns 10000" &> build.log"
make JAVAC_MAX_WARNINGS=true JAVAC_WARNINGS_FATAL= OTHER_JAVACFLAGS="-Xmaxwarns 10000" &> build.log
