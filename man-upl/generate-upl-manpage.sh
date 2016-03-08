#! /bin/bash
echo "Generating UPL man page..."
PANDOC_EXISTS=$(which pandoc)

if [ $PANDOC_EXISTS ]
   then
    # update the date of the markdown file
    echo y
    cp upl.markdown upl.tmp
    echo z
    date >> upl.tmp
    echo a
    # first convert the markdown file to manpage
    pandoc -s upl.tmp -f markdown_github -t man -o upl.1
    echo b
    # manpage must be zipped, `upl` is deleted
    gzip upl.1
    echo c
    # move the new manpage zip file to the man directory
    sudo mv upl.1.gz /usr/share/man/man1/upl.1.gz
    echo d
    # remove the temp file, should be the only thing that remains
    rm upl.tmp
    echo e
  else
    echo 'pandoc required'
fi
