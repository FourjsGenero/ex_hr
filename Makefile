#
# Master Makefile
#

SUB_DIRS = $(wildcard modules/*) hr

default:
	make all

$(MAKECMDGOALS):
	$(foreach DIR, $(SUB_DIRS), make -C $(DIR) $@;)

cleaner:
	make clean
	rm -f bin/*.42?

