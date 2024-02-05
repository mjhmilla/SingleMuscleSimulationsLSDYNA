function [figH] = ...
    plotForceVelocitySimulationDataForPublication(figH,...
                      lsdynaBinout,lsdynaMuscleUniform,d3hspFileName, ...
                      indexModel,subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationDirectoryName,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...                       
                      referenceCurveFolder,...
                      muscleArchitecture,...
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      lineColorA, lineColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);

fontSizeLegend=6;

flag_addHerzogLeonard1997=1;
flag_addBrownScottLoeb1996=1;
flag_addScottBrownLoeb1996=1;
flag_addMashimaAkazawaKushimaFujii1972=1;

if(contains(simulationDirectoryName,'isometric'))
    flag_addSimulationData=0;
end

trialFolder=pwd;
cd ..;
simulationFolder=pwd;
cd(trialFolder);

%These files hold the processed experimental data which is used to 
%evaluate the RMSE of the (interpolated) model values
fileExpDataForceVelocity        = [simulationFolder,filesep,'dataExpForceVelocity.csv'];
fileExpDataForceVelocitySubmax  = [simulationFolder,filesep,'dataExpForceVelocitySubmax.csv'];
idHerzogLeonard1997             = 1;
idBrownScottLoeb1996            = 2;
idScottBrownLoeb1996            = 3;
idMashimaAkazawaKushimaFujii1972= 4;

lineColorRampA = [149, 69, 53]./256;%[1,1,1].*0.5;
lineColorRampB = lineColorRampA*0.5;
markerFaceColor= lineColorRampA;


lineAndMarkerSettings.lineType        = '-';
lineAndMarkerSettings.lineColor       = lineColorA;
lineAndMarkerSettings.lineWidth       = 1;
lineAndMarkerSettings.mark            = lsdynaMuscleUniform.mark;
lineAndMarkerSettings.markerFaceColor = lineColorA;
lineAndMarkerSettings.markerLineWidth = 1;
lineAndMarkerSettings.markerSize      = 4;   

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;
vceNMax                 = getParameterValueFromD3HSPFile(d3hspFileName, 'VCEMAX');





simMetaData.fileNameShorteningStart         = 'force_velocity_00';
simMetaData.fileNameShorteningEnd           = 'force_velocity_06';
simMetaData.numberMaxShorteningStart        = 0; 
simMetaData.numberMaxShorteningEnd          = 6;

simMetaData.fileNameLengtheningStart        = 'force_velocity_07';
simMetaData.fileNameLengtheningEnd          = 'force_velocity_13';
simMetaData.numberMaxLengtheningStart       = 7;
simMetaData.numberMaxLengtheningEnd         = 13;

simMetaData.fileNameMaxActStart             = 'force_velocity_00';
simMetaData.fileNameMaxActEnd               = 'force_velocity_13';
simMetaData.numberMaxActStart               = 0;
simMetaData.numberMaxActEnd                 = 13;

simMetaData.fileNameSubMaxActStart          = 'force_velocity_14';
simMetaData.fileNameSubMaxActEnd            = 'force_velocity_27';
simMetaData.numberSubMaxActStart            = 14;
simMetaData.numberSubMaxActEnd              = 27;

simMetaData.numberHL1997ShorteningStart     = 0;
simMetaData.numberHL1997ShorteningEnd       = 4;
simMetaData.numberHL1997LengtheningStart    = 7;
simMetaData.numberHL1997LengtheningEnd      = 11;
simMetaData.numberHL1997Total               = 10;
simMetaData.fileNameIsometric               = 'isometric';

%%
% Timing Information
%%

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

%%
%Plotting settings
%%
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


leftPos = 0.15;%max(plotSettings(idx-2).yLim)-leftPos;
a = max(plotSettings(idx-2).yLim)-leftPos;
b = leftPos-min(plotSettings(idx-2).yLim);
d = max(plotSettings(idx).yTicks)-min(plotSettings(idx).yTicks);
c = d*a/b;
yMax = max(plotSettings(idx).yTicks)+c;

plotSettings(idx).yLim   = [0.85,yMax];

idx=5;
plotSettings(idx).xLim   = plotSettings(idx-1).xLim;
plotSettings(idx).xTicks = plotSettings(idx-1).xTicks;
plotSettings(idx).yTicks = [0.9,1];

