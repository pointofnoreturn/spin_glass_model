%   Script to perform Monte Carlo simulation for each syntax parameter
clear;
steps = 1000000;
T = 0.000001;
dirName = 'output-files';

%   Load sln, tln, phi_corr from 'books_graph_values.mat'
% load('books_edges_data.mat');

%   Load sln, tln, phi_corr from 'wikipedia_graph_values.mat'
load('wikipedia_edges_data.mat');

%   Loop over syntactic parameters
cd('parameter_value_files');
fileList = dir;
numOfFiles = size(fileList,1);
cd('../');

mkdir(dirName);

for i = 3:113;    % Change the end value to generate simulations for more syntactic parameters; 3 is Subject Verb.
    cd('parameter_value_files');
    load(fileList(i).name);
    cd('../');
    siteln = f(:,1);
    values = f(:,2);
    [initialSpins, finalSpins,couplings,languages,map,localM,MvsT] = monteCarlo(sln, tln, phi_corr, siteln,values, T, steps);
    dataFilename = [fileList(i).name(1:(end-4)),'_',num2str(T),'_data.mat'];
    cd(dirName);
    save(dataFilename,'initialSpins','finalSpins','couplings','languages','map','localM','MvsT','paramType');
    cd('../');
end