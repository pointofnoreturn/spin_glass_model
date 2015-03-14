function [ spinInit, spin, couplings, langsOnGraph,codeToLang,localM,MvsT ] = monteCarlo( sln, tln, phi_corr, siteln,values, T, steps )
%   Monte Carlo simulation for thermodynamics of spin glass model of syntax
%   sln, tln, phi_corr define a digraph
%   siteln, values define a database of syntax parameter values for various
%   languages
%   T = temperature, steps = number of steps to carry out
%   discard is number of initial steps to exclude from averaging
%   Inputs are as follows:
%   sln = names of source vertices, tln = names of target vertices
%   phi_corr = interaction strengths
%   siteln = names of languages in parameter database, values = parameter
%   value for each language in database

discard = 1000;
mystream = RandStream('mt19937ar');

%   Count the number of unique languages in the topology data
nLangGraph = size(unique([sln;tln]),1);
%   Create a map from language names to array indices
codeToLang = containers.Map(transpose(unique([sln;tln])), 1:nLangGraph);
%   Initialize coupling matrix and spin array
couplings = zeros(nLangGraph, nLangGraph);
spin = zeros(1,nLangGraph);
%   Create array of random numbers (via twister)
randomNumbers = rand(steps * nLangGraph, 1);

%   Populate coupling matrix. Note that entries that don't appear in the
%   syntactic parameter list will have no effect because their spins will
%   always be zero.
for i = 1:(size(sln,1))
    couplings(codeToLang(sln{i}), codeToLang(tln{i})) = phi_corr(i);    
end

%   Count the number of languages that appear on both lists
isOnGraph = isKey(codeToLang,siteln);
%   Initialize a list of languages that appear on both lists
langsOnGraph = cell(sum(isOnGraph),1);
langsOnGraphCounter = 0;
%   Populate spin array and language list
for i = 1:(size(siteln,1))
    if (isOnGraph(i) == 1)
        if (strcmp(values{i},'Yes'))
            spin(1,codeToLang(siteln{i})) = 1;  % Feature present
        elseif (strcmp(values{i},'No'))
            spin(1,codeToLang(siteln{i})) = -1; %   Feature absent
        else
            spin(1,codeToLang(siteln{i})) = 0;  % "Not yet set"
        end
        langsOnGraphCounter = langsOnGraphCounter + 1;
        langsOnGraph{langsOnGraphCounter} = siteln{i};
    end
end

%   Save initial spin state
spinInit = spin;
spinRecord = zeros(steps,nLangGraph);
MvsT = zeros(steps, 1);
%   Perform Monte Carlo simulation via Metropolis Algorithm
for t = 1:steps
    %   Choose random site to flip
    idxToFlip = randi([1,langsOnGraphCounter]);
    i = codeToLang(langsOnGraph{idxToFlip});
    currSpin =  spin(1,i);
    %   Calculate energy cost of flipping spin
    delta = currSpin * 2 * spin * couplings(:,i);
    %   Apply Metropolis criterion
    if (delta <= 0)
        spin(1,i) = (-1) * spin(1,i);
    elseif (exp((-1) * delta / T) > randomNumbers((t - 1) * nLangGraph + i))
        spin(1,i) = (-1) * spin(1,i);
    end
    MvsT(t) = sum(spin); % sum over sites
    spinRecord(t,:) = spin;
end
MvsT = MvsT / langsOnGraphCounter;  % spin average at each step
localM = mean(spinRecord(discard:steps,:),1); % local magnetization
end

