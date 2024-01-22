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

scaleF=1000;
scaleV = 1000;


lineColorRampA = [149, 69, 53]./256;%[1,1,1].*0.5;
lineColorRampB = lineColorRampA*0.5;

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;
vceNMax                 = getParameterValueFromD3HSPFile(d3hspFileName, 'VCEMAX');

lineWidthData=1;
lineWidthModel=1;

fileNameShorteningStart         = 'force_velocity_00';
fileNameShorteningEnd           = 'force_velocity_08';
numberMaxShorteningStart        = 0; 
numberMaxShorteningEnd          = 8;

fileNameLengtheningStart        = 'force_velocity_09';
fileNameLengtheningEnd          = 'force_velocity_17';
numberMaxLengtheningStart       = 9;
numberMaxLengtheningEnd         = 17;

fileNameMaxActStart             = 'force_velocity_00';
fileNameMaxActEnd               = 'force_velocity_17';
numberMaxActStart               = 0;
numberMaxActEnd                 = 17;

fileNameSubMaxActStart          = 'force_velocity_18';
fileNameSubMaxActEnd            = 'force_velocity_35';
numberSubMaxActStart            = 18;
numberSubMaxActEnd              = 35;

numberHL1997ShorteningStart     = 0;
numberHL1997ShorteningEnd       = 8;%4;
numberHL1997LengtheningStart    = 9;
numberHL1997LengtheningEnd      = 17;%13;

fileNameIsometric           = 'isometric';


flag_viva=0;
if(contains(lsdynaMuscleUniform.nameLabel,'VIVA+'))
    flag_viva=1;
end



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

plotSettings(5) = struct('yLim',[],'xLim',[],'yTicks',[],'xTicks',[]);
idx=1;
plotSettings(idx).xLim  = [-1.01,1.01];
plotSettings(idx).yLim  = [0,1.501];
plotSettings(idx).xTicks = [-1,0,1];
plotSettings(idx).yTicks = [0,1];

idx=2;
plotSettings(idx).xLim   = [0,timeEnd];
plotSettings(idx).yLim   = plotSettings(1).yLim;
plotSettings(idx).xTicks = round([0,timeExcitation1,timeRamp0],3,'significant');
plotSettings(idx).yTicks = [0,1];

idx=3;
plotSettings(idx).xLim   = [0,timeEnd];
plotSettings(idx).yLim   = plotSettings(1).yLim;
plotSettings(idx).xTicks = round([0,timeExcitation1,timeRamp0],3,'significant');
plotSettings(idx).yTicks = [0,1];

idx=4;
plotSettings(idx).xLim   = [0,timeEnd];
plotSettings(idx).xTicks = round([0,timeExcitation1,timeRamp0],3,'significant');
plotSettings(idx).yTicks = [1,1.1];

% leftPos = 1.2;
% a = max(plotSettings(idx-2).yLim)-leftPos;
% b = leftPos-min(plotSettings(idx-2).yLim);
% c = max(plotSettings(idx).yTicks)-min(plotSettings(idx).yTicks);
% d = c*b/a;
% yMin = min(plotSettings(idx).yTicks)-d;
% 
% plotSettings(idx).yLim   = [yMin,1.1];
leftPos = 0.1;%max(plotSettings(idx-2).yLim)-leftPos;
a = max(plotSettings(idx-2).yLim)-leftPos;
b = leftPos-min(plotSettings(idx-2).yLim);
d = max(plotSettings(idx).yTicks)-min(plotSettings(idx).yTicks);
c = d*a/b;
yMax = max(plotSettings(idx).yTicks)+c;

plotSettings(idx).yLim   = [0.9,yMax];

idx=5;
plotSettings(idx).xLim   = plotSettings(idx-1).xLim;
plotSettings(idx).xTicks = plotSettings(idx-1).xTicks;
plotSettings(idx).yTicks = [0.9,1];

leftPos = 0.1;%max(plotSettings(idx-2).yLim)-leftPos;
a = max(plotSettings(idx-2).yLim)-leftPos;
b = leftPos-min(plotSettings(idx-2).yLim);
d = max(plotSettings(idx).yTicks)-min(plotSettings(idx).yTicks);
c = d*a/b;
yMax = max(plotSettings(idx).yTicks)+c;

