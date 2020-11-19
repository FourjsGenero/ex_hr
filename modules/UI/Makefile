#
# Makefile for UI module
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
UI = UI.42r
Apps = $(UI)



### Default build ###
all: $(Apps)



#
# Apps
#


UI_Objects =  \
	UI_Unit.42m \
	UI_.42m \

$(UI) : $(UI_Objects)
	fgl2p -o $@ $(UI_Objects)


clean :
	rm -f *.42?

install :
	cp -a *.42? $(BIN)


run: $(Apps)
	fglrun $?
