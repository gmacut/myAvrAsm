
PROJNAME=myAvrAsm

SOURCES=myAvrAsm.cpp myAvrAsm.tab.c lex.yy.c


CXX=g++
CXXFLAGS=-Wall -Wl,--enable-auto-import



all: executable

executable: flex bison
	$(CXX) $(CXXFLAGS) -o $(PROJNAME) $(SOURCES)


flex: bison
	flex $(PROJNAME).l

bison:
	bison -d $(PROJNAME).y

clean:
	-rm -rf $(PROJNAME) $(PROJNAME).exe *.tab.c *.yy.c *.tab.h