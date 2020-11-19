#
# Makefile for Selection module
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
Selection = Selection.42r
Apps = $(Selection)



### Default build ###
all: $(Apps)



#
# Apps
#


Selection_Objects =  \
	Selection_Unit.42m \
	Selection.42m \

$(Selection) : $(Selection_Objects)
	fgl2p -o $@ $(Selection_Objects)


clean :
	rm -f *.42?

install :
	cp -a *.42? $(BIN)


run: $(Apps)
	fglrun $?
