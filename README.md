Digital edition of Scott Joplin Rags
====================================

This repository is a digital edition of piano rags by Scott Joplin in
the Humdrum file format.  Tools for processing the encodings in this
format on the command-line can be found online at
https://github.com/humdrum-tools

The encodings are located in the 'kern' directory.
Scans of the source edition can be downloaded from 
[kernScores](http://kern.humdrum.org) with this command:
```bash
   make reference
```

These digital scores can also be found as a submodule in the 
[humdrum-data](https://github.com/humdrum-tools/humdrum-data) repository.


Data processing tools and other resources
=========================================

These digital scores may also be found on the kernScores website:
*    http://kernscores.stanford.edu/browse?l=joplin

with mirrors at:
*    http://kern.humdrum.org/browse?l=joplin
*    http://kern.ccarh.org/browse?l=joplin

which includes dynamic conversions to other data formats.  

The [Humdrum Extras](http://extras.humdrum.org) command-line programs 
can download these files from kernScores.  A quick method of downloading:
```bash
    mkdir joplin
    cd joplin
    humsplit h://joplin
```
To get online access to a single chorale, for example to transpose the first chorale to C major:
```bash
   transpose -k c h://joplin/mapleleaf.krn
```

To interface to the Humdrum Toolkit commands, use the humcat command to download to standard input (the -s option is needed when downloading multiple files):
```bash
   humcat -s h://joplin | census -k
```


Makefile
========

The makefile provided in the base directory includes example data
processing commands.  Type ```make``` when in the same directory as the
makefile to list commands that can be run with the makefile.

If the command ```which make``` reports that the make command cannot
be found, then you must install it.  In linux, this comamnd might
install it:
```bash
   sudo apt-get install build-essential
   # or
   sudo yum install build-essential
```

In OS X Mavericks or later, install the Xcode command-line tools:
```bash
   xcode-select --install
```

In Cygwin on MS Windows, re-run the cygwin install program and make sure
that the development tools are included in the installation packages.



