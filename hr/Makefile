#
# Makefile for hr app
#

### Environment ###
#% FGLDBPATH := ../../bin:$(FGLDBPATH)


### Locations ###
BIN = ../bin



### Default Rules ###
.SUFFIXES: .4gl .42m .per .42f .42r

.4gl.42m:
	fglcomp $<

.per.42f:
	fglform $<



### Local vars ###
hr = hr.42r
Apps = $(hr)



### Default build ###
all: $(Apps)



#
# Apps
#


hr_Objects =  \
	Emp_Unit.42m \
	Emp_View.42m \

hr_Modules = \
	Employee.42m \

hr_Forms = \
	Emp_Hdr.42f \
	Emp_Leave.42f \
	Emp_List.42f \
	Emp_Pay.42f \
	Emp_Qualification.42f \
	Emp_Review.42f \
	Emp_Sick.42f \
	Emp_Travel.42f \
	Employee.42f \

$(hr) : $(hr_Objects) $(hr_Modules)
	fgl2p -o $@ $(hr_Objects)


clean :
	rm -f *.42?

install :
	cp -a *.42? $(BIN)


run: $(Apps)
	fglrun $?
