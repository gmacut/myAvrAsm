
PROJNAME=myAvrAsm

TARGET=myAvrAsm
EXAMPLES=example/*

CXX=g++
CXXFLAGS=-Wall -Wno-unknown-pragmas
COPY_COMMAND=cp
REMOVE_COMMAND=rm
REMOVE_FLAGS=-rf


SRCDIRS = src src/instructions
OUTPUTDIR = output
BUILDDIR = build

DIRS := $(SRCDIRS)
FILES := $(foreach DIR,$(DIRS),$(wildcard $(DIR)/*.c $(DIR)/*.cpp))

OBJS := $(addprefix $(BUILDDIR)/,$(FILES:.c=.o))
OBJS := $(OBJS:.cpp=.o)


SYS:= $(shell gcc -dumpmachine)
ifneq (, $(findstring mingw, $(SYS)))
PLATFORM=WIN
else 
PLATFORM=LINUX
endif

ifeq ($(PLATFORM), WIN)
TARGET=myAvrAsm.exe
#EXAMPLES=example\*.*
#COPY_COMMAND=copy
#REMOVE_COMMAND=del
#REMOVE_FLAGS=/F /Q
CXXFLAGS+= -Wl,--enable-auto-import -static
endif



all: $(TARGET)
	@echo Copying to output dir...
	$(COPY_COMMAND) $(TARGET) $(OUTPUTDIR)
	$(COPY_COMMAND) $(EXAMPLES) $(OUTPUTDIR)

$(TARGET): $(OBJS)
	@echo [linking $@]
	@$(CXX) $(OBJS) -o$@ 

$(BUILDDIR)/%.o: %.c prepare
	@echo [compiling] $< ...
	@$(CXX) -c $< -o $@ $(CXXFLAGS)

$(BUILDDIR)/%.o: %.cpp prepare
	@echo [compiling] $< ...
	@$(CXX) -c $< -o $@ $(CXXFLAGS)

prepare: flex bison

flex: bison
	@echo [FLEX] ...
	flex -i -osrc/$(PROJNAME).lexer.c src/$(PROJNAME).l

bison: dirs
	@echo [BISON] ...
	bison -d -osrc/$(PROJNAME).parser.c src/$(PROJNAME).y


# create required directories in $(BUILDDIR) directory (including $(BUILDDIR))
dirs:
	@-mkdir -p $(BUILDDIR)
	@-mkdir -p $(OUTPUTDIR)
	@-$(foreach DIR,$(DIRS), mkdir -p $(BUILDDIR)/$(DIR); )

cleanall: clean
	-$(REMOVE_COMMAND) $(REMOVE_FLAGS) $(OUTPUTDIR)
clean:
	-$(REMOVE_COMMAND) $(REMOVE_FLAGS) $(PROJNAME) $(TARGET) $(BUILDDIR)
