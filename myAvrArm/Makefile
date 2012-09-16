
PROJNAME=myAvrAsm

SOURCES=myAvrAsm.cpp myAvrAsm.tab.c lex.yy.c

OUTPUTDIR=out

CXX=g++
CXXFLAGS=-Wall -Wl,--enable-auto-import -Wno-unknown-pragmas



all: clean mkdir executable  
	cp $(PROJNAME).exe $(OUTPUTDIR)
	cp example/* $(OUTPUTDIR)

executable: flex bison
	$(CXX) $(CXXFLAGS) -o $(PROJNAME) $(SOURCES)


flex: bison
	flex -i $(PROJNAME).l

bison:
	bison -d $(PROJNAME).y

mkdir: 
	mkdir $(OUTPUTDIR)

clean:
	-rm -rf $(PROJNAME) $(PROJNAME).exe *.tab.c *.yy.c *.tab.h $(OUTPUTDIR)
