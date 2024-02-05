function figH = addRodeSiebertHerzogBlickhan2009ForceLength(...
                figH,subplotPosition, labelData, ...
                expColorA,expColorB,...
                muscleArchitecture, ...
                plotActiveData,...
                plotPassiveData,...
                flag_plotInNormalizedCoordinates,...
                fileNameToAppendProcessedData,...
                idData)

assert(flag_plotInNormalizedCoordinates==1,...
       ['Error: addRodeSiebertHerzogBlickhan2009ForceLength only works in ',...
        'normalized coordinates']);

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;

figure(figH);
subplot('Position',subplotPosition);

fid=fopen(fileNameToAppendProcessedData,'a');

settingHandleVisibility = 'on';

for indexSeries=1:1:6

    fileRSHB2009 = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
       'ReferenceExperiments',filesep,...
       'active_passive_force_length',filesep,...
       sprintf('RodeSiebertHerzogBlickhan2009_Fig4_S%i.csv',indexSeries)]; 
    
    
    dataRSHB2009 = loadDigitizedData(fileRSHB2009,...
                    'Norm. Length ($$mm$$)','Norm. Force ($$f/f_o^M$$)',...
                    {'flfp','fp'},...
                    {'Rode, Siebert, Herzog, Blickhan 2009'}); 

    n = (indexSeries-1)/(6-1);
    expColor = expColorA.*n + expColorB.*(1-n);

    %Evaluate the optimal length assuming it happens at the peak active
    %force
    idxFaFp=1;
    idxFp = 2;

    xMM   = dataRSHB2009(idxFaFp).x;
    fafp  = dataRSHB2009(idxFaFp).y;
    fp    = zeros(size(fafp)); 
    for i=1:1:length(dataRSHB2009(idxFaFp).x)
        if(xMM(i,1) < min(dataRSHB2009(idxFp).x))
            fp(i,1)=0;
        else
            fp(i,1) = interp1(dataRSHB2009(idxFp).x,...
                              dataRSHB2009(idxFp).y,...
                              xMM(i,1),...
                              'linear','extrap');
        end
    end
    
    fa              = fafp - fp;
    [faMax,idxMax]  = max(fa);
    lenMMOpt        = xMM(idxMax,1);

    if(plotActiveData==1 && plotPassiveData==0)
        lenMM = dataRSHB2009(idxFaFp).x;
        f = fa;
    end

    if(plotPassiveData==1 && plotActiveData==0)
        lenMM = dataRSHB2009(idxFp).x;
        f     = dataRSHB2009(idxFp).y;       
    end

    if(plotActiveData==1 && plotPassiveData==1)
        lenMM = dataRSHB2009(idxFaFp).x;
        f     = dataRSHB2009(idxFaFp).y; 
    end

    %Where 1 meets the definition of the optimal fiber length in 
    %the paper: the shortest length where the active force is 98%
    %of the peak value. This is the beginning of the plateau region. 
    %Here I subtract off the value of lenMMOpt to align the optimal length
    %with the length at the peak value.

    lenMM = lenMM-lenMMOpt;
    lenN  = lenMM./(optimalFiberLength*1000) + 1;

    plot( lenN,...
          f,...
          'o',...
          'Color',expColor,...
          'MarkerFaceColor',expColor,...
          'MarkerSize',4,...
          'DisplayName',labelData,...
          'HandleVisibility',settingHandleVisibility);   
    hold on;
    settingHandleVisibility = 'off';        
    
    for indexData=1:1:length(lenN)
        if(isnan(f(indexData,1)))
            here=1;
        end
        fprintf(fid,'%1.3f,%1.3f,%i,%i\n',...
            lenN(indexData,1),f(indexData,1),...
            idData,indexSeries);
    end
end

fclose(fid);
