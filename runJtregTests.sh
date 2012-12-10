#!/bin/bash

set -eu

#
# runJtregTests.sh - runs JTregTests given a valid package / group name.
#
# Copyright (c) 2012  Mani Sarkar <sadhak001@gmail.com> All rights reserved.
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
#
# This code is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 only  as
# published by the Free Software Foundation.  Oracle designates this
# particular file as subject to the "Classpath" exception as provided
# by Oracle in the LICENSE file that accompanied this code.
#
# This code is distributed in the hope that it will be useful  but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# version 2 for more details (a copy is included in the LICENSE file that
# accompanied this code).
#
# You should have received a copy of the GNU General Public License version
# 2 along with this work; if not  write to the Free Software Foundation 
# Inc.  51 Franklin St  Fifth Floor  Boston  MA 02110-1301 USA.
#

# Declare an array contain list of valid package names - case sensitive hence they must match any comparison checks  
declare -a openJDKTestPackages=("default" "all" "jdk_awt" "jdk_beans1" "jdk_io" "jdk_lang" "jdk_jfr" "jdk_math" "jdk_misc" "jdk_net" "jdk_nio1" "jdk_nio2"  "jdk_nio3" "jdk_security1" "jdk_rmi" "jdk_sound" "jdk_swing" "jdk_text" "jdk_util");
declare firstParam="";
declare rtnResult=0;

# funtion to iterate through the list of valid OpenJDK package names and searching for the input package name
function packageNameExists() {
  local testPackageName;

  # no match found  return 0
  rtnResult=0;

  # Loop through the valid names and compare it with the input string
  for testPackageName in "${openJDKTestPackages[@]}"
  do
    #echo {"$testPackageName" == "$firstParam"};
    if [[ "$testPackageName" == "$firstParam" ]];
    then
      # if you found a match return 1
      rtnResult=1;
      break;
    fi
  done
}

# function to display Usage message
displayUsageMessage() {
  echo ""
  echo ""runJtregTests.sh" has been invoked without a valid parameter."
  echo "" 
  echo "Usage: runJtregTests.sh <group/package name>"
  echo "e.g. runJtregTests.sh jdk_awt     ----- to run tests on the awt package"
  echo ""

  echo "Below is a list of packages to help with the usage"
  echo "=================================================="
  echo "default        - run default tests"
  echo "all            - run all tests"
  echo ""
  echo "jdk_awt        - run awt package tests"
  echo "jdk_beans1     - run beans package tests"
  echo "jdk_io         - run io package tests"
  echo "jdk_lang       - run language package tests"
  echo "jdk_jfr 	   - run jfr package tests"
  echo "jdk_math       - run math package tests"
  echo "jdk_misc       - run misc package tests"
  echo "jdk_net        - run net package tests"
  echo "jdk_nio1       - run nio package tests"
  echo "jdk_nio2       - run nio package tests"
  echo "jdk_nio3       - run nio package tests"
  echo "jdk_security1  - run security package tests"
  echo "jdk_rmi        - run rmi package tests"
  echo "jdk_sound      - run sound package tests"
  echo "jdk_swing      - run swing package tests"
  echo "jdk_text       - run text package tests"
  echo "jdk_util       - run util package tests"
  echo ""
}

# Display usage details if user calls runTestRigTests without any parameter  and exit the script.
if [[ $# -eq 0 ]]
then
  displayUsageMessage
  exit
fi

# call function with a parameter, result is returned in rtnResult
firstParam=$1;
packageNameExists;

# check if the package name check fails validity
if [[ $rtnResult -eq 0 ]];
then
   # if no match is found  display error  show the usage message and exit the script
   echo "[$1] is not a valid OpenJDK test package name. Please refer to the usage message below for a list of valid test package names."
   displayUsageMessage 
   exit
fi

# Perform the action by running the test for the inut package name 
echo "Tests for package [$1] are being performed. Results are recorded in the [$1.log] file stored locally..."
make $1 > $1.log
