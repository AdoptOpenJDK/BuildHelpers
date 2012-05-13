#!/bin/bash
gawk '
 
BEGIN {
  injavac = 0
  ncompiles = 0
  zerowarn = 0
  totalwarn = 0
  print "files warnings dir"
}
 
/^# Java sources/ { }
 
/^# Running javac:/ {
  injavac = 1
  ncompiles += 1
  nfiles = $4
  nwarn = 0
  dir = $7
  gsub(/^.*jdk\//, "", dir)
}
 
/^[0-9][0-9]* warning/ { # match "1 warning" and "n warnings"
  if (injavac) {
    nwarn = $1
  }
}
 
/^# javac finished/ {
  injavac = 0
  printf " %4d  %5d   %s\n", nfiles, nwarn, dir
  if (nwarn == 0) {
    zerowarn += 1
  }
  totalwarn += nwarn
}
 
END {
  print ""
  printf "ncompiles=%d zerowarn=%d totalwarn=%d\n",
    ncompiles, zerowarn, totalwarn
}
 
' "$@"

