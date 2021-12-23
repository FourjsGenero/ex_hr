#
# Makefile for Selection module
#

### Locations ###
LIB = ../lib

### Environment ###
FGLLDPATH := $(LIB):$(FGLLDPATH)


### Default Rules ###
.SUFFIXES: .4gl .42m .per .42f .42r

.4gl.42m:
	fglcomp $<

.per.42f:
	fglform $<



### Local vars ###
Unit = unit_Selection.42m

Shared_Objects =  \
	$(LIB)/Selection.42m \

Local_Objects = $(shell basename $(Shared_Objects))


#
# Build
#

### Default build ###
all: $(Unit)

$(Unit) : $(Shared_Objects)

$(Shared_Objects) : $(Local_Objects)
	cp -a $(Local_Objects) $(LIB)

clean :
	rm -f *.42? $(Shared_Objects)

run: $(Unit)
	fglrun $?

