#! /bin/bash
echo 'Generating UPL man page...'
PANDOC_EXISTS=$(which pandoc)
# if you help out, put your name here :)
declare -a AUTHORS=('Leo Rudberg')
MAN_HEADER="% upl(1)\n% $(echo ${AUTHORS[*]})\n% $(date)\n"

if [ $PANDOC_EXISTS ]
then
  # start with the header, then append the markdown file
  echo -e $MAN_HEADER > upl.tmp
  cat upl.markdown >> upl.tmp
  # then convert the new markdown file to manpage
  pandoc -s upl.tmp -f markdown -t man -o upl.1
  # manpage must be zipped, `upl.1` is deleted
  gzip upl.1
  # move the new manpage zip file to the man directory
  sudo mv upl.1.gz /usr/share/man/man1/upl.1.gz
  # remove the temp file, should be the only thing that remains
  rm upl.tmp
  echo 'Done!'
else
  echo 'pandoc required'
fi