leftPos = 0.15;%max(plotSettings(idx-2).yLim)-leftPos;
a = max(plotSettings(idx-2).yLim)-leftPos;
b = leftPos-min(plotSettings(idx-2).yLim);
d = max(plotSettings(idx).yTicks)-min(plotSettings(idx).yTicks);
c = d*a/b;
yMax = max(plotSettings(idx).yTicks)+c;

plotSettings(idx).yLim   = [0.85,yMax];

lineType = '-';

subplotFv              = reshape(subPlotLayout(indexModel+1,1,:),1,4);
subplotFvConTimeSeries = reshape(subPlotLayout(indexModel+1,2,:),1,4);
subplotFvEccTimeSeries = reshape(subPlotLayout(indexModel+1,3,:),1,4);

% Add the reference data
if(flag_addReferenceData==1)

    subplotFvExp              = reshape(subPlotLayout(1,1,:),1,4);
    subplotFvConTimeSeriesExp = reshape(subPlotLayout(1,2,:),1,4);
    subplotFvEccTimeSeriesExp = reshape(subPlotLayout(1,3,:),1,4);

    %Wipe the processed data files clean
    fid=fopen(fileExpDataForceVelocity,'w');
    fclose(fid);
    fid=fopen(fileExpDataForceVelocitySubmax,'w');
    fclose(fid);


    if(flag_addScottBrownLoeb1996==1)
        labelSBL1996='Exp: SBL1996 Cat Sol WM';
        expColor = [1,1,1].*0.8;
        vceMaxExp=4.5;
        figH = addScottBrownLoeb1996ForceVelocity(...
                figH,subplotFvExp, labelSBL1996, ...
                expColor,...
                vceMaxExp,...
                fileExpDataForceVelocity,...
                idScottBrownLoeb1996);

    end

    if(flag_addBrownScottLoeb1996==1)
        labelBSL1996='Exp: BSL1996 Cat Sol WM';
        expColor = [1,1,1].*0.65;
        vceMaxExp=4;
        figH = addBrownScottLoeb1996ForceVelocity(...
                figH,subplotFvExp, labelBSL1996, ...
                expColor,...
                vceMaxExp,...
                fileExpDataForceVelocity,...
                idBrownScottLoeb1996);
    
    end

    if(flag_addMashimaAkazawaKushimaFujii1972==1)
        labelMAKF1972='Exp: MAKF1972 Frog F';
        expColor = [1,1,1].*0.5;
        vceMaxExp=3.75;
        figH = addMashimaAkazawaKushimaFujii1972ForceVelocity(...
                figH,subplotFvExp, labelMAKF1972, ...
                expColor,...
                vceMaxExp,...
                fileExpDataForceVelocitySubmax,...
                idMashimaAkazawaKushimaFujii1972);
    end

    if(flag_addHerzogLeonard1997==1)
        %%
        % Plot Herzog & Leonard 1997
        %%
        labelHL1997='Exp: HL1997 Cat S WM';
     
        % Graphically measured from Herzog and Leonard 1997 Fig. 1A    
        fisoHL1997 = 37.4576;
    
        % Graphically measured from Figure 4 of Scott, Brown, Loeb
        %Scott SH, Brown IE, Loeb GE. Mechanics of feline soleus: I. Effect of 
        % fascicle length and velocity on force output. Journal of Muscle 
        % Research & Cell Motility. 1996 Apr;17:207-19.
        vmaxSBL1996 = 4.65; 
    
        % Optimal fiber length from 
        % Scott SH, Loeb GE. Mechanical properties of aponeurosis and tendon 
        % of the cat soleus muscle during whole‐muscle isometric contractions. 
        % Journal of Morphology. 1995 Apr;224(1):73-86.
        lceOptHL1997 = 38.0/1000;
    
        musclePropertiesHL1997.fiso     = fisoHL1997;
        musclePropertiesHL1997.lceOpt   = lceOptHL1997;
        musclePropertiesHL1997.vmax     = vmaxSBL1996;
        
        expColorA = [1,1,1].*0.75;
        expColorB = [1,1,1].*0;
    
        addConcentricData = -1;
        addEccentricData  =  1;
    
        [figH, dataFvConcSample] = ...
            addHerzogLeonard1997TimeSeries(...
                figH,subplotFvConTimeSeriesExp,labelHL1997,...
                expColorA,expColorB,...
                lineColorRampA,lineColorRampB,...
                lineAndMarkerSettings.lineWidth,...  
                plotSettings,...            
                musclePropertiesHL1997,...
                addConcentricData);
    
        [figH, dataFvEccSample] = ...
            addHerzogLeonard1997TimeSeries(...
                figH,subplotFvEccTimeSeriesExp,labelHL1997,...
                expColorA,expColorB,...
                lineColorRampA,lineColorRampB,...
                lineAndMarkerSettings.lineWidth,...  
                plotSettings,...
                musclePropertiesHL1997,...
                addEccentricData);
    
    
    
        dataFvSample = [dataFvConcSample;dataFvEccSample];
        [val,idxMap] = sort(dataFvSample(:,1));
        dataFvSample = dataFvSample(idxMap,:);
    
        expColor = expColorB;
        figH = addHerzogLeonard1997ForceVelocity(...
                        figH,subplotFvExp,labelHL1997,...
                        dataFvSample, ...
                        expColor,...
                        lineAndMarkerSettings.lineWidth,...
                        plotSettings,...
                        musclePropertiesHL1997,...
                        fileExpDataForceVelocity,...
                        idHerzogLeonard1997); 


    end

