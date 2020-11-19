#
# Makefile for Common modules
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
Common = Common.42r
Apps = $(Common)



### Default build ###
all: $(Apps)



#
# Apps
#


Common_Objects =  \
	Common_Unit.42m \
	db.42m \
	str.42m \

$(Common) : $(Common_Objects)
	fgl2p -o $@ $(Common_Objects)


clean :
	rm -f *.42?

install :
	cp -a *.42? $(BIN)


run: $(Apps)
	fglrun $?
