#
# Master Makefile
#

SUB_DIRS = $(wildcard modules/[A-Z]*) webcomponents/api hr

default:
	make all

run:
	make -C hr run

run-r1:
	make -C hr run-r1

run-r2:
	make -C hr run-r2

doc:
	fglcomp --build-doc overview.4gl

cleanrootdoc:
	rm index*.html overview*.html overview*.xa fgldoc.css allclasses*.html

#$(MAKECMDGOALS):

all clean cleandoc: cleanrootdoc
	$(foreach DIR, $(SUB_DIRS), make -C $(DIR) $@;)

