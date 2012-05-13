cd ~/sources/jdk
# hg revert -r .
hg revert -a
find . -name "*.orig" -exec rm {} \;
hg pull
hg update
