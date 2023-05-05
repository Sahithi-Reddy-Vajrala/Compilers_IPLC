CXX   = g++-8
EXE = iplC
CXXDEBUG = -g -Wall
CXXSTD = -std=c++11


.PHONY: all parser lexer
all: parser lexer 	
	$(CXX) $(CXXDEBUG) -o $(EXE) driver.cpp symbtab.cpp ast_class.cpp parser.o scanner.o 

parser: parser.yy scanner.hh
	bison -d -v $<
	$(CXX) $(CXXDEBUG) -c parser.tab.cc -o parser.o 

lexer: scanner.l scanner.hh parser.tab.hh parser.tab.cc	
	flex++ --outfile=scanner.yy.cc  $<
	$(CXX)  $(CXXDEBUG) -c scanner.yy.cc -o scanner.o

clean:
	rm -rf parser.tab.cc parser.tab.hh scanner.yy.cc scanner.o parser.o location.hh stack.hh position.hh parser.output $(EXE)
