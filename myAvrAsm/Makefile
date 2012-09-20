
PROJNAME=myAvrAsm

SOURCES=myAvrAsm.cpp myAvrAsm.tab.c lex.yy.c
OUTPUTDIR=output
TARGET=$(PROJNAME)
INSTRUCTIONS=$(wildcard instructions/*.cpp)
EXAMPLES=example/*

CXX=g++
CXXFLAGS=-Wall -Wno-unknown-pragmas
COPY_COMMAND=cp
REMOVE_COMMAND=rm
REMOVE_FLAGS=-rf

SYS:= $(shell gcc -dumpmachine)
ifneq (, $(findstring mingw, $(SYS)))
PLATFORM=WIN
else 
PLATFORM=LINUX
endif

ifeq ($(PLATFORM), WIN)
TARGET+=.exe
EXAMPLES=examples\*.*
COPY_COMMAND=copy
REMOVE_COMMAND=del
REMOVE_FLAGS=/F /S /Q
CXXFLAGS+= -Wl,--enable-auto-import 
endif



all: clean mkdir executable 
	$(COPY_COMMAND) $(TARGET) $(OUTPUTDIR)
	$(COPY_COMMAND) $(EXAMPLES) $(OUTPUTDIR)

executable: prepare
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCES) $(INSTRUCTIONS)

prepare: flex bison

flex: bison
	flex -i $(PROJNAME).l

bison:
	bison -d $(PROJNAME).y

mkdir: 
	-mkdir $(OUTPUTDIR)

clean:
	-$(REMOVE_COMMAND) $(REMOVE_FLAGS) $(PROJNAME) $(TARGET) $(OUTPUTDIR)
