function [figH] = ...
    plotForceVelocitySimulationDataForPublication(figH,...
                      lsdynaBinout,lsdynaMuscleUniform,d3hspFileName, ...
                      indexModel,subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...                       
                      referenceCurveFolder,...
                      muscleArchitecture,...
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      lineColorA, lineColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);

fontSizeLegend=6;

if(contains(simulationFile,'isometric'))
    flag_addSimulationData=0;
end

trialFolder=pwd;
cd ..;
simulationFolder=pwd;
cd(trialFolder);

indexCol = indexModel;
scaleF=1000;
scaleV = 1000;

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;
vceNMax                 = getParameterValueFromD3HSPFile(d3hspFileName, 'VCEMAX');

lineWidthData=1;
lineWidthModel=1;

fileNameShorteningStart     = 'force_velocity_00';
fileNameShorteningEnd       = 'force_velocity_05';
fileNameLengtheningStart    = 'force_velocity_06';
fileNameLengtheningEnd      = 'force_velocity_11';

fileNameMaxActStart         = 'force_velocity_00';
fileNameMaxActLast          = 'force_velocity_11';
fileNameSubMaxActStart      = 'force_velocity_12';
fileNameSubMaxActLast       = 'force_velocity_17';

numberSubMaxActStart=12;

fileNameIsometric           = 'isometric';


flag_viva=0;
if(contains(lsdynaMuscleUniform.nameLabel,'VIVA+'))
    flag_viva=1;
end

plotSettings(3) = struct('yLim',[],'xLim',[],'yTicks',[],'xTicks',[]);

timeEnd     = lsdynaMuscleUniform.eloutTime(end,1);
timeStart   = lsdynaMuscleUniform.eloutTime(1,1);
timeEpsilon = (timeEnd-timeStart)/1000;
timeDelta   = (timeEnd-timeStart)/100;

timeRamp0   = getParameterValueFromD3HSPFile(d3hspFileName, 'TIMERAMP0');
timeRamp1   = getParameterValueFromD3HSPFile(d3hspFileName, 'TIMERAMP1');
pathLen0    = getParameterValueFromD3HSPFile(d3hspFileName, 'PATHLEN0');
pathLen1    = getParameterValueFromD3HSPFile(d3hspFileName, 'PATHLEN1');

pathVel         = getParameterValueFromD3HSPFile(d3hspFileName, 'PATHVEL');
timeExcitation1 = getParameterValueFromD3HSPFile(d3hspFileName, 'TIMES1');

timePreRamp = round((timeRamp0-timeExcitation1)*0.9)+timeExcitation1;

%Slightly adjust 

indexRamp0  = find(lsdynaMuscleUniform.time>=timeRamp0,1);
indexRamp1  = find(lsdynaMuscleUniform.time>=timeRamp1,1);


idx=1;
plotSettings(idx).xLim  = [-10.01,10.01];
plotSettings(idx).yLim  = [0,1.501];
plotSettings(idx).xTicks = [-10,-1,0,1,10];
plotSettings(idx).yTicks = [0,1];

idx=2;
plotSettings(idx).xLim   = [0,timeEnd];
plotSettings(idx).yLim   = plotSettings(1).yLim;
plotSettings(idx).xTicks = round([0,timeExcitation1,timeRamp0],3,'significant');
plotSettings(idx).yTicks = [0,1];

lineType = '-';

lastTwoChar = simulationFile(1,end-1:1:end);
lastTwoNum  = str2num(lastTwoChar);
flag_subMax = 0;
if(isempty(lastTwoNum) == 0)
    if(lastTwoNum >= numberSubMaxActStart)
        lineType='--';
        flag_subMax = 1;
    end
end




% Add the reference data
%if(flag_addReferenceData==1)


%end

