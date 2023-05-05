# Submission Instructions for Assignment 1

1. You need to submit a tarred gzipped version of your directory (file name must be `<group_id>.tar.gz`).

2. On untarring, it must produce the directory `group_id` (e.g. `group_1`, `group_19`).

3. The directory must contain a `Makefile` that produces an executable called `iplC`. The target of the Makefile that creates the executable `iplC` should be a .PHONY called all. Similarly the target that creates the relocatable files `parser.o` and `scanner.o` should be phonies parser and lexer.

4. The Makefile must also have a target `clean` such that the command `$ make clean` deletes all generated files in the same directory.

5. The directory should have a `scanner.l` (lex script), `parser.yy` (yacc script), `driver.cpp` (driver program) and other helper files as required.

6. The directory must not contain the binary `iplC` (or any other binary file) when untarred. It must be generated only when make all is run.

7. You must use `g++-8` in Makefile for compiling.

Any deviation from this will incur a heavy penalty.

# Evaluation of Assignment 1

Following factors will be considered for evaluation :

1.  A set of test cases.

    The executable `iplC` should take the test program as commandline argument. It should print the dot script on stdout.

    The order of nodes and edges must match with the order generated by the reference implementation. Work with the testcases to find out the regular pattern of this order.

    The spaces and newlines need not match exactly. For this purpose, all outputs will be matched using the command `$ diff -Bw` which should produce zero output.

2.  Absence of shift-reduce or reduce-reduce conflicts in the parser.

    Use the command `$ bison -dv` in your Makefile to produce the `parser.tab.cc`, `parser.tab.hh` and `parser.output` files (do not rename them). `parser.output` contains the debug info and shows shift-reduce, reduce-reduce conflicts if any. The command `$ make all` should not report any shift-reduce or reduce-reduce conflicts. Similarly no conflicts should appear in the `parser.output` file.

3.  You must use "variant" (as in `parser.yy` in the demo) and not "union" for the type specification of values of the terminals and non-terminals in the stack of the parser.

4.  Return the token OTHERS on seeing a character that is not part of the language. On getting a OTHERS token, the parser goes through its default behaviour. It stops after reporting the error and emptying the stack.

# Grading Policy

There will be 3 lab assignments, each with the tentative weightage as:

- Assignment 1: 35 marks
- Assignment 2: 35 marks
- Assignment 3: 30 marks

Late submissions for Assignment 1 are allowed for a maximum of 7 days (i.e till 23:59, Jan 11) with a penalty of 1 mark per day.