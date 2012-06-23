#!/bin/bash

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

# Get list of changed files from Mercurial
getChangedFiles=$(hg status | grep .java)

# Remove the lagging ? from the results from the above action, and split the long string (delimeter: space) into an array 
getChangedFiles=$(echo $getChangedFiles | tr -s " ?" " ")

# Loop through the list of fullpath filenames  
for javaFullPath in $getChangedFiles 
do
   homeDir="$HOME/sources/jdk"
   
   # save full path name into a working variable
   javaFullPathElements=$javaFullPath
   # extract .java file name from the full path name (working variable)
   javaFullPathElements=$(echo $javaFullPathElements | tr "/" " ")
   
   for javaFileName in $javaFullPathElements
   do
     echo "Class file [$javaFileName] has been changed according to Mercurial."
   done

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
