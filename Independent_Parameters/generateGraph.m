function [ finalCouplings,finalInitialSpins,finalFinalMeanSpins,finalFinalSpins,bg1,bg2,bg3 ] = generateGraph( filename )
%   Generates digraph of languages with spins or local magnetization > 0
%   colored red and spins or local magnetization < 0 colored blue
cd('output-files');
load(filename);
cd('../');
numOfLanguages = size(languages,1);
finalCouplings = zeros(numOfLanguages,numOfLanguages);
finalInitialSpins = zeros(numOfLanguages,1);
finalFinalMeanSpins = zeros(numOfLanguages,1);
finalFinalSpins = zeros(numOfLanguages,1);

for i = 1:numOfLanguages;
    idxI = map(languages{i});
    finalInitialSpins(i) = initialSpins(idxI);
    finalFinalMeanSpins(i) = localM(idxI);
    finalFinalSpins(i) = finalSpins(idxI);
    for j = 1:numOfLanguages;
        idxJ = map(languages{j});
        finalCouplings(i,j) = couplings(idxI,idxJ);
    end
end

cm1 = finalCouplings;
ids1 = transpose(languages);
bg1 = biograph(cm1,ids1);
bg2 = biograph(cm1,ids1);
bg3 = biograph(cm1,ids1);
set(bg1, 'ShowWeights','off');
set(bg1,'LayoutType','radial');
set(bg2, 'ShowWeights','off');
set(bg2,'LayoutType','radial');
set(bg3, 'ShowWeights','off');
set(bg3,'LayoutType','radial');

%set(bg1, 'EdgeFontSize',30);
%set(bg1, 'EdgeType','straight');
for i = 1:numOfLanguages;
    bg1.nodes(i).Size = [10,10];
    bg1.nodes(i).Shape = 'circle';
    bg1.nodes(i).fontSize = 10;
    bg2.nodes(i).Size = [10,10];
    bg2.nodes(i).Shape = 'circle';
    bg2.nodes(i).fontSize = 10;
    bg3.nodes(i).Size = [10,10];
    bg3.nodes(i).Shape = 'circle';
    bg3.nodes(i).fontSize = 10;
    if (finalInitialSpins(i) == 1)
        bg1.nodes(i).Color = [1,0.4314, 0.4314];
    elseif (finalInitialSpins(i) == -1)
        bg1.nodes(i).Color = [0.4314, 0.4314,1];
    end
    if (finalFinalMeanSpins(i) > 0)
        bg2.nodes(i).Color = [1,0.4314, 0.4314];
    elseif (finalFinalMeanSpins(i) < 0)
        bg2.nodes(i).Color = [0.4314, 0.4314,1];
    end
    if (finalFinalSpins(i) == 1)
        bg3.nodes(i).Color = [1,0.4314, 0.4314];
    elseif (finalFinalSpins(i) == -1)
        bg3.nodes(i).Color = [0.4314, 0.4314,1];
    end
    
end
end

