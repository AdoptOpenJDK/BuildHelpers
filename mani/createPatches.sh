#!/bin/bash

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
