#! /bin/bash
echo "Generating UPL man page..."
PANDOC_EXISTS=$(which pandoc)

if [ $PANDOC_EXISTS ]
   then
    # update the date of the markdown file
    cp upl.markdown upl.tmp
    date >> upl.tmp
    # first convert the markdown file to manpage
    pandoc -s upl.tmp -f markdown_github -t man -o upl.1
    # manpage must be zipped, `upl` is deleted
    gzip upl.1
    # move the new manpage zip file to the man directory
    sudo mv upl.1.gz /usr/share/man/man1/upl.1.gz
    # remove the temp file, should be the only thing that remains
    rm upl.tmp
    echo 'Done!'
  else
    echo 'pandoc required'
fi
