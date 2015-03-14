%   Script to generate MATLAB-parseable data for each syntax parameter from
%   SSWL's barely usable form
%   Requires file 'parameters_and_stuff.mat' which contains all of the
%   languages and parameters and parameter values in the SSWL database.
%   Creates directory 'parameter_value_files' and saves one .mat file for
%   every syntax parameter containing a list of languages and their
%   corresponding values for that parameter in variable 'f'

clear;
load('parameters_and_stuff.mat');
numOfParams = size(parameters,1);
totalNum = size(paramVals,1);
numOfLanguages = size(langList, 1);

mkdir('parameter_value_files');
cd('parameter_value_files');

%   For each syntactic parameter...
for i = 1:numOfParams;
    paramType = parameters{i};
    %   Initialize f
    f = cell(numOfLanguages,2);
    langCounter = 0;
    %   Do some parsing
    for j = 1:totalNum;
        thing = paramVals{j};
        idxParameter = strfind(thing,paramType);
        if (idxParameter)
                value = thing((idxParameter+length(paramType)+1):end);
                if (strcmp(value, 'Yes') || strcmp(value,'No'))
                    language = thing(1:(idxParameter - 2));
                    langCounter = langCounter + 1;
                    f{langCounter, 1} = language;
                    f{langCounter, 2} = value;
                end
        end
    end
    f = f(1:langCounter,:);
    %   Save stuff
    if (strcmp(paramType(1),'w'))
        paramType(strfind(paramType,':')) = [];
    end
    filename = [paramType, '.mat'];
    paramType = parameters{i};
    save(filename,'f','paramType');
end
cd('../');