end

% Add the simulation data
if(flag_addSimulationData==1)  


    contractionDirection=-1;

    [figH, simFvSample] = ...
        addSimulationForceVelocityTimeSeries(...
            indexModel,lsdynaMuscleUniform,d3hspFileName,...
            simulationDirectoryName,simMetaData,...
            figH,subPlotLayout,...
            lineColorA, lineColorB,...
            lineColorRampA,lineColorRampB,...
            lineAndMarkerSettings,...
            plotSettings,...
            muscleArchitecture,...        
            contractionDirection);


    appendWriteFlag = 'a';
    if(contains(simulationDirectoryName,simMetaData.fileNameMaxActStart)...
            || contains(simulationDirectoryName,simMetaData.fileNameSubMaxActStart))
        appendWriteFlag = 'w';        
    end
    fid=fopen([simulationFolder,filesep,'record.csv'],appendWriteFlag);
    fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',...
                simFvSample(1,1),...
                simFvSample(1,2),...
                simFvSample(1,3),...
                simFvSample(1,4),...
                simFvSample(1,5));
    fclose(fid);

    disp(simulationDirectoryName);

    %time,act,lceN,vsN,fvN
    if(contains(simulationDirectoryName,simMetaData.fileNameMaxActEnd) ...
            || contains(simulationDirectoryName,simMetaData.fileNameSubMaxActEnd))

        lineAndMarkerSettings.lineType='-';
        if(contains(simulationDirectoryName,simMetaData.fileNameSubMaxActEnd))
            lineAndMarkerSettings.lineType='--';
        end

        dataFv = csvread([simulationFolder,filesep,'record.csv']);
       

        figH = addSimulationForceVelocity(...
                            figH,subplotFv,...
                            dataFv, ...
                            lsdynaMuscleUniform,...
                            lineAndMarkerSettings);

        if(contains(simulationDirectoryName,simMetaData.fileNameMaxActEnd))

            idxSimE = find(dataFv(:,4)>0);
            idxSimC = find(dataFv(:,4)<0);
            

            dataExp=readmatrix(fileExpDataForceVelocity,'Delimiter',',');

            errVec = zeros(size(dataExp,1),2).*nan;
            for indexData=1:1:size(dataExp,1)
                vceNExp = dataExp(indexData,1);
                fceNExp = dataExp(indexData,2);
                if(vceNExp < 0)
                    errVec(indexData,1) = ...
                             interp1(dataFv(idxSimC,4),...
                                     dataFv(idxSimC,5),...
                                     vceNExp,...
                                     'linear',...
                                     'extrap')-fceNExp;
                else
                    errVec(indexData,2) = ...
                             interp1(dataFv(idxSimE,4),...
                                     dataFv(idxSimE,5),...
                                     vceNExp,...
                                     'linear',...
                                     'extrap')-fceNExp;
                end
             end

             idxC = find(~isnan(errVec(:,1)));
             idxE = find(~isnan(errVec(:,2)));

             errRmseC = sqrt(mean(errVec(idxC,1).^2)); 
             errRmseE = sqrt(mean(errVec(idxE,2).^2)); 

             text(-1,1.0,sprintf('RMSE Conc.\n%1.3e',errRmseC),...
                 'HorizontalAlignment','left',...
                 'VerticalAlignment','middle',...
                 'FontSize',6);
             hold on;

             text( 1,1.0,sprintf('RMSE Ecc.\n%1.3e',errRmseE),...
                 'HorizontalAlignment','right',...
                 'VerticalAlignment','middle',...
                 'FontSize',6);
             hold on;

        end

        if(contains(simulationDirectoryName,simMetaData.fileNameSubMaxActEnd))
            figure(figH);
            subplot('Position',subplotFv);
            legend('Location','NorthWest');     
            text(max(plotSettings(1).xLim),...
                 min(plotSettings(1).yLim),...
                sprintf('%s: %1.2f%s','$$v^M_{max}',vceNMax,'\ell^M_o/s$$'),...
                'FontSize',6,...
                'HorizontalAlignment','right',...
                'VerticalAlignment','bottom');
            hold on
        end

    end


