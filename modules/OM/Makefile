#
# Makefile for OM module
#

### Environment ###
#% FGLDBPATH := ../../bin:$(FGLDBPATH)


### Locations ###
BIN = ../../bin



### Default Rules ###
.SUFFIXES: .4gl .42m .per .42f .42r

.4gl.42m:
	fglcomp $<

.per.42f:
	fglform $<



### Local vars ###
OM = OM.42r
Apps = $(OM)



### Default build ###
all: $(Apps)



#
# Apps
#


OM_Objects =  \
	OM_Unit.42m \
	OM_.42m \

$(OM) : $(OM_Objects)
	fgl2p -o $@ $(OM_Objects)


clean :
	rm -f *.42?

install :
	cp -a *.42? $(BIN)


run: $(hr0)
	fglrun $<
