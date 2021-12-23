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

#$(MAKECMDGOALS):

all clean:
	$(foreach DIR, $(SUB_DIRS), make -C $(DIR) $@;)

