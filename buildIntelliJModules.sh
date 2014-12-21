#!/bin/bash

#
# buildIntelliJModules.sh - generates the IntelliJ modules for JDK 9.
#
# Copyright (c) 2014, Will May <will.j.may@gmail.com> All rights reserved.
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

pushd /home/openjdk/dev/jdk9_dev/jdk
for D in src/*; do
  moduleName=`basename $D`
  echo '<?xml version="1.0" encoding="UTF-8"?>' > $moduleName.iml
  echo '<module type="JAVA_MODULE" version="4">' >> $moduleName.iml
  echo '  <component name="NewModuleRootManager" inherit-compiler-output="false">' >> $moduleName.iml
  echo "    <output url=\"file://\$MODULE_DIR\$/../build/linux-x86_64-normal-server-release/jdk/modules/$moduleName\" />" >> $moduleName.iml
  echo "    <output-test url=\"file://\$MODULE_DIR\$/out/test/$moduleName\" />" >> $moduleName.iml
  echo '    <exclude-output />' >> $moduleName.iml
  echo "    <content url=\"file://\$MODULE_DIR\$/$D\">" >> $moduleName.iml
  if [ -e $D/share/classes ]; then
    echo "      <sourceFolder url=\"file://\$MODULE_DIR\$/$D/share/classes\" isTestSource=\"false\" />" >> $moduleName.iml
  fi
  if [ -e $D/unix/classes ]; then
    echo "      <sourceFolder url=\"file://\$MODULE_DIR\$/$D/unix/classes\" isTestSource=\"false\" />" >> $moduleName.iml
  fi
  if [ -e $D/linux/classes ]; then
    echo "      <sourceFolder url=\"file://\$MODULE_DIR\$/$D/linux/classes\" isTestSource=\"false\" />" >> $moduleName.iml
  fi
  if [ -e $D/share/native ]; then
    echo "      <sourceFolder url=\"file://\$MODULE_DIR\$/$D/share/native\" isTestSource=\"false\" />" >> $moduleName.iml
  fi
  if [ -e $D/unix/native ]; then
    echo "      <sourceFolder url=\"file://\$MODULE_DIR\$/$D/unix/native\" isTestSource=\"false\" />" >> $moduleName.iml
  fi
  if [ -e $D/linux/native ]; then
    echo "      <sourceFolder url=\"file://\$MODULE_DIR\$/$D/linux/native\" isTestSource=\"false\" />" >> $moduleName.iml
  fi
  if [ -e $D/share/conf ]; then
    echo "      <sourceFolder url=\"file://\$MODULE_DIR\$/$D/share/conf\" type=\"java-resource\" />" >> $moduleName.iml
  fi
  if [ -e $D/unix/conf ]; then
    echo "      <sourceFolder url=\"file://\$MODULE_DIR\$/$D/unix/conf\" type=\"java-resource\" />" >> $moduleName.iml
  fi
  if [ -e $D/linux/conf ]; then
    echo "      <sourceFolder url=\"file://\$MODULE_DIR\$/$D/linux/conf\" type=\"java-resource\" />" >> $moduleName.iml
  fi
  echo '    </content>' >> $moduleName.iml
  echo '    <orderEntry type="inheritedJdk" />' >> $moduleName.iml
  echo '    <orderEntry type="sourceFolder" forTests="false" />' >> $moduleName.iml
  echo '  </component>' >> $moduleName.iml
  echo '</module>' >> $moduleName.iml
done
popd