% Add the simulation data
if(flag_addSimulationData==1)  
    lineColor = lineColorA;    
    markerFaceColor = lineColorA;
    markerLineWidth = lineWidthModel;
    markerSize = 4;

    %%
    % Load the isometric trial at the target length and store the 
    % passive and active forces at this length
    %%
    %Load the isometric binout file
    currDir = pwd;
    fpNSample = nan;
    faNSample = nan;
    lceNSample = nan;
    
    if(flag_subMax == 0)
        cd(fullfile('..','isometric_max'));
        
        [binoutIsometric,status] = ...
            binoutreader('dynaOutputFile','binout0000',...
                            'ignoreUnknownDataError',true);
        timeSampleExcitation1 = getParameterValueFromD3HSPFile('d3hsp', 'TIMES1'); 
    
        switch lsdynaMuscleUniform.name
            case 'umat41'
                [musout,success] = ...
                    readUmat41MusoutData('musout.0000000002');  
            case 'umat43'
                [musout,success] = ...
                    readUmat43MusoutData('musout.0000000002');             
            case 'viva'
                musout=[];
            otherwise assert(0)
        end
    
        cd(currDir);    
    else
        cd(fullfile('..','isometric_sub_max'));
        [binoutIsometric,status] = ...
            binoutreader('dynaOutputFile','binout0000',...
                            'ignoreUnknownDataError',true);
        timeSampleExcitation1 = getParameterValueFromD3HSPFile('d3hsp', 'TIMES1');  
        switch lsdynaMuscleUniform.name
            case 'umat41'
                [musout,success] = ...
                    readUmat41MusoutData('musout.0000000002');  
            case 'umat43'
                [musout,success] = ...
                    readUmat43MusoutData('musout.0000000002');             
            case 'viva'
                musout=[];
            otherwise assert(0)
        end    
        cd(currDir);        
    end
        
    idxPassive          = find(binoutIsometric.elout.beam.time >= timeSampleExcitation1,1);
    idxPassiveSample    = round(idxPassive*0.5);
    idxActiveSample     = round(0.9*(length(binoutIsometric.elout.beam.time)-idxPassive)) ...
                            + idxPassive;
    
    fA = binoutIsometric.elout.beam.axial(idxPassiveSample,1);
    fB = binoutIsometric.elout.beam.axial(idxActiveSample,1);
    
    fpNSample = (fA)/maximumIsometricForce;
    faNSample = (fB-fA)/maximumIsometricForce;

    switch lsdynaMuscleUniform.name
        case 'umat41'
            lceNSample = musout.data(end,musout.indexLce)./optimalFiberLength; 
        case 'umat43'
            lceNSample = musout.data(end,musout.indexLceN);           
        case 'viva'
            lceNSample = -binoutIsometric.nodout.z_coordinate(idxActiveSample,1)...
                            /optimalFiberLength;
        otherwise assert(0)
    end     


    %%
    % Sample the model force when lceN is equal to lceNSample
    %%
    
    %Sampling at the time that lceNSample will not work with elastic tendon
    %models using the protocol of Herzog & Leonard 1997 which ends at
    %the same length. Why? During lenthening the CE's force is enhanced and
    %it will remain shorter than lceNSample until well after the shortening
    %has ceased.

    %timeSample = interp1(lsdynaMuscleUniform.lceN(indexRamp0:indexRamp1,1),...
    %                     lsdynaMuscleUniform.time(indexRamp0:indexRamp1,1),...
    %                     lceNSample);

    %And so, I'm using the very end time of the ramp as the sample time,
    %which matches the protocol of Herzog and Leonard. This is only 
    %really acceptable if all of the lceN's end up being similar, which 
    %in turn, is only possible with a short tendon.
    %
    %To ensure that I'm sampling the last instant in which the
    %muscle is at its maximum shortening rate, I have to make a small
    %adjustment because LS-DYNA transitions from the target velocity
    %to zero over a few steps. 
    idx = indexRamp1;
    if(contains(simulationFile,'isometric')==0)
        dfR =(lsdynaMuscleUniform.vp(idx,1)...
            - lsdynaMuscleUniform.vp(idx-1,1));
        while( abs(dfR) > 1e-8 && idx > indexRamp0)
            idx=idx-1;
            dfR =(lsdynaMuscleUniform.vp(idx,1)...
                - lsdynaMuscleUniform.vp(idx-1,1));                
        end        
        assert(idx > indexRamp0,...
            ['Error: the loop used to refine the end of'...
             ' the ramp continued to the beginning of the ramp']);
    else
        idx=indexRamp1;
    end
    indexSample=idx;
    timeSample = lsdynaMuscleUniform.time(indexSample,1);



    act = lsdynaMuscleUniform.act(indexSample,1);
    if(flag_viva)
        act=faNSample;
    end
    
    lceN = lsdynaMuscleUniform.lceN(indexSample,1);
    fsN = lsdynaMuscleUniform.fmtN(indexSample,1);
    vsN = lsdynaMuscleUniform.lceNDot(indexSample,1);

    switch lsdynaMuscleUniform.name
        case 'umat41'
            vsN = vsN.*scaleV;% / vceNMax; 
        case 'umat43'
            vsN = vsN*vceNMax.*scaleV;           
        case 'viva'
            vsN = vsN.*scaleV;% / vceNMax;
        otherwise assert(0)
    end    

    fvN = (fsN-fpNSample);



    handleVisibility = 'off';
    if(contains(simulationFile,fileNameMaxActStart) ...
            || contains(simulationFile,fileNameSubMaxActStart))
        handleVisibility = 'on';        
    end    
    %%
    % Plot the time domain signals
    %%
    if(flag_subMax==0 && contains(simulationFile,'isometric_sub_max')==0)
        subplot('Position',reshape(subPlotLayout(2,indexCol,:),1,4));
        
        displayNameStr = [lsdynaMuscleUniform.name, sprintf('(%1.1f)',act)];
        
        plot(lsdynaMuscleUniform.time,...
             lsdynaMuscleUniform.fmtN, ...
             '-',...
            'Color',[1,1,1],...
            'LineWidth',lineWidthModel+1,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off'); 
        hold on;
        plot(lsdynaMuscleUniform.time(indexSample,1),...
             lsdynaMuscleUniform.fmtN(indexSample,1), ...
             lsdynaMuscleUniform.mark,...
            'Color',[1,1,1],...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',[1,1,1],...
            'MarkerSize',markerSize+2);
        hold on;
        plot(lsdynaMuscleUniform.time,...
             lsdynaMuscleUniform.fmtN, ...
             lineType,...
            'Color',lineColor,...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility',handleVisibility,...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;
        plot(lsdynaMuscleUniform.time(indexSample,1),...
             lsdynaMuscleUniform.fmtN(indexSample,1), ...
             lsdynaMuscleUniform.mark,...
            'Color',lineColor,...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;
        box off;
    end
    
    %time,act,lceN,vsN,fvN
    if(contains(simulationFile,fileNameMaxActStart))
        fid=fopen([simulationFolder,filesep,'record.csv'],'w');
        fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',timeSample,act,lceN,vsN,fvN);
        fclose(fid);

    elseif(contains(simulationFile,fileNameMaxActLast))
        fid=fopen([simulationFolder,filesep,'record.csv'],'a');
        fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',timeSample,act,lceN,vsN,fvN);
        fclose(fid);

        dataFv = csvread([simulationFolder,filesep,'record.csv']);

        subplot('Position',reshape(subPlotLayout(1,indexCol,:),1,4));        
        
        [valMap,idxMap] = sort(dataFv(:,4));

        displayNameStr = [lsdynaMuscleUniform.name, sprintf('(%1.1f)',act)]; 
        plot(dataFv(idxMap,4),...
             dataFv(idxMap,5),...
             '-',...
            'Color',[1,1,1],...
            'LineWidth',lineWidthModel+1,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off'); 
        hold on;
        plot(dataFv(idxMap,4),...
             dataFv(idxMap,5),...
             lsdynaMuscleUniform.mark,...
            'Color',[1,1,1],...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',[1,1,1],...
            'MarkerSize',markerSize+2);
        hold on;
        plot(dataFv(idxMap,4),...
             dataFv(idxMap,5),...
             lineType,...
            'Color',lineColor,...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility',handleVisibility,...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;
        plot(dataFv(idxMap,4),...
             dataFv(idxMap,5),...
             lsdynaMuscleUniform.mark,...
            'Color',lineColor,...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;
        box off;        

    elseif(contains(simulationFile,fileNameSubMaxActStart))
        fid=fopen([simulationFolder,filesep,'record.csv'],'w');
        fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',timeSample,act,lceN,vsN,fvN);
        fclose(fid);

    elseif(contains(simulationFile,fileNameSubMaxActLast))
        fid=fopen([simulationFolder,filesep,'record.csv'],'a');
        fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',timeSample,act,lceN,vsN,fvN);
        fclose(fid);

        dataFv = csvread([simulationFolder,filesep,'record.csv']);
        [valMap,idxMap] = sort(dataFv(:,4));

        subplot('Position',reshape(subPlotLayout(1,indexCol,:),1,4));        
        
        displayNameStr = [lsdynaMuscleUniform.name, sprintf('(%1.1f)',act)]; 
        plot(dataFv(idxMap,4),...
             dataFv(idxMap,5),...
             '-',...
            'Color',[1,1,1],...
            'LineWidth',lineWidthModel+1,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off'); 
        hold on;
        plot(dataFv(idxMap,4),...
             dataFv(idxMap,5),...
             lsdynaMuscleUniform.mark,...
            'Color',[1,1,1],...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',[1,1,1],...
            'MarkerSize',markerSize+2);
        hold on;
        plot(dataFv(idxMap,4),...
             dataFv(idxMap,5),...
             lineType,...
            'Color',lineColor,...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility',handleVisibility,...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;
        plot(dataFv(idxMap,4),...
             dataFv(idxMap,5),...
             lsdynaMuscleUniform.mark,...
            'Color',lineColor,...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;
        box off;             

    else 
        fid=fopen([simulationFolder,filesep,'record.csv'],'a');
        fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',timeSample,act,lceN,vsN,fvN);
        fclose(fid);
    end

end


subPlotLabel0 = 'A.';
subPlotLabel1 = 'B.';

switch lsdynaMuscleUniform.name
    case 'umat41'
        subPlotLabel0 = 'C.';
        subPlotLabel1 = 'D.'; 
    case 'umat43'
        subPlotLabel0 = 'E.';
        subPlotLabel1 = 'F.';            
    case 'viva'
        subPlotLabel0 = 'A.';
        subPlotLabel1 = 'B.';
    otherwise assert(0)
end

idx=1;
subplot('Position',reshape(subPlotLayout(idx,indexCol,:),1,4));

xlim(plotSettings(idx).xLim);
ylim(plotSettings(idx).yLim);
xticks(plotSettings(idx).xTicks);
yticks(plotSettings(idx).yTicks); 
xlabel('Norm. Velocity ($$v/\ell^{M}_o$$)');
ylabel('Norm. Force ($$f/f^{M}_o$$)');
title(sprintf('%s %s force-velocity relation',...
              subPlotLabel0,lsdynaMuscleUniform.nameLabel));

idx=2;
subplot('Position',reshape(subPlotLayout(idx,indexCol,:),1,4));

xlim(plotSettings(idx).xLim);
ylim(plotSettings(idx).yLim);
xticks(plotSettings(idx).xTicks);
yticks(plotSettings(idx).yTicks); 
xlabel('Time (ms)');
ylabel('Norm. Force ($$f/f^{M}_o$$)');
title(sprintf('%s %s ramp responses',...
    subPlotLabel1,lsdynaMuscleUniform.nameLabel));