end



if(contains(simulationDirectoryName,simMetaData.fileNameSubMaxActEnd)==1 || ...
   contains(simulationDirectoryName,'_00')==1)

    plotRowsToFormat = [];
    if(contains(simulationDirectoryName,'_00')==1)
        plotRowsToFormat = [1,(indexModel+1)];
    else
        plotRowsToFormat = (indexModel+1);
    end

    for indexRow = 1:1:length(plotRowsToFormat)
        row = plotRowsToFormat(1,indexRow);

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
            case 'mat156'
                subPlotLabel0 = 'D.';
                subPlotLabel1 = 'E.';
                subPlotLabel2 = 'F.';
            otherwise assert(0)
        end

        if(row==1)
            subPlotLabel0 = 'A. ';
            subPlotLabel1 = 'B.';
            subPlotLabel2 = 'C.';
        end

        for idx=1:1:3
            subplot('Position',reshape(subPlotLayout(row,idx,:),1,4));
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
            subplot('Position',reshape(subPlotLayout(row,idx-2,:),1,4));
            yyaxis right;
                xlim(plotSettings(idx).xLim);
                ylim(plotSettings(idx).yLim);        
                xticks(plotSettings(idx).xTicks);
                yticks(plotSettings(idx).yTicks);
                box off;    
        end
    
        subplot('Position',reshape(subPlotLayout(row,1,:),1,4));
            xlabel('Norm. Velocity ($$v^P/v^{M}_{max}$$)');
            ylabel('Norm. Force ($$f/f^{M}_o$$)');
            title([subPlotLabel0,' Force-velocity relation measurements']);  
        
        
        subplot('Position',reshape(subPlotLayout(row,2,:),1,4));
        yyaxis left;    
            xlabel('Time (ms)');
            ylabel('Norm. Force ($$f/f^{M}_o$$)');    
            title([subPlotLabel1,' Ramp-shortening measurements']);  
            ax=gca;
            ax.YAxis(1).Color = [0,0,0];
            ax.YAxis(2).Color = lineColorRampA;        
            legend('Location','NorthWest');
        
        yyaxis right;
            dx = diff(plotSettings(4).xLim)*0.025;
            hT = text(plotSettings(4).xLim(1,2)+dx,1.15,...
                'Norm. Length ($$(\ell^P-\ell^T_s)/\ell^{M}_o$$)',...
                'HorizontalAlignment','left',...
                'VerticalAlignment','top',...
                'FontSize',8,...
                'Color',lineColorRampA);
            set(hT,'rotation',90);
            %ylabel('Norm. Length ($$(\ell^P-\ell^T_s)/\ell^{M}_o$$)');
        
        subplot('Position',reshape(subPlotLayout(row,3,:),1,4));
        yyaxis left;
            xlabel('Time (ms)');
            ylabel('Norm. Force ($$f/f^{M}_o$$)');    
            title([subPlotLabel2,' Ramp-lengthening measurements']); 
            ax=gca;
            ax.YAxis(1).Color = [0,0,0];
            ax.YAxis(2).Color = lineColorRampA;        
            legend('Location','NorthWest');
        
        yyaxis right;
        %ylabel('Norm. Length ($$(\ell^P-\ell^T_s)/\ell^{M}_o$$)');
        %yyaxis right;
        hT = text(plotSettings(4).xLim(1,2)+dx,1.15,...
            'Norm. Length ($$(\ell^P-\ell^T_s)/\ell^{M}_o$$)',...
            'HorizontalAlignment','left',...
            'VerticalAlignment','top',...
            'FontSize',8,...
            'Color',lineColorRampA);
        set(hT,'rotation',90);
    end
end




here=1;
