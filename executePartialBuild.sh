#!/bin/bash
export ALT_JDK_IMPORT_PATH=/home/openjdk/sources/jdk8_tl/build/linux-amd64_backup/j2sdk-image
echo "Exported ALT_JDK_IMPORT_PATH as $ALT_JDK_IMPORT_PATH"
echo "Executing partial build make JAVAC_MAX_WARNINGS=true JAVAC_WARNINGS_FATAL= OTHER_JAVACFLAGS="-Xmaxwarns 10000" &> build.log"
make JAVAC_MAX_WARNINGS=true JAVAC_WARNINGS_FATAL= OTHER_JAVACFLAGS="-Xmaxwarns 10000" &> build.log
