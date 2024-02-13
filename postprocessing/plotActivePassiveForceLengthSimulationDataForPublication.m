function [figH] = ...
    plotActivePassiveForceLengthSimulationDataForPublication(figH,...
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

flag_plotInNormalizedCoordinates=1;
flag_plotSmeulders2004     =0;
flag_plotGollapudiLin2009 = 0;
flag_plotSiebert2015      = 0;
flag_plotWinters2011      = 0;
flag_plotScottBrownLoeb1996_fig3_active=1;
flag_plotScottBrownLoeb1996_fig3_passive=0;


flag_plotBrownScottLoeb1996_fig7=1;
flag_plotRodeSiebertHerzogBlickhan2009=1;

flag_passiveStiffnessRmse=0;

xTextRmse=1.6;
yTextRmse=0.2;

trialFolder=pwd;
cd ..;
simulationFolder=pwd;
cd(trialFolder);

%%
%Active and passive data points of the starting of the Herzog & Leonard
%1997 force-velocity data
%%
dataHL1997.dl   = [0.894242,1.10606]-0.894242;
dataHL1997.fpe  = [0.0264486,0.08545676];
dataHL1997.fa   = [0.856798,1.15101]-dataHL1997.fpe;
dataHL1997.fa   = dataHL1997.fa-dataHL1997.fa(1,1);
dataHL1997.rectangle.fl =   [dl(1,1),dfa(1,1);...
                             dl(1,2),dfa(1,1);...
                             dl(1,2),dfa(1,2);...
                             dl(1,1),dfa(1,2);...
                             dl(1,1),dfa(1,1)];
dataHL1997.rectangle.fpe =  [dl(1,1),dfpe(1,1);...
                             dl(1,2),dfpe(1,1);...
                             dl(1,2),dfpe(1,2);...
                             dl(1,1),dfpe(1,2);...
                             dl(1,1),dfpe(1,1)];


%These files hold the processed experimental data which is used to 
%evaluate the RMSE of the (interpolated) model values
fileExpDataActiveForceLength    = [simulationFolder,filesep,'dataExpActive.csv'];
fileExpDataPassiveForceLength   = [simulationFolder,filesep,'dataExpPassive.csv'];
idRodeSiebertHerzogBlickhan2009 = 1;
idScottBrownLoeb1996            = 2;
idBrownScottLoeb1996            = 3;

indexRow = indexModel;

m2mm=1000;

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;

lineWidthData=1;
lineWidthModel=1;

fileNameMaxActStart     = 'active_force_length_00';
fileNameMaxActLast      = 'active_force_length_14';
fileNameSubMaxActStart  = 'active_force_length_15';
fileNameSubMaxActLast   = 'active_force_length_19';

fileNameMaxActStart     = 'active_force_length_00';
fileNameSubMaxActStart  = 'active_force_length_15';
numberSubMaxActStart    = 16;

fileNameMaxActOpt       = 'active_force_length_06';
fileNameSubMaxActOpt    = 'active_force_length_16';

flag_viva=0;
if(contains(lsdynaMuscleUniform.nameLabel,'VIVA+'))
    flag_viva=1;
end

plotSettings(3) = struct('yLim',[],'xLim',[],'yTicks',[],'xTicks',[]);

timeEnd   = lsdynaMuscleUniform.eloutTime(end,1);
timeStart = lsdynaMuscleUniform.eloutTime(1,1);
timeEpsilon = (timeEnd-timeStart)/1000;
timeDelta   = (timeEnd-timeStart)/100;

timeA = timeStart + (timeEnd-timeStart)*(0.25);
timeMid=timeStart + (timeEnd-timeStart)*(0.5);
timeB = timeStart + (timeEnd-timeStart)*(0.75);

indexA = find(lsdynaMuscleUniform.eloutTime > timeA,1);
indexB = find(lsdynaMuscleUniform.eloutTime > timeB,1);
timeA = lsdynaMuscleUniform.time(indexA,1);
timeB = lsdynaMuscleUniform.time(indexB,1);

idx=1;
plotSettings(idx).xLim  = round([50,240],3,'significant');
plotSettings(idx).yLim  = round([0,1.501].*maximumIsometricForce,3,'significant');
if(flag_viva)
    plotSettings(idx).xTicks = ...
        round([60,optimalFiberLength,240],3,'significant');
else
    plotSettings(idx).xTicks = ...
        round([60,optimalFiberLength,optimalFiberLength+tendonSlackLength,240],3,'significant');
end
plotSettings(idx).yTicks = round([0,1].*maximumIsometricForce,3,'significant');

idx=2;
plotSettings(idx).xLim   = plotSettings(1).xLim;
plotSettings(idx).yLim   = plotSettings(1).yLim;
plotSettings(idx).xTicks = plotSettings(1).xTicks;
plotSettings(idx).yTicks = plotSettings(1).yTicks;

idx=3;
plotSettings(idx).xLim   = round([(timeStart-timeEpsilon),(timeEnd+timeEpsilon)],3,'significant');
plotSettings(idx).yLim   = plotSettings(1).yLim;
plotSettings(idx).xTicks = round([timeStart,timeA,timeMid,timeB,timeEnd],3,'significant');
plotSettings(idx).yTicks = plotSettings(1).yTicks;

if(flag_plotInNormalizedCoordinates==1)    
    idx=1;
    plotSettings(idx).xLim   = round([0.2,2.0],3,'significant');
    plotSettings(idx).yLim   = round([0,1.501],3,'significant');
    plotSettings(idx).xTicks = round([0.5,1,1.6],3,'significant');
    plotSettings(idx).yTicks = round([0,1],3,'significant');
    
    idx=2;
    plotSettings(idx).xLim   = plotSettings(1).xLim;
    plotSettings(idx).yLim   = plotSettings(1).yLim;
    plotSettings(idx).xTicks = plotSettings(1).xTicks;
    plotSettings(idx).yTicks = plotSettings(1).yTicks;

    
    idx=3;
    plotSettings(idx).xLim  = round([(timeStart-timeEpsilon),(timeEnd+timeEpsilon)],3,'significant');
    plotSettings(idx).yLim  = plotSettings(1).yLim;
    plotSettings(idx).xTicks = round([timeStart,timeA,timeMid,timeB,timeEnd],3,'significant');
    plotSettings(idx).yTicks = plotSettings(1).yTicks;
end



lineType = '-';

lastTwoChar = simulationFile(1,end-1:1:end);
lastTwoNum  = str2num(lastTwoChar);
if(isempty(lastTwoNum) == 0)
    if(lastTwoNum >= numberSubMaxActStart)
        lineType='--';
    end
end

if (contains(simulationFile,fileNameSubMaxActOpt))
    lineType = '--';
end


subplotFpe      = reshape(subPlotLayout(indexRow,1,:),1,4);    
subplotFl       = reshape(subPlotLayout(indexRow,2,:),1,4);
subplotFlTime   = reshape(subPlotLayout(indexRow,3,:),1,4);

% Add the reference data
if(flag_addReferenceData==1)
    
    %Wipe the processed data files clean
    fid=fopen(fileExpDataActiveForceLength,'w');
    fclose(fid);
    fid=fopen(fileExpDataPassiveForceLength,'w');
    fclose(fid);
    
    if(flag_plotSiebert2015==1)
        labelSLRWS2015 = 'Exp: SLRWS2015 Rabbit GAS WM';
        expColor = [1,1,1].*0.9;
        disp('Warning: Siebert et al. experimental data not used in RMSE calculation');  
        figH = addSiebert2015ActiveForceLength(...
                figH,subplotFl, labelSLRWS2015, ...
                expColor,...
                muscleArchitecture, ...
                flag_plotInNormalizedCoordinates);
    
        figH = addSiebert2015PassiveForceLength(...
                figH,subplotFpe, labelSLRWS2015, ...
                expColor,...
                muscleArchitecture, ...
                flag_plotInNormalizedCoordinates);    
    end

    if(flag_plotRodeSiebertHerzogBlickhan2009==1)
        labelRSHB2009='Exp: RSHB2009 Cat Sol WM';
        colorRSHB2009a=[1,1,1].*0.75;
        colorRSHB2009b=[1,1,1].*0.75;
        figH = addRodeSiebertHerzogBlickhan2009ForceLength(...
                    figH,subplotFl,labelRSHB2009,...
                    colorRSHB2009a,colorRSHB2009b,...
                    muscleArchitecture,...
                    1,0,...
                    flag_plotInNormalizedCoordinates,...
                    fileExpDataActiveForceLength,...
                    idRodeSiebertHerzogBlickhan2009);

        figH = addRodeSiebertHerzogBlickhan2009ForceLength(...
                    figH,subplotFpe,labelRSHB2009,...
                    colorRSHB2009a,colorRSHB2009b,...
                    muscleArchitecture,...
                    0,1,...
                    flag_plotInNormalizedCoordinates,...
                    fileExpDataPassiveForceLength,...
                    idRodeSiebertHerzogBlickhan2009);
        
    end

    labelSBL1996 = 'Exp: SBL1996 Cat Sol WM';
    colorSBL1996A = [1,1,1].*0.5;
    colorSBL1996B = [1,1,1].*0.5;  

    if(flag_plotScottBrownLoeb1996_fig3_active==1)
        figH = addScottBrownLoeb1996ActiveForceLength(...
                figH,subplotFl, labelSBL1996, ...
                colorSBL1996A,colorSBL1996B,...
                muscleArchitecture, ...
                flag_plotInNormalizedCoordinates,...
                fileExpDataActiveForceLength,...
                idScottBrownLoeb1996);
    end

    if(flag_plotScottBrownLoeb1996_fig3_passive==1)
        figH = addScottBrownLoeb1996PassiveForceLength(...
                figH,subplotFpe, labelSBL1996, ...
                colorSBL1996A,colorSBL1996B,...
                muscleArchitecture, ...
                flag_plotInNormalizedCoordinates,...
                fileExpDataPassiveForceLength,...
                idScottBrownLoeb1996);
    end
    labelBSL1996 = 'Exp: BSL1996 Cat Sol WM';
    colorBSL1996 = [0,0,0];    
    if(flag_plotBrownScottLoeb1996_fig7==1)
        figH = addBrownScottLoeb1996ActiveForceLength(...
                        figH,subplotFl, labelBSL1996, ...
                        colorBSL1996,...
                        muscleArchitecture, ...
                        flag_plotInNormalizedCoordinates,...
                        fileExpDataActiveForceLength,...
                        idBrownScottLoeb1996);
    end



    if(flag_plotWinters2011==1)
        expColorA = [1,1,1].*0.7; 
        expColorB = [1,1,1].*0.3;     
        labelWTLW2011  = 'Exp: WTLW2011 Rabbit EDII/EDL/TA WM';
        disp('Warning: Winters et al. experimental data not used in RMSE calculation');      
        figH = addWinters2011ActiveForceLengthData(...
                        figH,subplotFl,labelWTLW2011,...
                        expColorA,expColorB,...
                        muscleArchitecture,...
                        flag_plotInNormalizedCoordinates);
    
        figH = addWinters2011PassiveForceLengthData(...
                        figH,subplotFpe,labelWTLW2011,...
                        expColorA,expColorB,...
                        muscleArchitecture,...
                        flag_plotInNormalizedCoordinates);
    end

    if(flag_plotGollapudiLin2009 == 1)
        expColor        = [0,0,0];
        labelGL2009     = 'Exp: GL2009 Human LGAS SF';
        lceOptHuman = 2.725;
        disp('Warning: Gollapudi et al. experimental data not used in RMSE calculation');    
        figH = addGollapudiLin2009ActiveForceLength(...
                figH,subplotFl,labelGL2009,expColor,...
                lceOptHuman,muscleArchitecture,...
                flag_plotInNormalizedCoordinates);
    
        figH = addGollapudiLin2009PassiveForceLength(...
                figH,subplotFpe,labelGL2009,expColor,...
                lceOptHuman,muscleArchitecture,...
                flag_plotInNormalizedCoordinates);    
    end

    if(flag_plotSmeulders2004==1)
        labelSKHHH2004 = 'Exp: SKHHH2004 Human FCU WM';
        expColor =[0,0,0];
        disp('Warning: Smeulders experimental data not used in RMSE calculation');
        figH = addSmeulders2004ActiveForceLength(figH,subplotFl, ...
                    labelSKHHH2004, expColor,...
                    muscleArchitecture, ...
                    flag_plotInNormalizedCoordinates);
    end


end

% Add the simulation data
if(flag_addSimulationData==1)  
    
    flag_activeData=0;
    flag_passiveData=0;
    if(contains(simulationFile,'active_force_length'))        
        flag_activeData=1;
    end
    if(contains(simulationFile,'passive_force_length'))
        flag_passiveData=1;
    end

    lineColor = lineColorA;    
    markerFaceColor = lineColorA;
    markerLineWidth = lineWidthModel;
    markerSize = 4;
    if(abs(lsdynaMuscleUniform.exc(end,1)-1) > 1e-3)
        markerFaceColor = [1,1,1];
        markerSize=4;
        markerLineWidth = lineWidthModel;        
    end


    lineAndMarkerSettings.lineType        = lineType;
    lineAndMarkerSettings.lineColor       = lineColor;
    lineAndMarkerSettings.lineWidth       = lineWidthModel;
    lineAndMarkerSettings.mark            = lsdynaMuscleUniform.mark;
    lineAndMarkerSettings.markerFaceColor = markerFaceColor;
    lineAndMarkerSettings.markerLineWidth = markerLineWidth;
    lineAndMarkerSettings.markerSize      = markerSize;

    if(flag_activeData)
        subplot('Position',subplotFl);

        fAN = lsdynaMuscleUniform.eloutAxialBeamForceNorm(indexA,1);
        fA  = fAN.*maximumIsometricForce;
        fBN = lsdynaMuscleUniform.eloutAxialBeamForceNorm(indexB,1);
        fB  = fBN.*maximumIsometricForce;

        if(strcmp(lsdynaMuscleUniform.name,'mat156')==1)
            act = lsdynaMuscleUniform.act(indexB,1);            
        else
            act = lsdynaMuscleUniform.act(indexB,1);
        end
       
        fpeAT =(fA);
        faeAT =(fB-fA);

        lp1 = lsdynaMuscleUniform.lp(indexB,1);
        ltN = lsdynaMuscleUniform.ltN(indexB,1);
        
        lp     = lp1;
        displayNameStr ='';
        handleVisibility='off';

        fpeN  = fAN;
        faeN  = (fBN-fAN);
        lceN  = lsdynaMuscleUniform.lceN(indexB,1);

        entryHeadings = {'act','lp','fae','lceN','fceN'};
        entryData = [act,lp,faeAT];

        %Start a new file
        if(contains(simulationFile,fileNameMaxActStart))
            fid=fopen([simulationFolder,filesep,'record.csv'],'w');
            fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',act,lp,faeAT,lceN,faeN);
            fclose(fid);
        elseif(contains(simulationFile,fileNameMaxActLast))
            fid=fopen([simulationFolder,filesep,'record.csv'],'a');
            fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',act,lp,faeAT,lceN,faeN);
            fclose(fid);
            dataForceLength = csvread([simulationFolder,filesep,'record.csv']);

            displayNameStr = [lsdynaMuscleUniform.nameLabel,...
                   sprintf('(%1.1f)',dataForceLength(1,1))];            
                     
            figH = addSimulationActiveForceLength(...
                figH,subplotFl,dataForceLength,displayNameStr,...
                muscleArchitecture,...
                lineAndMarkerSettings,...
                plotSettings,...
                flag_plotInNormalizedCoordinates);

                xDelta=abs(diff(plotSettings(idx).xLim))*0.05;
                yDelta=abs(diff(plotSettings(idx).yLim))*0.05;               
                xText = max(plotSettings(idx).xLim)-5*xDelta;
         
                idxX = 2;
                idxY = 3;
                if(flag_plotInNormalizedCoordinates==1)
                    idxX = 4;
                    idxY = 5;
                end
                 %Evaluate the RMSE
                 dataExp=readmatrix(fileExpDataActiveForceLength,'Delimiter',',');
                 errVec = zeros(size(dataExp,1),1);
                 for indexData=1:1:size(dataExp,1)
                    lceNExp = dataExp(indexData,1);
                    fceNExp = dataExp(indexData,2);
                    errVec(indexData,1) = ...
                                     interp1(dataForceLength(:,idxX),...
                                     dataForceLength(:,idxY),...
                                     lceNExp,...
                                     'linear',...
                                     'extrap')-fceNExp;
                    
                 end
    
                 errRmse = sqrt(mean(errVec.^2));                
                
                text(xText,...
                     1,...
                     sprintf('Properties\n%s: %1.0f mm\n%s: %1.0f mm\n%s: %1.1f N',...
                     '$$\ell^{M}_o$$',optimalFiberLength*m2mm,...
                     '$$\ell^{T}_s$$',tendonSlackLength*m2mm,...
                     '$$f^{M}_o$$',maximumIsometricForce),...
                     'HorizontalAlignment','left',...
                     'VerticalAlignment','top',...
                     'FontSize',6);
                hold on; 
             
                text(xTextRmse,yTextRmse,...
                    sprintf('RMSE\n%1.2e%s',errRmse,'$$f^{M}_o$$'),...
                    'HorizontalAlignment','left',...
                     'VerticalAlignment','top',...
                     'FontSize',6);
                hold on;

            if(flag_solveForHerzogLeonard1997Params==1)

            end


        elseif(contains(simulationFile,fileNameSubMaxActStart))
            fid=fopen([simulationFolder,filesep,'record.csv'],'w');
            fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',act,lp,faeAT,lceN,faeN);
            fclose(fid);
        elseif(contains(simulationFile,fileNameSubMaxActLast))
            fid=fopen([simulationFolder,filesep,'record.csv'],'a');
            fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',act,lp,faeAT,lceN,faeN);
            fclose(fid);
            dataForceLength = csvread([simulationFolder,filesep,'record.csv']); 


            displayNameStr = [lsdynaMuscleUniform.nameLabel,...
                   sprintf('(%1.1f)',dataForceLength(1,1))];   

            figH = addSimulationActiveForceLength(...
                figH,subplotFl,dataForceLength,displayNameStr,...
                muscleArchitecture,...
                lineAndMarkerSettings,...
                plotSettings,...
                flag_plotInNormalizedCoordinates);
            

            lgdH = legend('Location','NorthWest');
            lgdH.FontSize=fontSizeLegend;
            legend box off;
         
            %%
            % Add experimental data illustrating the shift of the peak
            % of the force-length relation
            %%
            idxX = 2;
            idxY = 3;
            if(flag_plotInNormalizedCoordinates==1)
                idxX = 4;
                idxY = 5;
            end            
            [valMax,idxMax] = max(dataForceLength(:,idxY));
            peakLceNFalN = [dataForceLength(idxMax,idxX),dataForceLength(idxMax,idxY)];            
            
            labelHA2014    = 'Exp: HA2014 Frog PL WM (sub max)';
            expColor=[0,0,0];
            figH = addHoltAzizi2014ActiveForceLengthShift(...
                    figH,subplotFl,peakLceNFalN,labelHA2014,expColor,...
                    muscleArchitecture,...
                    flag_plotInNormalizedCoordinates);
            
        else
            fid=fopen([simulationFolder,filesep,'record.csv'],'a');
            fprintf(fid,'%1.3e,%1.3e,%1.3e,%1.3e,%1.3e\n',act,lp,faeAT,lceN,faeN);
            fclose(fid);
        end


        box off;    
        idx=2;
        xlim(plotSettings(idx).xLim);
        ylim(plotSettings(idx).yLim);
        xticks(plotSettings(idx).xTicks);
        yticks(plotSettings(idx).yTicks); 
    
        if(flag_plotInNormalizedCoordinates==1)
            xlabel('Norm. Length ($$\ell/\ell^{M}_o$$)');
            ylabel('Norm. Force ($$f/f^{M}_o$$)');   
        else
            xlabel('Path Length (mm)');
            ylabel('Tendon Force (N)');   
        end
        title('B. Active force-length relations',...
              'HorizontalAlignment','right');        
    end

    if(flag_passiveData)

        figH = addSimulationPassiveForceLength(...
            figH,subplotFpe,lsdynaMuscleUniform,...
            muscleArchitecture,...
            lineAndMarkerSettings,...
            plotSettings,...
            flag_plotInNormalizedCoordinates);
    
        lgdH=legend('Location','NorthWest');
        lgdH.FontSize=fontSizeLegend;
        legend box off;

        assert(flag_plotInNormalizedCoordinates==1,...
            'Error: RMSE calculations only implemeneted for normalized data');

        idxA = 1;
        if(length(lsdynaMuscleUniform.eloutAxialBeamForceNorm) ...
                > length(lsdynaMuscleUniform.lceATN))
            idxA=2;
        end        
        lengthPlot = lsdynaMuscleUniform.lceN;
        forcePlot  = lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxA:end,1);
        stiffnessPlot = calcCentralDifferenceDataSeries(lengthPlot,forcePlot);
        indexPlot = find(forcePlot > 0.05);

         %Evaluate the RMSE
         dataExp=readmatrix(fileExpDataPassiveForceLength,'Delimiter',',');
         errVec = zeros(size(dataExp,1),1).*nan;

         if(flag_passiveStiffnessRmse==1)
             count=1;
             for indexTrial=1:1:max(dataExp(:,4))
                indexData =find(dataExp(:,4)==indexTrial);
    
                lceNExp = dataExp(indexData,1);
                fceNExp = dataExp(indexData,2);
                stiffnessExp = calcCentralDifferenceDataSeries(lceNExp,fceNExp);
                
                for indexData=1:1:length(lceNExp)
                    if(fceNExp(indexData,1)>0.025)
                        errVec(count,1) = ...
                                 interp1(forcePlot(indexPlot,1),...
                                         stiffnessPlot(indexPlot,1),...
                                         fceNExp(indexData,1),...
                                         'linear',...
                                         'extrap')-stiffnessExp(indexData,1);
                        count=count+1;
                    end
                end
                
             end
             idxEntry = ~isnan(errVec);
             errRmse = sqrt(mean(errVec(idxEntry).^2));  
    
             text(xTextRmse,yTextRmse,...
                sprintf('RMSE\n%1.2e%s',errRmse,'$$f^{M}_o/l^M_o$$'),...
                'HorizontalAlignment','left',...
                 'VerticalAlignment','top',...
                 'FontSize',6);
            hold on;
         else
             for indexData=1:1:size(dataExp,1)
                lceNExp = dataExp(indexData,1);
                fceNExp = dataExp(indexData,2);                 
                errVec(indexData,1) = ...
                     interp1(lengthPlot(:,1),...
                             forcePlot(:,1),...
                             lceNExp,...
                             'linear',...
                             'extrap')-fceNExp;
             end
             idxEntry = ~isnan(errVec);
             errRmse = sqrt(mean(errVec(idxEntry).^2));  
    
             text(xTextRmse,yTextRmse,...
                sprintf('RMSE\n%1.2e%s',errRmse,'$$f^{M}_o$$'),...
                'HorizontalAlignment','left',...
                 'VerticalAlignment','top',...
                 'FontSize',6);
             hold on;

         end

    end    
   
    if(contains(simulationFile,fileNameMaxActOpt) ...
        || contains(simulationFile,fileNameSubMaxActOpt))
  
       
        figH = addSimulationActiveForceTimeSeries(...
                    figH,subplotFlTime,lsdynaMuscleUniform,...
                    indexA,indexB,...
                    timeA,timeB,timeEnd,...
                    muscleArchitecture,...
                    lineType,lineWidthModel,lineColor,...
                    markerSize,markerLineWidth,markerFaceColor,...
                    plotSettings,...
                    flag_plotInNormalizedCoordinates);        
    end

end

pause(0.1);
    

end

