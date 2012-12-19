#!/bin/bash

set -eu

#
# createPatches.sh - generates one or more .patch files from the changed .java files in the local mercurial repository.
#
# Copyright (c) 2012, Mani Sarkar <sadhak001@gmail.com> All rights reserved.
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


displayUsageMessage(){
	echo "---------------------------------------------------"
	echo "Usage : bash createPatches.sh "
	echo "This script is supposed to be placed in <OpenJdk_Source_Dir>/jdk8_tl/jdk/ "
	echo "<OpenJdk_Source_Dir>  is the location where you have cloned OpenJdk repository  "		
	echo "---------------------------------------------------"
}


homeDir=`pwd`
openJdkBaseDir="jdk8_tl/jdk"
if [[ "$homeDir" != *jdk8_tl/jdk ]]
then
	displayUsageMessage
	exit
fi

# Get list of changed files from Mercurial
getChangedFiles=$(hg status | grep .java)

# Remove the lagging ? from the results from the above action, and split the long string (delimeter: space) into an array 
getChangedFiles=$(echo $getChangedFiles | tr -s " ?" " ")

# Loop through the list of fullpath filenames  
for javaFullPath in $getChangedFiles 
do  
   
   # save full path name into a working variable
   javaFullPathElements=$javaFullPath
   # break full path to java class name into strings and assign it to array (working variable)
   javaFullPathElements=($(echo $javaFullPathElements | tr "/" " "))
   # assign .java file name from javaFullPathElements array to javaFileName (working variable)
   javaFileName=${javaFullPathElements[${#javaFullPathElements[@]}-1]}

   # define the diff output file with the .patch extension 
   javaPatchFileName="$javaFileName.patch"
 
   hgDiffCmd="hg diff $homeDir/$javaFullPath"
   $hgDiffCmd > $javaPatchFileName
   if [ -s $javaPatchFileName ]; then
     echo "Patch file for class [$javaPatchFileName] has been created and placed in the local folder." 
   else 
     rm $javaPatchFileName 
     echo "Zero byte patch file [$javaPatchFileName] for class [$javaFileName] has been deleted." 
   fi
done