plotSettings(idx).yLim   = [0.9,yMax];

lineType = '-';

lastTwoChar = simulationFile(1,end-1:1:end);
trialNumber  = str2num(lastTwoChar);
flag_subMax = 0;
if(isempty(trialNumber) == 0)
    if(trialNumber >= numberSubMaxActStart)
        lineType='--';
        flag_subMax = 1;
    end
end




% Add the reference data
if(flag_addReferenceData==1)
    %%
    % Plot Herzog & Leonard 1997
    %%
    labelHL1997='Exp: HL1997 Cat S WM';
    fileHL1997Length = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
               'ReferenceExperiments',filesep,...
               'force_velocity',filesep,...
               'fig_HerzogLeonard1997Fig1A_length.csv'];
    fileHL1997Force = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
               'ReferenceExperiments',filesep,...
               'force_velocity',filesep,...
               'fig_HerzogLeonard1997Fig1A_forces.csv'];

    dataHL1997Length = loadDigitizedData(fileHL1997Length,...
                    'Time ($$s$$)','Length ($$mm$$)',...
                    {'c01','c02','c03','c04','c05',...
                     'c06','c07','c08','c09','c010'},...
                    {'Herzog and Leonard 1997'}); 

    dataHL1997Force = loadDigitizedData(fileHL1997Force,...
                    'Time ($$s$$)','Force ($$N$$)',...
                    {'c01','c02','c03','c04','c05',...
                     'c06','c07','c08','c09','c010'},...
                    {'Herzog and Leonard 1997'});  
    % Graphically measured from Herzog and Leonard 1997 Fig. 1A    
    fisoHL1997 = 37.4576;

    % Graphically measured from Figure 4 of Scott, Brown, Loeb
    %Scott SH, Brown IE, Loeb GE. Mechanics of feline soleus: I. Effect of 
    % fascicle length and velocity on force output. Journal of Muscle 
    % Research & Cell Motility. 1996 Apr;17:207-19.
    vmaxHL1997 = 4.65; 

    % Optimal fiber length from 
    % Scott SH, Loeb GE. Mechanical properties of aponeurosis and tendon 
    % of the cat soleus muscle during whole‐muscle isometric contractions. 
    % Journal of Morphology. 1995 Apr;224(1):73-86.
    lceOptHL1997 = 38.0;

    for idxCol = 2:1:3

        subplot('Position',reshape(subPlotLayout(1,idxCol,:),1,4));
        switch idxCol
            case 2
                idxStart=1;
                idxEnd = 5;
            case 3
                idxStart=6;
                idxEnd = 10;
                
            otherwise assert(0,'Error');
        end

        for idx=idxStart:1:idxEnd
            expColorA = [1,1,1].*0.75;
            expColorB = [1,1,1].*0.5;
            n = (idx-idxStart)/(idxEnd-idxStart);
            expColor = expColorA.*n + expColorB.*(1-n);
            lineWidthModel = 1;
            expRampColor = lineColorRampA.*n + lineColorRampB.*(1-n);
            
            hVis = 'off';
            if(idx==idxEnd)
                hVis = 'on';
            end
    
            yyaxis left;
            if(idx==idxStart)
                plot(plotSettings(2).xLim,[1,1],...
                     '-',...
                     'Color',[0,0,0],...
                     'LineWidth',1,...
                     'HandleVisibility','off');
                hold on;
                text(min(plotSettings(2).xLim),1,'$$f^M_o$$',...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','bottom',...
                    'FontSize',6);
                hold on;
            end
    
            plot( dataHL1997Force(idx).x(:,1).*1000,...
                  dataHL1997Force(idx).y(:,1)./fisoHL1997,...
                  '-',...
                  'Color',[1,1,1],...
                  'LineWidth',lineWidthModel+2,...
                  'DisplayName',labelHL1997,...
                  'HandleVisibility','off'); 
            hold on;
            plot( dataHL1997Force(idx).x(:,1).*1000,...
                  dataHL1997Force(idx).y(:,1)./fisoHL1997,...
                  '-',...
                  'Color',expColor,...
                  'LineWidth',lineWidthModel,...
                  'DisplayName',labelHL1997,...
                  'HandleVisibility',hVis);   
            hold on;
    
            yyaxis right;
            plot( dataHL1997Length(idx).x(:,1).*1000,...
                  dataHL1997Length(idx).y(:,1)./lceOptHL1997+1,...
                  '-',...
                  'Color',[1,1,1],...
                  'LineWidth',lineWidthModel+2,...
                  'DisplayName',labelHL1997,...
                  'HandleVisibility','off'); 
            hold on;
            plot( dataHL1997Length(idx).x(:,1).*1000,...
                  dataHL1997Length(idx).y(:,1)./lceOptHL1997+1,...
                  '-',...
                  'Color',expRampColor,...
                  'LineWidth',lineWidthModel,...
                  'DisplayName',labelHL1997,...
                  'HandleVisibility','off');   
            hold on;
    
            
        end
    end



    for idx=1:1:3
        subplot('Position',reshape(subPlotLayout(1,idx,:),1,4));
        if(idx > 1)
            yyaxis left;
        end
        xlim(plotSettings(idx).xLim);
        ylim(plotSettings(idx).yLim);        
        xticks(plotSettings(idx).xTicks);
        yticks(plotSettings(idx).yTicks);
        box off;        
    end
    for idx=4:1:5
        subplot('Position',reshape(subPlotLayout(1,idx-2,:),1,4));
        yyaxis right;
        xlim(plotSettings(idx).xLim);
        ylim(plotSettings(idx).yLim);        
        xticks(plotSettings(idx).xTicks);
        yticks(plotSettings(idx).yTicks);
        box off;

    end

    subplot('Position',reshape(subPlotLayout(1,1,:),1,4));
        xlabel('Norm. Velocity ($$v^P/v^{M}_{max}$$)');
        ylabel('Norm. Force ($$f/f^{M}_o$$)');
        title('A. Force-velocity relation measurements');  


    subplot('Position',reshape(subPlotLayout(1,2,:),1,4));
        yyaxis left;    
        xlabel('Time (ms)');
        ylabel('Norm. Force ($$f/f^{M}_o$$)');    
        title('B. Ramp-shortening measurements');  
        ax=gca;
        ax.YAxis(1).Color = [0,0,0];
        ax.YAxis(2).Color = lineColorRampA;        
        legend('Location','NorthWest');

        yyaxis right;
        ylabel('Norm. Length ($$(\ell^P-\ell^T_s)/\ell^{M}_o$$)');
        
    subplot('Position',reshape(subPlotLayout(1,3,:),1,4));
        yyaxis left;
        xlabel('Time (ms)');
        ylabel('Norm. Force ($$f/f^{M}_o$$)');    
        title('B. Ramp-lengthening measurements'); 
        ax=gca;
        ax.YAxis(1).Color = [0,0,0];
        ax.YAxis(2).Color = lineColorRampA;        
        legend('Location','NorthWest');

        yyaxis right;
        ylabel('Norm. Length ($$(\ell^P-\ell^T_s)/\ell^{M}_o$$)');

    here=1;
