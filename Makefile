## joplin-rag Makefile
##
## Programmer:    Craig Stuart Sapp <craig@ccrma.stanford.edu>
## Creation Date: Tue Jun  3 12:23:48 PDT 2014
## Last Modified: Tue Jun  3 14:52:35 PDT 2014
## Filename:      Makefile
## Syntax:        GNU/BSD makefile
##
## Description:   Makefile for basic processing Humdrum data files 
##                for the music of Scott Joplin.
##
## To run this makefile, type "make" (without quotes) to see a list 
## of the makefile actions which can be done.
##

# targets which don't actually refer to files:
.PHONY : abc kernscores lilypond mei midi midi-norep musedata musicxml notearray pdf-abc pdf-lilypond pdf-musedata reference-edition

all:
	@echo ''
	@echo 'Run this makefile with one of the following labels:'
	@echo '   "[0;32mmake update[0m"      : download any new changes from online repository.'
	@echo '   "[0;32mmake reference[0m"   : download PDF scans of reference editions.'
	@echo '   "[0;32mmake clean[0m"       : delete data directories created by this makefile.'
	@echo ''
	@echo 'Commands requiring the Humdrum Toolkit to be installed:'
	@echo '   "[0;32mmake census[0m"      : run the census command on all files.'
	@echo ''
	@echo 'Commands requiring Humdrum Extras to be installed.'
	@echo '   "[0;32mmake abc[0m"         : convert to ABC+ files.'
	@echo '   "[0;32mmake kernscores[0m"  : download equivalent from kernscores.'
	@echo '   "[0;32mmake mei[0m"         : convert to MEI files.'
	@echo '   "[0;32mmake midi[0m"        : convert to MIDI files (full repeats)'
	@echo '   "[0;32mmake midi-norep[0m"  : convert to MIDI files (no repeats)'
	@echo '   "[0;32mmake musedata[0m"    : convert to MuseData files.'
	@echo '   "[0;32mmake musicxml[0m"    : convert to MusicXML files.'
	@echo '   "[0;32mmake notearray[0m"   : create notearray files.'
	@echo '   "[0;32mmake searchindex[0m" : create themax search index.'
	@echo ''
	@echo 'Commands requiring other software to be installed.'
	@echo '   "[0;32mmake pdf-abc[0m"     : convert to PDF files with abcm2ps.'
	@echo '   "[0;32mmake pdf-lilypond[0m": convert to PDF files with lilypond.'
	@echo '   "[0;32mmake pdf-musedata[0m": convert to PDF files with muse2ps.'
	@echo ''


############################################################################
##
## General make commands:
##

##############################
#
# make update -- Download any changes in the Github repositories for
#      each composer.  To download for the first time, type:
#           git clone https://github.com/craigsapp/joplin-rags
#

update:       github-pull
pull:         github-pull
github:       github-pull
githubupdate: github-pull
githubpull:   github-pull
github-pull: git-check git-repository-check
	git pull



##############################
#
# make kernscores -- Download scores from the kernScores website
#   (http://kern.humdrum.org).  In theory these are the same as the 
#   files in the kern directory.
#

