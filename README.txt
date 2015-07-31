Spin glass model of evolution syntactic parameters

By. M.M., J.T., K.S.

Implementations in MATLAB and Java

MATLAB code for independent parameters approximation

param_file_creation.m : creates workspace files for each syntactic parameter in a directory parameter_value_files

parameter_script.m : performs Monte Carlo simulation for each syntactic parameter and stores the output for each in a workspace variable in output-files

data_visualization.m : creates visual digraph for an output file (parameter/temperature) in directory output-files specified in the code

Entailment Example code in java

To compile the simulation, execute the following Linux command:

make

Note: it makes use of Java libraries algs4.jar and stdlib.jar from http://algs4.cs.princeton.edu/code/algs4.jar and http://algs4.cs.princeton.edu/code/stdlib.jar respectively.

To run the simulation, execute the following Linux command:

./testAll.sh

To plot the data, use the Mathematica notebook titled "plotter.nb" and save the plots as images.