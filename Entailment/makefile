# Jim Tao
# LaTeX Default Makefile

# Macros
 JAVAC = javac
# JAVAC = 
 JAVACFLAGS = -cp stdlib.jar:algs4.jar:.
# JAVACFLAGS = 

# Dependency rules for non-file targets
all: SpinGlass
clean: 
	rm -f *.class
clobber: clean

# Dependency rules for file targets
SpinGlass: SpinGlass.java
	$(JAVAC) $(JAVACFLAGS) SpinGlass.java

