#!/bin/sh
#
# Copyright (c) 2011, 2012, Oracle and/or its affiliates. All rights reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
#
# This code is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 only, as
# published by the Free Software Foundation.
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
# Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
# or visit www.oracle.com if you need additional information or have any
# questions.
#

script_dir=`dirname $0`
closed_script_dir="$script_dir/../../jdk/make/closed/autoconf"

# Create a timestamp as seconds since epoch
TIMESTAMP=`date +%s`

cat $script_dir/configure.ac  | sed -e "s|@DATE_WHEN_GENERATED@|$TIMESTAMP|" | autoconf -W all -I$script_dir - > $script_dir/generated-configure.sh
rm -rf autom4te.cache

if test -e $closed_script_dir/closed-hook.m4; then
  # We have closed sources available; also generate configure script
  # with closed hooks compiled in.
  cat $script_dir/configure.ac | sed -e "s|@DATE_WHEN_GENERATED@|$TIMESTAMP|" | \
    sed -e "s|AC_DEFUN_ONCE(\[CLOSED_HOOK\])|m4_include([$closed_script_dir/closed-hook.m4])|" | autoconf -W all -I$script_dir - > $closed_script_dir/generated-configure.sh
  rm -rf autom4te.cache
fi