kernscores: humdrum-extras-check
	mkdir -p kernscores; (cd kernscores && humsplit h://joplin)
	@echo "[0;32m"
	@echo "*** Downloaded data from kernScores website into '[0;31mkernscores[0;32m' directory."
	@echo "[0m"



##############################
##
## make reference-edition -- Download scans of the source edition for the
##    encodings of Joplin's Rags from the kernScore website.
##

pdf:           reference-edition
pdfs:          reference-edition
webpdf:        reference-edition
webpdfs:       reference-edition
reference:     reference-edition
reference-pdf: reference-edition
reference-edition:
	-mkdir reference-edition
ifeq ($(shell which wget),)
ifeq ($(shell which curl),)
	# No wget or curl, so don't know how to download
	@echo "[0;31m"
	@echo "*** Error: don't know how to download from the internet."
	@echo "*** Install wget or curl on your computer and try again."
	@echo "[0m"
else
	# Don't have wget but have curl
	for file in kern/*.krn; do \
	   TBASE=`basename $$file .krn`; \
	   echo "Downloading reference-edition/$$TBASE.pdf"; \
	   curl \
	      "http://kern.humdrum.org/data?l=joplin&file=$$TBASE.krn&format=pdf" \
	      -o reference-edition/$$TBASE.pdf >& /dev/null; \
	done
	@echo "[0;32m"
	@echo "*** Download PDF files in '[0;31mreference-edition[0;32m' directory."
	@echo "[0m"
endif
else
	# Have wget
	for file in kern/*.krn; do \
	   TBASE=`basename $$file .krn`; \
	   echo "Downloading reference-edition/$$TBASE.pdf"; \
	   wget -w 3 \
	      "http://kern.humdrum.org/data?l=joplin&file=$$TBASE.krn&format=pdf" \
	      -O reference-edition/$$TBASE.pdf >& /dev/null; \
	done
	@echo "[0;32m"
	@echo "*** Download PDF files in '[0;31mreference-edition[0;32m' directory."
	@echo "[0m"
endif



##############################
#
# make clean -- Remove all automatically generated or downloaded data files.  
#     Make sure that you have not added your own content into the directories 
#     in which these derivative files are located; otherwise, these will be 
#     deleted as well.
#

clean:
	-rm -rf abc
	-rm -rf kernscores
	-rm -rf lilypond
	-rm -rf mei
	-rm -rf midi
	-rm -rf midi-norep
	-rm -rf musedata
	-rm -rf musicxml
	-rm -rf notearray
	-rm -rf pdf-abc
	-rm -rf pdf-lilypond
	-rm -rf pdf-musedata
	-rm -rf reference-edition
	-rm searchindex.dat



############################################################################
##
## Humdrum Extras related make commands:
##

##############################
#
# make midi -- Create midi files for music, expanding repeats.
#

midi: humdrum-extras-check
	mkdir -p midi
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;                                \
	   echo Creating midi/$$TBASE.mid;				\
	   thrux $$file | hum2mid -o midi/$$TBASE.mid;			\
	done
	@echo "[0;32m"
	@echo "*** Created midi data in '[0;31mmidi[0;32m' directory."
	@echo "[0m"



##############################
#
# make midi-norep -- Create midi files for music, taking only second
#     endings (performance sequence with minimal repeats).
#

norep:      midi-norep
midinorep:  midi-norep
midi-norep: humdrum-extras-check
	mkdir -p midi-norep
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;                                \
	   echo Creating midi/$$TBASE.mid;				\
	   thrux -v norep $$file | hum2mid -o midi-norep/$$TBASE.mid;	\
	done
	@echo "[0;32m"
	@echo "*** Created midi data in '[0;31mmidi-norep[0;32m' directory."
	@echo "[0m"



##############################
#
# make notearray -- Create notearray files (useful for processing data
# in matlab).  Output is stored in a directory called "notearray".
#

notearray: humdrum-extras-check
	mkdir -p notearray
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;                                \
	   echo Creating notearray/$$TBASE.dat;				\
	   notearray -jicale --mel $$file 				\
		> notearray/$$TBASE.dat;				\
	done
	@echo "[0;32m"
	@echo "*** Created notearray data in '[0;31mnotearray[0;32m' directory."
	@echo "[0m"



##############################
#
# make abc -- Create ABC+ files (useful for printing with abcm2ps).
# Output is stored in a directory called "abc".
#

abc: humdrum-extras-check
	mkdir -p abc
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;				\
	   echo Creating abc/$$TBASE.abc;				\
	   hum2abc $$file > abc/$$TBASE.abc;				\
	done
	@echo "[0;32m"
	@echo "*** Created abc data in '[0;31mabc[0;32m' directory."
	@echo "[0m"



##############################
#
# make pdf-abc -- Create PDF files with abcm2ps.
# Output is stored in a directory called "pdf-abc".
#

pdf-abc: abcm2ps-check ps2pdf-check humdrum-extras-check
	mkdir -p pdf-abc
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;				\
	   echo Creating pdf-abc/$$TBASE.pdf;				\
	   hum2abc $$file |		  				\
	   abcm2ps - -O - |		  				\
	   ps2pdf -sPAPERSIZE=letter - > pdf-abc/$$TBASE.pdf;		\
	done
	@echo "[0;32m"
	@echo "*** Created PDF data in '[0;31mpdf-abc[0;32m' directory."
	@echo "[0m"



##############################
#
# make musedata -- Create musedata files (useful for printing with muse2ps).
# Output is stored in a directory called "musedata".
#

musedata: humextra-check
	mkdir -p musedata
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;				\
	   echo Creating musedata/$$TBASE.msd;				\
	   autostem $$file | hum2muse   				\
		> musedata/`basename $$file .krn`.msd;			\
	done
	@echo "[0;32m"
	@echo "*** Created musedata data in '[0;31mmusedata[0;32m' directory."
	@echo "[0m"



##############################
#
# make pdf-musedata -- Create PDF files of graphical notation using muse2ps:
#     http://muse2ps.ccarh.org
#     https://github.com/musedata/muse2ps
# Output is stored in a directory called "pdf-musedata".
#
# To print with this method, you need to install muse2ps from the above
# website, as well as the GhostScript package.  In linux, the ps2pdf
# program can be installed with "yum install ghostscript", or 
# "apt-get install ghostscript".  In OS X if you have installed homebrew:
# "brew install ghostscript", or "port install ghostscript" if you are
# using MacPorts.
#

pdf-musedata: ps2pdf-check muse2ps-check humdrum-extras-check
	mkdir -p pdf-musedata
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;			        \
	   echo Creating pdf-musedata/$$TBASE.pdf;			\
	   autostem $$file | hum2muse | muse2ps =z16j 			\
	      | ps2pdf -sPAPERSIZE=letter - 				\
		> pdf-musedata/$$TBASE.pdf;				\
	done
	@echo "[0;32m"
	@echo "*** Created PDF files in '[0;31mpdf-musedata[0;32m' directory."
	@echo "[0m"



##############################
#
# make mei -- Create MEI files (useful for printing with verovio).
# Output is stored in a directory called "mei".
#

MEI: mei
mei: humdrum-extras-check
	mkdir -p mei
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;                                \
	   echo Creating mei/$$TBASE.mei;				\
	   autostem $$file | hum2mei > mei/$$TBASE.mei;			\
	done
	@echo "[0;32m"
	@echo "*** Created MEI data in '[0;31mmei[0;32m' directory."
	@echo "[0m"



##############################
#
# make musicxml -- Create MusicXML files, which are useful for processing with
# various programs/systems.  Output is stored in a directory called "musicxml".
#

musicxml: humdrum-extras-check
	mkdir -p musicxml
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;				\
	   echo Creating musicxml/$$TBASE.xml;				\
	   autostem $$file | hum2xml > musicxml/$$TBASE.xml;		\
	done
	@echo "[0;32m"
	@echo "*** Created MusicXML data in '[0;31mmusicxml[0;32m' directory."
	@echo "[0m"



##############################
#
# make lilypond -- Create lilypond files.
# Output is stored in a directory called "lilypond".
#

lilypond: humdrum-extras-check
	mkdir -p lilypond
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;				\
	   echo Creating lilypond/$$TBASE.ly;				\
	   autostem $$file | hum2xml | musicxml2ly - -o-   		\
	       > lilypond/$$TBASE.ly;					\
	done
	@echo "[0;32m"
	@echo "*** Created lilypond data in '[0;31mlilypond[0;32m' directory."
	@echo "[0m"



##############################
#
# make pdf-lilypond -- Create lilypond files.
# Output is stored in a directory called "lilypond".
#

pdf-lilypond: humdrum-extras-check lilypond-check
	mkdir -p pdf-lilypond
	for file in kern/*.krn;						\
	do								\
	   TBASE=`basename $$file .krn`;				\
	   echo Creating pdf-lilypond/%%TBASE.pdf;			\
	   autostem $$file | hum2xml | musicxml2ly - -o-   		\
	   | lilypond -f pdf -o pdf-lilypond/$$TBASE - ;		\
	done
	@echo "[0;32m"
	@echo "*** Created PDF data in '[0;31mpdf-lilypond[0;32m' directory."
	@echo "[0m"



##############################
#
# make searchindex -- Create a themax search index file.  The searchindex.dat
# file can be used with the themax program to search for melodic/rhythmic 
# patterns in the data, such as searching for two successive rising 
# perfect fourths:
#
# Counting the number of occurrences within the data (all voices):
#    themax -I "+P4 +P4" searchindex.dat --total
#
# Count the number of matches by each voice separately:
#    grep ::1 searchindex.dat | themax -I "+P4 +P4" --count
#       (finds 53 matches in the bass part)
#    grep ::2 searchindex.dat | themax -I "+P4 +P4" --count
#       (finds 9 matches in the tenor part)
#    grep ::3 searchindex.dat | themax -I "+P4 +P4" --count
#       (finds 0 matches in the alto part)
#    grep ::4 searchindex.dat | themax -I "+P4 +P4" --count
#       (finds 2 matches in the soprano part)
#
# Counting the number of matches in a file:
#    themax -I "+P4 +P4" searchindex.dat --count
#
# Showing the note-number location of the matches:
#    themax -I "+P4 +P4" searchindex.dat --loc
#
# Resolve note-number locations to measure/beat locations:
#    themax -I "+P4 +P4" searchindex.dat --loc | theloc
#
# Extract measures which contain the matches in a particular work:
#    tindex kern/mapleleaf.krn | themax -I "+P4 +P4" --loc | theloc --mark | myank --marks
#
#

search:	     	searchindex
search-index:	searchindex
searchindex: humdrum-extras-check
	tindex kern/*.krn > searchindex.dat
	@echo "[0;32m"
	@echo "*** Try the command:"
	@echo "***    [0;31mthemax -P \"d e c a b g\" searchindex.dat --loc | theloc[0;32m"
	@echo "*** To search for the introduction theme to the Entertainer."
	@echo "*** The result should be:"
	@echo "***    [0;31mkern/entertainer.krn::1	1=1B1-6=1B2.5 7=2B1-12=2B2.5[0;32m"
	@echo "***    [0;31mkern/entertainer.krn::2	1=1B1-6=1B2.5 7=2B1-12=2B2.5[0;32m"
	@echo "*** Which mean that the melodic pitch sequence [0;31m"d e c a b g"[0;32m occurs four"
	@echo "*** times in the Entertainer, twice each in parts 1 (LH) and 2 (RH) at m1 beat 1 to"
	@echo "*** m1 beat 2.5 and m2b1 to m2b2.5.  No other rags have this melodic sequence."
	@echo "[0m"
	



############################################################################
##
## standard Humdrum Toolkit related make commands:
##

##############################
#
# make census -- Count notes in all score for all composers.
#

census: humdrum-toolkit-check
	census -k kern/*.krn



############################################################################
##
## Check to see if various software packages are installed.
##

##############################
##
## make git-check -- Check to see if the git program is available.
##    If not, then make suggestions for how to install.
##

git-check:
ifeq ($(shell which git),)
	@echo "[0;31m"
	@echo "*** Error: You must first install the git program."
	@echo "*** In Linux, try:"
	@echo "***    [0;32sudo yum install git0;31m"
	@echo "*** or"
	@echo "***    [0;32sudo apt-get install git0;31m"
	@echo "*** In OS X, install Homebrew ([0;31mhttps://brew.sh[0;31m) and then type:"
	@echo "***    [0;32brew install git0;31m"
	@echo "[0m"
	exit 1
endif



##############################
##
## make git-repository-check -- Check to see if the directory is part of
##    a git repository.
##

git-repository-check:
ifeq ($(wildcard .git),)
	@echo "[0;31m"
	@echo "*** Error: To automatically update, you need to have installed"
	@echo "*** this directory with the git command:"
	@echo "***    [0;32mgit clone https://github.com/craigsapp/joplin-rags[0;31m"
	@echo "[0m"
	exit 1
endif



##############################
##
## make ps2pdf-check -- Check to see if the ps2pdf program, which is a script
##    in the GhostScript software package, is available.  If not, then make
##    suggestions for how to install.
##

ps2pdf-check:
ifeq ($(shell which ps2pdf),)
	@echo "[0;31m"
	@echo "*** Error: You must first install ps2pdf from the GhostScript package".
	@echo "*** In Linux, try:"
	@echo "***    [0;32sudo yum install ghostscript0;31m"
	@echo "*** or"
	@echo "***    [0;32sudo apt-get install ghostscript0;31m"
	@echo "*** In OS X, install Homebrew ([0;31mhttps://brew.sh[0;31m) and then type:"
	@echo "***    [0;32brew install ghostscript0;31m"
	@echo "[0m"
	exit 1
endif



##############################
##
## make abcm2ps-check -- Check to see if the abcm2ps program is available.
##    If not, then make suggestions for how to install.
##

abcm2ps-check:
ifeq ($(shell which abcm2ps),)
	@echo "[0;31m"
	@echo "*** Error: You must first install abcm2ps from:"
	@echo "***    [0;32mhttp://moinejf.free.fr[0;31m"
	@echo "[0m"
	exit 1
endif



##############################
##
## make muse2ps-check -- Check to see if the muse2ps program is available.
##    If not, then make suggestions for how to install.
##

muse2ps-check:
ifeq ($(shell which muse2ps),)
	@echo "[0;31m"
	@echo "*** Error: You must first install muse2ps from:"
	@echo "***    [0;32mhttp://muse2ps.ccarh.org[0;31m"
	@echo "[0m"
	exit 1
endif



##############################
##
## make lilypond-check -- Check to see if the lilypond program is available.
##    If not, then make suggestions for how to install.
##

lilypond-check:
ifeq ($(shell which lilypond),)
	@echo "[0;31m"
	@echo "*** Error: You must first install lilypond."
	@echo "*** In Linux, try:"
	@echo "***    [0;32sudo yum install lilypond0;31m"
	@echo "*** or"
	@echo "***    [0;32sudo apt-get install lilypond0;31m"
	@echo "*** In OS X, install Homebrew ([0;31mhttps://brew.sh[0;31m) and then type:"
	@echo "***    [0;32brew install lilypond0;31m"
	@echo "[0m"
	exit 1
endif



##############################
##
## make humdrum-toolkit-check -- Check to see if the Humdrum Toolkit package
##    is available.  If not, then make suggestions for how to install.
##

humdrum-toolkit-check:
ifeq ($(shell which humdrum),)
	@echo "[0;31m"
	@echo "*** Error: You must first install the Humdrum Toolkit. See:"
	@echo "***    [0;32mhttps://github.com/humdrum-tools/humdrum-tools[0;31m"
	@echo "[0m"
	exit 1
endif



##############################
##
## make humdrum-extras-check -- Check to see if the Humdrum Extras package
##    is available.  If not, then make suggestions for how to install.
##

humextra-check:
humdrumextra-check:
humdrum-extra-check:
humdrum-extras-check:
ifeq ($(shell which keycor),)
	@echo "[0;31m"
	@echo "*** Error: You must first install the Humdrum Extras. See:"
	@echo "***    [0;32mhttps://github.com/humdrum-tools/humdrum-tools[0;31m"
	@echo "[0m"
	exit 1
endif


