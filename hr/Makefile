#
# Makefile for hr app
#


### Locations ###
ProjectDir = ..
LIB = $(ProjectDir)/modules/lib
BIN = $(ProjectDir)/bin
SCH = $(ProjectDir)/model

### Environment ###
#.EXPORT_ALL_VARIABLES:
export FGLLDPATH := $(LIB):$(BIN):$(FGLLDPATH)
export FGLDBPATH := $(SCH):$(FGLDBPATH)
export FGLIMAGEPATH := $(ProjectDir)/resources/image2font.txt:$(ProjectDir)/resources:$(ProjectDir)/images:$(ProjectDir):$(FGLDIR)/lib/image2font.txt:$(FGLDIR)/lib
export FGLRESOURCEPATH := $(ProjectDir)/resources
export DBPATH := $(ProjectDir)/data:$(DBPATH)
export DBDATE := DMY4/
export FGLPROFILE := $(ProjectDir)/data/db.prof:$(FGLPROFILE)
export FGLSOURCEPATH := $(ProjectDir)/hr:$(ProjectDir)/modules/Common:$(ProjectDir)/modules/OM:$(ProjectDir)/modules/UI:$(ProjectDir)/modules/Selection:$(ProjectDir)/webcomponents/api:$(FGLSOURCEPATH)


### Default Rules ###
.SUFFIXES: .4gl .42m .per .42f .42r

.4gl.42m:
	fglcomp $<

.per.42f:
	fglform $<



### Local vars ###


#
# Apps
#

bin_Apps = \
	$(BIN)/Emp_Main.42m \

bin_Objects =  \
	$(BIN)/Emp_Con.42m \
	$(BIN)/Employee.42m \

bin_Forms = \
	$(BIN)/Emp_ExtDash1-R1.42f \
	$(BIN)/Emp_ExtDash2-R1.42f \
	$(BIN)/Emp_ExtPhoto-R1.42f \
	$(BIN)/Emp_ExtPhoto.42f \
	$(BIN)/Emp_Hdr-R1.42f \
	$(BIN)/Emp_Hdr-R2.42f \
	$(BIN)/Emp_Hdr.42f \
	$(BIN)/Emp_Leave-R1.42f \
	$(BIN)/Emp_Leave-R2.42f \
	$(BIN)/Emp_Leave.42f \
	$(BIN)/Emp_List-R1.42f \
	$(BIN)/Emp_List-R2.42f \
	$(BIN)/Emp_List.42f \
	$(BIN)/Emp_Medical-R1.42f \
	$(BIN)/Emp_Medical-R2.42f \
	$(BIN)/Emp_Medical.42f \
	$(BIN)/Emp_Pay-R1.42f \
	$(BIN)/Emp_Pay-R2.42f \
	$(BIN)/Emp_Pay.42f \
	$(BIN)/Emp_Qualification-R1.42f \
	$(BIN)/Emp_Qualification-R2.42f \
	$(BIN)/Emp_Qualification.42f \
	$(BIN)/Emp_Review-R1.42f \
	$(BIN)/Emp_Review-R2.42f \
	$(BIN)/Emp_Review.42f \
	$(BIN)/Emp_Travel-R1.42f \
	$(BIN)/Emp_Travel-R2.42f \
	$(BIN)/Emp_Travel.42f \
	$(BIN)/Employee-R1.42f \
	$(BIN)/Employee-R2.42f \
	$(BIN)/Employee.42f \

hr_Apps = $(shell basename $(bin_Apps))

hr_Objects = $(shell basename $(bin_Objects))

hr_Forms = $(shell basename $(bin_Forms))


#
# Build
#

### Default build ###
all: $(bin_Apps) $(bin_Objects) $(bin_Forms)


$(bin_Apps) $(bin_Objects) $(bin_Forms) : $(hr_Apps) $(hr_Objects) $(hr_Forms)
	cp -a $? $(BIN)

clean :
	rm -f *.42? $(bin_Apps) $(bin_Objects) $(bin_Forms)

run: $(bin_Apps)
	cd $(BIN)
	fglrun $?

run-r1: $(bin_Apps)
	cd $(BIN)
	fglrun $? -R1

run-r2: $(bin_Apps)
	cd $(BIN)
	fglrun $? -R2

debug: $(hr_Apps)
	cd $(BIN)
	fglrun -d $?