end

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
        if(idx <= indexRamp0)
            [val,idx]=max(abs(lsdynaMuscleUniform.vp(indexRamp0:indexRamp1,1)));
            idx = indexRamp0+idx-1;
        end
        assert(idx >= indexRamp0,...
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
            vsN = vsN.*(1/vceNMax); 
        case 'umat43'
            vsN = vsN;           
        case 'viva'
            vsN = vsN.*(1/vceNMax);
        otherwise assert(0)
    end    

    fvN = (fsN-fpNSample);

   
    %%
    % Plot the time domain signals
    %%
  
    if(      (   trialNumber >= numberHL1997ShorteningStart ...
              && trialNumber <= numberHL1997ShorteningEnd) ...
          || (   trialNumber >= numberHL1997LengtheningStart ...
              && trialNumber <= numberHL1997LengtheningEnd) ) 

        flag_firstTrial=0;
        flag_lastTrial=0;
        if(    (   trialNumber >= numberHL1997ShorteningStart ...
                && trialNumber <=numberHL1997ShorteningEnd) )

            subplot('Position',reshape(subPlotLayout(indexModel+1,2,:),1,4));
            n = (trialNumber-numberHL1997ShorteningStart)...
                /(numberHL1997ShorteningEnd-numberHL1997ShorteningStart);
            dySign=-1;
            idxColumn =2;
            if(trialNumber==numberHL1997ShorteningStart)
                flag_firstTrial=1;
            end
            if(trialNumber==numberHL1997ShorteningEnd)
                flag_lastTrial=1;
            end            
        elseif( (   trialNumber >= numberHL1997LengtheningStart ...
                 && trialNumber <= numberHL1997LengtheningEnd) )
            subplot('Position',reshape(subPlotLayout(indexModel+1,3,:),1,4));
            n = (trialNumber-numberHL1997LengtheningStart)...
                /(numberHL1997LengtheningEnd-numberHL1997LengtheningStart);            
            dySign=1;            
            idxColumn =3;
            if(trialNumber==numberHL1997LengtheningStart)
                flag_firstTrial=1;
            end
            if(trialNumber==numberHL1997LengtheningEnd)
                flag_lastTrial=1;
            end
        else
            assert(0,'Error: Somehow an invalid trial number made it into this if statement');
        end

        handleVisibility='off';
        if(flag_lastTrial==1)
            handleVisibility='on';
        end

        lineColor = lineColorB.*(1-n) + lineColorA.*(n);
        lineColorRamp = lineColorRampB.*(1-n)+lineColorRampA.*n;

        displayNameStr = [lsdynaMuscleUniform.nameLabel, sprintf('(%1.1f)',act)];
        
        yyaxis left;

        if(flag_firstTrial==1)
            plot(plotSettings(idxColumn).xLim,[1,1],...
                 '-',...
                 'Color',[0,0,0],...
                 'LineWidth',1,...
                 'HandleVisibility','off');
            hold on;
            text(min(plotSettings(2).xLim),1,'$$f^M_o$$',...
                'HorizontalAlignment','left',...
                'VerticalAlignment','bottom',...
                'FontSize',6);
            hold on;
        end

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
            'Color',lineColorA,...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;
        box off;

 
%         hTxt=text(   lsdynaMuscleUniform.time(indexSample,1),...
%                      lsdynaMuscleUniform.fmtN(indexSample,1),...
%                      sprintf('%s%1.2f%s','$$',pathVel,' \ell^M_o/s$$'),...
%                      'HorizontalAlignment','left',...
%                      'VerticalAlignment',vAlign,...
%                      'FontSize',6);
%         hold on;

        yyaxis right;
        plot(lsdynaMuscleUniform.time,...
             (lsdynaMuscleUniform.lp-tendonSlackLength)./optimalFiberLength, ...
             '-',...
            'Color',[1,1,1],...
            'LineWidth',lineWidthModel+1,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off'); 
        hold on;
        plot(lsdynaMuscleUniform.time,...
             (lsdynaMuscleUniform.lp-tendonSlackLength)./optimalFiberLength, ...
             lineType,...
            'Color',lineColorRamp,...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;


    end
    
    %time,act,lceN,vsN,fvN
    if(contains(simulationFile,fileNameMaxActStart))
        fid=fopen([simulationFolder,filesep,'record.csv'],'w');
        fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',timeSample,act,lceN,vsN,fvN);
        fclose(fid);

    elseif(contains(simulationFile,fileNameMaxActEnd))
        fid=fopen([simulationFolder,filesep,'record.csv'],'a');
        fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',timeSample,act,lceN,vsN,fvN);
        fclose(fid);

        lineColor = lineColorA;

        dataFv = csvread([simulationFolder,filesep,'record.csv']);

        subplot('Position',reshape(subPlotLayout(indexModel+1,1,:),1,4));        
        
        [valMap,idxMap] = sort(dataFv(:,4));

        displayNameStr = [lsdynaMuscleUniform.nameLabel, sprintf('(%1.1f)',act)]; 
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
            'HandleVisibility','on',...
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

    elseif(contains(simulationFile,fileNameSubMaxActEnd))
        fid=fopen([simulationFolder,filesep,'record.csv'],'a');
        fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',timeSample,act,lceN,vsN,fvN);
        fclose(fid);

        lineColor = lineColorA;

        dataFv = csvread([simulationFolder,filesep,'record.csv']);
        [valMap,idxMap] = sort(dataFv(:,4));

        subplot('Position',reshape(subPlotLayout(indexModel+1,1,:),1,4));        
        
        displayNameStr = [lsdynaMuscleUniform.nameLabel, sprintf('(%1.1f)',act)]; 
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
            'HandleVisibility','on',...
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

        legend('Location','NorthWest');     

        text(max(plotSettings(1).xLim),...
             min(plotSettings(1).yLim),...
            sprintf('%s: %1.2f%s','$$v^M_{max}',vceNMax*scaleV,'\ell^M_o/s$$'),...
            'FontSize',6,...
            'HorizontalAlignment','right',...
            'VerticalAlignment','bottom');
        hold on
    


    else 
        fid=fopen([simulationFolder,filesep,'record.csv'],'a');
        fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',timeSample,act,lceN,vsN,fvN);
        fclose(fid);
    end

end

if(trialNumber==numberSubMaxActEnd)
    subPlotLabel0 = 'D.';
    subPlotLabel1 = 'E.';
    subPlotLabel2 = 'F.';
    
    switch lsdynaMuscleUniform.name
        case 'umat41'
            subPlotLabel0 = 'H.';
            subPlotLabel1 = 'I.';
            subPlotLabel2 = 'J.';
        case 'umat43'
            subPlotLabel0 = 'K.';
            subPlotLabel1 = 'L.';
            subPlotLabel2 = 'M.';
        case 'viva'
            subPlotLabel0 = 'D.';
            subPlotLabel1 = 'E.';
            subPlotLabel2 = 'F.';
        otherwise assert(0)
    end
    
    flag_moveTicksInsidePlot=0;

    idx=1;
    subplot('Position',reshape(subPlotLayout(indexModel+1,idx,:),1,4));
    
    xlim(plotSettings(idx).xLim);
    ylim(plotSettings(idx).yLim);
    xticks(plotSettings(idx).xTicks);
    yticks(plotSettings(idx).yTicks); 
    
    if(flag_moveTicksInsidePlot==1)
        xticklabels(cell(1, length(xticks)));
        yticklabels(cell(1, length(xticks)));
        for i=1:1:length(plotSettings(idx).xTicks)
            align = 'left';
            if(i==length(plotSettings(idx).xTicks))
                align='right';
            end
            text(plotSettings(idx).xTicks(1,i),...
                 0,...
                 sprintf('%d',round(plotSettings(idx).xTicks(1,i))),...
                 'FontSize',6,...
                 'HorizontalAlignment',align,...
                 'VerticalAlignment','bottom');
            hold on;
        end
        for i=1:1:length(plotSettings(idx).yTicks)
            text(plotSettings(idx).xLim(1,1),...
                 plotSettings(idx).yTicks(1,i),...
                 sprintf('%1.2f',plotSettings(idx).yTicks(1,i)),...
                 'FontSize',6,...
                 'HorizontalAlignment','left',...
                 'VerticalAlignment','middle');
            hold on;
        end
    end
    
    xlabel('Norm. Velocity ($$v^P/v^{M}_{max}$$)');
    ylabel('Norm. Force ($$f/f^{M}_o$$)');
    legend('Location','NorthWest');
    
    title(sprintf('%s %s force-velocity relation',...
                  subPlotLabel0,lsdynaMuscleUniform.nameLabel));
    

    idx=2;
    subplot('Position',reshape(subPlotLayout(indexModel+1,idx,:),1,4));
    
    yyaxis left;
    xlim(plotSettings(idx).xLim);
    ylim(plotSettings(idx).yLim);
    xticks(plotSettings(idx).xTicks);
    yticks(plotSettings(idx).yTicks); 
    
    if(flag_moveTicksInsidePlot==1)
        xticklabels(cell(1, length(xticks)));
        yticklabels(cell(1, length(xticks)));
        for i=1:1:length(plotSettings(idx).xTicks)
            align = 'left';
            if(i==length(plotSettings(idx).xTicks))
                align='right';
            end        
            text(plotSettings(idx).xTicks(1,i),...
                 plotSettings(idx).yLim(1,1),...
                 sprintf('%d',round(plotSettings(idx).xTicks(1,i))),...
                 'FontSize',6,...
                 'HorizontalAlignment',align,...
                 'VerticalAlignment','bottom');
            hold on;
        end
        for i=1:1:length(plotSettings(idx).yTicks)
            text(plotSettings(idx).xLim(1,1),...
                 plotSettings(idx).yTicks(1,i),...
                 sprintf('%1.2f',plotSettings(idx).yTicks(1,i)),...
                 'FontSize',6,...
                 'HorizontalAlignment','left',...
                 'VerticalAlignment','middle');
            hold on;
        end
    end
    
    xlabel('Time (ms)');
    ylabel('Norm. Force ($$f/f^{M}_o$$)');
    box off;
    
    yyaxis right;
    ylim(plotSettings(idx+2).yLim);
    yticks(plotSettings(idx+2).yTicks); 
    
    if(flag_moveTicksInsidePlot==1)
        yticklabels(cell(1, length(xticks)));
        for i=1:1:length(plotSettings(idx+2).yTicks)
            text(plotSettings(idx+2).xLim(1,2),...
                 plotSettings(idx+2).yTicks(1,i),...
                 sprintf('%1.2f',plotSettings(idx+2).yTicks(1,i)),...
                 'FontSize',6,...
                 'HorizontalAlignment','right',...
                 'VerticalAlignment','middle');
            hold on;
        end
    end

    ylabel('Norm. Length ($$(\ell^P-\ell^T_s)/\ell^{M}_o$$)');
    box off;
    
    ax=gca;
    ax.YAxis(1).Color = lineColorA;
    ax.YAxis(2).Color = lineColorRampA;
    
    title(sprintf('%s %s Shortening responses',...
        subPlotLabel1,lsdynaMuscleUniform.nameLabel));

    legend('Location','NorthEast');
    
    
    idx=3;
    subplot('Position',reshape(subPlotLayout(indexModel+1,idx,:),1,4));
    
    yyaxis left;
    xlim(plotSettings(idx).xLim);
    ylim(plotSettings(idx).yLim);
    xticks(plotSettings(idx).xTicks);
    yticks(plotSettings(idx).yTicks); 
    if(flag_moveTicksInsidePlot==1)
        xticklabels(cell(1, length(xticks)));
        yticklabels(cell(1, length(xticks)));
        for i=1:1:length(plotSettings(idx).xTicks)
            align = 'left';
            if(i==length(plotSettings(idx).xTicks))
                align='right';
            end        
            text(plotSettings(idx).xTicks(1,i),...
                 0,...
                 sprintf('%d',round(plotSettings(idx).xTicks(1,i))),...
                 'FontSize',6,...
                 'HorizontalAlignment',align,...
                 'VerticalAlignment','bottom');
            hold on;
        end
        for i=1:1:length(plotSettings(idx).yTicks)
            text(0,...
                 plotSettings(idx).yTicks(1,i),...
                 sprintf('%1.2f',plotSettings(idx).yTicks(1,i)),...
                 'FontSize',6,...
                 'HorizontalAlignment','left',...
                 'VerticalAlignment','middle');
            hold on;
        end
    end
    xlabel('Time (ms)');
    ylabel('Norm. Force ($$f/f^{M}_o$$)');
    box off;
    
    yyaxis right;
    ylim(plotSettings(idx+2).yLim);
    yticks(plotSettings(idx+2).yTicks);     
    if(flag_moveTicksInsidePlot==1)
        
        yticklabels(cell(1, length(xticks)));
        for i=1:1:length(plotSettings(idx+2).yTicks)
            text(plotSettings(idx+2).xLim(1,2),...
                 plotSettings(idx+2).yTicks(1,i),...
                 sprintf('%1.2f',plotSettings(idx+2).yTicks(1,i)),...
                 'FontSize',6,...
                 'HorizontalAlignment','right',...
                 'VerticalAlignment','middle');
            hold on;
        end
    end
    ylabel('Norm. Length ($$(\ell^P-\ell^T_s)/\ell^{M}_o$$)');
    box off;
    
    ax=gca;
    ax.YAxis(1).Color = lineColorA;
    ax.YAxis(2).Color = lineColorRampA;
    
    title(sprintf('%s %s Lengthening responses',...
        subPlotLabel2,lsdynaMuscleUniform.nameLabel));

    legend('Location','NorthEast');

end

here=1;
