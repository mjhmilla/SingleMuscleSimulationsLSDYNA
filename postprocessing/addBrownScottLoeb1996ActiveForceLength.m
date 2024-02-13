function figH = addBrownScottLoeb1996ActiveForceLength(...
                figH,subplotPosition, labelData, ...
                expColor,...
                muscleArchitecture, ...
                flag_plotInNormalizedCoordinates,...
                fileNameToAppendProcessedData,...
                idData)

assert(flag_plotInNormalizedCoordinates==1,...
       ['Error: addBrownScottLoeb1996ActiveForceLength only works in ',...
        'normalized coordinates']);

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;

fid=fopen(fileNameToAppendProcessedData,'a');

figure(figH);
subplot('Position',subplotPosition);

fileBSL1996falN = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'active_passive_force_length',filesep,...
           'fig_BrownScottLoeb1996_fig7.csv']; 

dataBSL1996falN= csvread(fileBSL1996falN,1,0);

plot(dataBSL1996falN(:,1),...
     dataBSL1996falN(:,2),...
     's',...
     'Color',expColor,...
     'MarkerFaceColor',[1,1,1],...
     'MarkerSize',4,...
     'DisplayName',labelData,...
     'HandleVisibility','on');
hold on;

for indexData=1:1:length(dataBSL1996falN(:,1))
    fprintf(fid,'%1.3f,%1.3f,%i,%i\n',...
            dataBSL1996falN(indexData,1),...
            dataBSL1996falN(indexData,2),...
            idData,1);
end

fclose(fid)