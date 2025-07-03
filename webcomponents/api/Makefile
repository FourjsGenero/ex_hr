#
# Makefile for wc3chart API
#

### Locations ###
LIB = ../../modules/lib
BIN = ../../bin

### Environment ###
FGLLDPATH := $(LIB):$(FGLLDPATH)


### Default Rules ###
.SUFFIXES: .4gl .42m .per .42f .42r

.4gl.42m:
	fglcomp $<

.per.42f:
	fglform $<



### Local vars ###
Unit = unit_Common.42m

Shared_Objects =  \
	$(BIN)/wc_c3chart.42m \
	$(BIN)/wc_c3chart.42f \

Local_Objects = $(shell basename -a $(Shared_Objects))


#
# Build
#

### Default build ###
all: $(Shared_Objects)

$(Shared_Objects) : $(Local_Objects)
	cp -a $(Local_Objects) $(BIN)

clean :
	rm -f *.42? $(Shared_Objects)

cleandoc :
	rm -f *.html *.xa

run: $(Unit)
	fglrun $?

