cd $HOME/sources/jdk

. ./jdk8-env.sh
cd make
# make clean
make JAVAC_MAX_WARNINGS=true JAVAC_WARNINGS_FATAL= OTHER_JAVACFLAGS="-Xmaxwarns 10000" &> build.log
cp build.log build.log.original
