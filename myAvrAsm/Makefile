
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
DOC_OUTPUTDIR = doc
DOC_DIR = doc-src

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


# create required directories in $(BUILDDIR) directory (including $(BUILDDIR))
DIRS_CREATED = $(BUILDDIR)/.null

$(DIRS_CREATED):
	@echo "Creating build directory structure..."
	@-mkdir -p $(BUILDDIR)
	@-mkdir -p $(OUTPUTDIR)
	@-mkdir -p $(DOC_OUTPUTDIR)
	@-$(foreach DIR,$(DIRS), mkdir -p $(BUILDDIR)/$(DIR); )
	@touch $(DIRS_CREATED)



$(TARGET): INDEX GENERATE_PARSER $(OBJS)
	@echo [linking $@]
	@$(CXX) $(OBJS) -o$@ 

$(BUILDDIR)/%.o: %.c
	@echo [compiling] $< ...
	@$(CXX) -c $< -o $@ $(CXXFLAGS)

$(BUILDDIR)/%.o: %.cpp
	@echo [compiling] $< ...
	@$(CXX) -c $< -o $@ $(CXXFLAGS)

GENERATE_PARSER: src/myAvrAsm.lexer.c

src/myAvrAsm.lexer.c: src/myAvrAsm.l src/myAvrAsm.parser.c
	@echo [FLEX] ...
	flex -i -o$@ $<

src/myAvrAsm.parser.c:	 src/myAvrAsm.y $(DIRS_CREATED)
	@echo [BISON] ...
	bison -d -o$@ $<



INSTR = $(wildcard src/instructions/*.h)

INDEX: $(INSTR)
	@$(shell echo "#pragma once" > src/instructions/index.h)
	@$(foreach INCL, $(INSTR:src/instructions/%.h=#include\"%.h\") , $(shell echo "$(INCL)" >> src/instructions/index.h))



cleanall: clean
	-$(REMOVE_COMMAND) $(REMOVE_FLAGS) $(OUTPUTDIR) $(DOC_OUTPUTDIR)
clean:
	-$(REMOVE_COMMAND) $(REMOVE_FLAGS) $(PROJNAME) $(TARGET) $(BUILDDIR) src/instructions/index.h




DOCFILES = $(wildcard $(DOC_DIR)/*.md)
DOCTARGETS = $(DOCFILES:$(DOC_DIR)/%.md=$(DOC_OUTPUTDIR)/%.html)

$(DOC_OUTPUTDIR)/%.html: $(DOC_DIR)/%.md $(DIRS_CREATED) 
	cat $(DOC_DIR)/template-start.html > $@
	perl bin/Markdown.pl $< >> $@
	cat $(DOC_DIR)/template-end.html >> $@

docs: $(DOCTARGETS)



