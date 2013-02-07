#!/usr/bin/awk -f

#
# countWarnings.sh - displays a table of statistics of the pending number of warnings when building the OpenJDK.
#
# Copyright (c) 2012, Stuart Marks <stuart.marks@oracle.com>, 
# Martijn Verburg <martijnverburg@gmail.com>. All rights reserved.
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

# This awk script should have a jdk/<name of log>.log file passed in 
# as its first and only argument
BEGIN {
  in_javac = 0
  number_of_compiler_invocations = 0
  number_of_warning_free_files = 0
  total_warnings = 0
  print "files warnings dir"
}
 
/^# Java sources/ { }
 
/^# Running javac:/ {
  in_javac = 1
  number_of_compiler_invocations += 1
  number_of_files = $4
  number_of_warnings = 0
  dir = $7
  gsub(/^.*jdk\//, "", dir)
}
 
/^[0-9][0-9]* warning/ { # match "1 warning" and "n warnings"
  if (in_javac) {
    number_of_warnings = $1
  }
}
 
/^# javac finished/ {
  in_javac = 0
  printf " %4d  %5d   %s\n", number_of_files, number_of_warnings, dir
  if (number_of_warnings == 0) {
    number_of_warning_free_files += 1
  }
  total_warnings += number_of_warnings
}
 
END {
  printf "\nnumber_of_compiler_invocations=%d number_of_warning_free_files=%d total_warnings=%d\n",
    number_of_compiler_invocations, number_of_warning_free_files, total_warnings
}
 
