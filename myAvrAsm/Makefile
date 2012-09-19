
PROJNAME=myAvrAsm

PLATFORM=WIN

SOURCES=myAvrAsm.cpp myAvrAsm.tab.c lex.yy.c
OUTPUTDIR=output

CXX=g++
CXXFLAGS=-Wall -Wl,--enable-auto-import -Wno-unknown-pragmas


ifeq ($(PLATFORM), WIN)
REMOVE_COMMAND=del
REMOVE_FLAGS=/F /S /Q
else
REMOVE_COMMAND=rm
REMOVE_FLAGS=rf
endif

INSTRUCTIONS=$(wildcard instructions/*.cpp)


all: clean mkdir executable 
ifeq ($(PLATFORM), WIN) 
	copy $(PROJNAME).exe $(OUTPUTDIR)
	copy example\*.* $(OUTPUTDIR)
else
	cp $(PROJNAME).exe $(OUTPUTDIR)
	cp example/* $(OUTPUTDIR)
endif

executable: prepare
	$(CXX) $(CXXFLAGS) -o $(PROJNAME) $(SOURCES) $(INSTRUCTIONS)

prepare: flex bison

flex: bison
	flex -i $(PROJNAME).l

bison:
	bison -d $(PROJNAME).y

mkdir: 
	-mkdir $(OUTPUTDIR)

clean:
	-$(REMOVE_COMMAND) $(REMOVE_FLAGS) $(PROJNAME) $(PROJNAME).exe $(OUTPUTDIR)
