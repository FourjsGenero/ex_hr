#
# Makefile for UI module
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
Unit = unit_UI.42m

Shared_Objects =  \
	$(LIB)/UI_.42m \

Local_Objects = $(shell basename -a $(Shared_Objects))


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

cleandoc :
	rm -f *.html *.xa

run: $(Unit)
	fglrun $?

