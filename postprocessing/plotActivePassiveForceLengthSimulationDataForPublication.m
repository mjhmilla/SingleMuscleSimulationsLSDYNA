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

trialFolder=pwd;
cd ..;
simulationFolder=pwd;
cd(trialFolder);

indexRow = indexModel;
scaleF=1000;

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
plotSettings(idx).xLim  = round([55,240],3,'significant');
plotSettings(idx).yLim  = round([0,1.201].*maximumIsometricForce.*scaleF,3,'significant');
if(flag_viva)
    plotSettings(idx).xTicks = ...
        round([60,optimalFiberLength,240],3,'significant');
else
    plotSettings(idx).xTicks = ...
        round([60,optimalFiberLength,optimalFiberLength+tendonSlackLength,240],3,'significant');
end
plotSettings(idx).yTicks = round([0,1].*maximumIsometricForce.*scaleF,3,'significant');

idx=2;
plotSettings(idx).xLim  = round([55,240],3,'significant');
plotSettings(idx).yLim  = round([0,1.201].*maximumIsometricForce.*scaleF,3,'significant');
if(flag_viva)
    plotSettings(idx).xTicks = ...
        round([60,optimalFiberLength,240],3,'significant');
else
    plotSettings(idx).xTicks = ...
        round([60,optimalFiberLength,(optimalFiberLength+tendonSlackLength),240],3,'significant');
end
plotSettings(idx).yTicks = round([0,1].*maximumIsometricForce.*scaleF,3,'significant');

idx=3;
plotSettings(idx).xLim  = round([(timeStart-timeEpsilon),(timeEnd+timeEpsilon)],3,'significant');
plotSettings(idx).yLim  = round([0,1.101].*maximumIsometricForce.*scaleF,3,'significant');
plotSettings(idx).xTicks = round([timeStart,timeA,timeMid,timeB,timeEnd],3,'significant');
plotSettings(idx).yTicks = round([0,1].*maximumIsometricForce.*scaleF,3,'significant');


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

% Add the reference data
if(flag_addReferenceData==1)
    %Load the reference data
    %dataFiles = {'dataHerzogLeonard2002Figure7A.dat',...
    %             'dataHerzogLeonard2002Figure7B.dat',...
    %             'dataHerzogLeonard2002Figure7C.dat'};
    %dataLabels = {'3mm/s','9mm/s','27mm/s'};

    %dataFig7A = importdata([referenceDataFolder,'/','dataHerzogLeonard2002Figure7A.csv']);
    %dataFig7B = importdata([referenceDataFolder,'/','dataHerzogLeonard2002Figure7B.csv']);
    %dataFig7C = importdata([referenceDataFolder,'/','dataHerzogLeonard2002Figure7C.csv']);  

    flag_addReferenceData=0;
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



    if(flag_activeData)
        subplot('Position',reshape(subPlotLayout(indexRow,2,:),1,4));

        fAN = lsdynaMuscleUniform.eloutAxialBeamForceNorm(indexA,1);
        fA  = fAN.*maximumIsometricForce.*scaleF;
        fBN = lsdynaMuscleUniform.eloutAxialBeamForceNorm(indexB,1);
        fB  = fBN.*maximumIsometricForce.*scaleF;

        act = lsdynaMuscleUniform.act(indexB,1);

        fpeAT =(fA);
        faeAT =(fB-fA);

        lp1 = lsdynaMuscleUniform.lp(indexB,1);
        ltN = lsdynaMuscleUniform.ltN(indexB,1);
        
        lp     = lp1;
        displayNameStr ='';
        handleVisibility='off';

        if(contains(lsdynaMuscleUniform.nameLabel,'EHTMM'))
            displayNameStr=[lsdynaMuscleUniform.nameLabel,...
                  sprintf('(%1.1f)',lsdynaMuscleUniform.act(end,1))];
            
        else
            displayNameStr=[lsdynaMuscleUniform.nameLabel,...
                  sprintf('(%1.1f)',lsdynaMuscleUniform.act(end,1))];
            
        end



        plot(lp,faeAT,...
             lsdynaMuscleUniform.mark,...
            'Color',lineColor,...
            'LineWidth',markerLineWidth,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize);
        hold on;

        entryHeadings = {'act','lN','fN'};
        entryData = [act,lp,faeAT];

        %Start a new file
        if(contains(simulationFile,fileNameMaxActStart))
            fid=fopen([simulationFolder,filesep,'record.csv'],'w');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lp,faeAT);
            fclose(fid);
        elseif(contains(simulationFile,fileNameMaxActLast))
            fid=fopen([simulationFolder,filesep,'record.csv'],'a');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lp,faeAT);
            fclose(fid);
            dataMax = csvread([simulationFolder,filesep,'record.csv']);
            plot(dataMax(:,2),dataMax(:,3),...
                 lineType,...
                'Color',lineColor,...
                'LineWidth',lineWidthModel,...
                'DisplayName',displayNameStr,...
                'HandleVisibility','on',...
                'MarkerFaceColor',markerFaceColor,...
                'MarkerSize',markerSize);
            hold on;

            [valMax,idxMax] = max(dataMax(:,3));

            idx=2;
            xDelta=abs(diff(plotSettings(idx).xLim))*0.05;
            yDelta=abs(diff(plotSettings(idx).yLim))*0.05;
            xText = min(plotSettings(idx).xLim)+xDelta;

            text(xText,max(dataMax(:,3)),...
                 sprintf('%s: %1.0f mm\n%s: %1.1f N',...
                 '$$\ell^{*}$$',dataMax(idxMax,2),...
                 '$$f^{*}$$',dataMax(idxMax,3)),...
                 'HorizontalAlignment','left',...
                 'VerticalAlignment','top',...
                 'FontSize',6);
            hold on;


            plot([xText,dataMax(idxMax,2)],...
                 [1,1].*dataMax(idxMax,3),...
                 '-',...
                'Color',[0,0,0],...
                'LineWidth',0.5,...
                'DisplayName','',...
                'HandleVisibility','off');
            hold on;

            xText = max(plotSettings(idx).xLim)-xDelta*4;

            text(xText,...
                 min(plotSettings(idx).yLim)+8*yDelta,...
                 sprintf('Properties\n%s: %1.0f mm\n%s: %1.0f mm\n%s: %1.1f N',...
                 '$$\ell^{M}_o$$',optimalFiberLength,...
                 '$$f^{T}_s$$',tendonSlackLength,...
                 '$$f^{M}_o$$',maximumIsometricForce*scaleF),...
                 'HorizontalAlignment','left',...
                 'VerticalAlignment','bottom',...
                 'FontSize',6);
            hold on;

        elseif(contains(simulationFile,fileNameSubMaxActStart))
            fid=fopen([simulationFolder,filesep,'record.csv'],'w');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lp,faeAT);
            fclose(fid);
        elseif(contains(simulationFile,fileNameSubMaxActLast))
            fid=fopen([simulationFolder,filesep,'record.csv'],'a');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lp,faeAT);
            fclose(fid);
            dataMax = csvread([simulationFolder,filesep,'record.csv']);            
            plot(dataMax(:,2),dataMax(:,3),...
                 lineType,...
                'Color',lineColor,...
                'LineWidth',lineWidthModel,...
                'DisplayName',displayNameStr,...
                'HandleVisibility','on',...
                'MarkerFaceColor',markerFaceColor,...
                'MarkerSize',markerSize);
            hold on;

            legend('Location','NorthEast');
            legend box off;
         
            [valMax,idxMax] = max(dataMax(:,3));
            
            idx=2;
            xDelta=abs(diff(plotSettings(idx).xLim))*0.05;
            yDelta=abs(diff(plotSettings(idx).yLim))*0.05;
            xText = min(plotSettings(idx).xLim)+xDelta;
            

            text(xText,max(dataMax(:,3)),...
                 sprintf('%s: %1.0f mm\n%s: %1.1f N',...                 
                 '$$\ell^{+}$$',dataMax(idxMax,2),...
                 '$$f^{+}$$',dataMax(idxMax,3)),...
                 'HorizontalAlignment','left',...
                 'VerticalAlignment','top',...
                 'FontSize',6);
            hold on;
            
            plot([xText,dataMax(idxMax,2)],...
                 [1,1].*dataMax(idxMax,3),...
                 '-',...
                'Color',[0,0,0],...
                'LineWidth',0.5,...
                'DisplayName','',...
                'HandleVisibility','off');
            hold on;
        else
            fid=fopen([simulationFolder,filesep,'record.csv'],'a');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lp,faeAT);
            fclose(fid);
        end

        if(contains(simulationFile,fileNameMaxActOpt))
            text(lp,faeAT,...
                 sprintf('*%1.1f',lsdynaMuscleUniform.act(indexB,1)),...
                 'Color',lineColor,...
                 'HorizontalAlignment','center',...
                 'VerticalAlignment','bottom');           
            hold on;
        end
        if(contains(simulationFile,fileNameSubMaxActOpt))
            text(lp,faeAT,...
                 sprintf('+%1.1f',lsdynaMuscleUniform.act(indexB,1)),...
                 'Color',lineColor,...
                 'HorizontalAlignment','center',...
                 'VerticalAlignment','bottom');           
            hold on;
        end
        box off;    
        idx=2;
        xlim(plotSettings(idx).xLim);
        ylim(plotSettings(idx).yLim);
        xticks(plotSettings(idx).xTicks);
        yticks(plotSettings(idx).yTicks); 
    
        xlabel('Path Length (mm)');
        ylabel('Tendon Force (N)');   
        title('B. Active force-length relations',...
              'HorizontalAlignment','right');        
    end

    if(flag_passiveData)

        subplot('Position',reshape(subPlotLayout(indexRow,1,:),1,4));
        

        %if(contains(simulationFile,'passive_force_length'))
        %    displayNameStr=[lsdynaMuscleUniform.nameLabel,' $$\tilde{f}^{PE} \cos \alpha$$'];
        %end
        displayNameStr=lsdynaMuscleUniform.nameLabel;

        idxA = 1;
        if(length(lsdynaMuscleUniform.eloutAxialBeamForceNorm) ...
                > length(lsdynaMuscleUniform.lceATN))
            idxA=2;
        end

        plot(lsdynaMuscleUniform.lp,...
             lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxA:end,1).*maximumIsometricForce.*scaleF,...
             '-',...
            'Color',lineColor,...
            'LineWidth',lineWidthModel,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','on');
        hold on;
        
        fpeN = lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxA:end,1).*maximumIsometricForce.*scaleF;

        fpeMin = 0.01*maximumIsometricForce*scaleF;
        fpeIso = maximumIsometricForce*scaleF;

        fpeMax = max(fpeN);
        [idxValid] = find(fpeN >= fpeMin);
        idxMin = min(idxValid)-1;

        while(fpeN(idxMin,1) > fpeMin*0.5 && idxMin > 1)
            idxMin=idxMin-1;
        end        
        lp0 = lsdynaMuscleUniform.lp(idxMin,1);
        fp0 = fpeN(idxMin,1);

        lp1 = interp1(fpeN(idxValid,:), ...
                      lsdynaMuscleUniform.lp(idxValid,:), fpeIso);
        
        dfdl = calcCentralDifferenceDataSeries(...
                 lsdynaMuscleUniform.lp(idxValid,:),...
                 fpeN(idxValid,:));
        dfdl1 = interp1(lsdynaMuscleUniform.lp(idxValid,:),...
                        dfdl,lp1);
        idx=1;
        lpLeft= min(plotSettings(idx).xLim);

        xDelta=abs(diff(plotSettings(idx).xLim))*0.05;
        yDelta=abs(diff(plotSettings(idx).yLim))*0.05;

        plot(lp0,fp0,...
             lsdynaMuscleUniform.mark,...
             'Color',lineColor,...
             'MarkerFaceColor',lineColor,...
             'LineWidth',lineWidthModel,...
             'MarkerSize',markerSize,...
             'HandleVisibility','off');
        hold on;
        text(lp0,fp0+yDelta,...
              sprintf('%1.0f mm, %1.1f N', lp0, fp0),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','bottom',...
             'FontSize',6);
        hold on;

        plot(lp1,fpeIso,...
             lsdynaMuscleUniform.mark,...
             'Color',lineColor,...
             'MarkerFaceColor',lineColor,...
             'LineWidth',lineWidthModel,...
             'MarkerSize',markerSize,...
             'HandleVisibility','off');
        hold on;
        text(lp1-6*xDelta,fpeIso,...
              sprintf('%1.0f mm, %1.1f N\n %1.1f N/mm', lp1, fpeIso, dfdl1),...
             'HorizontalAlignment','left',...
             'VerticalAlignment','top',...
             'FontSize',6);
        hold on;


        box off;    
        idx=1;
        xlim(plotSettings(idx).xLim);
        ylim(plotSettings(idx).yLim);
        xticks(plotSettings(idx).xTicks);
        yticks(plotSettings(idx).yTicks); 
    
        xlabel('Path Length (mm)');
        ylabel('Tendon Force (N)');   
        title('A. Passive force-length relations',...
              'HorizontalAlignment','right');
    
        legend('Location','NorthWest');
        legend box off;
    end    


    

    if(contains(simulationFile,fileNameMaxActOpt) ...
        || contains(simulationFile,fileNameSubMaxActOpt))
        subplot('Position',reshape(subPlotLayout(indexRow,3,:),1,4));        
        %subplot('Position',reshape(subPlotLayout(1,2,:),1,4));
        


        plot(   lsdynaMuscleUniform.eloutTime(:,1),...
                lsdynaMuscleUniform.eloutAxialBeamForceNorm(:,1).*maximumIsometricForce.*scaleF,...
                lineType,...
                'Color',lineColor,...
                'LineWidth',lineWidthModel,...
                'DisplayName',[lsdynaMuscleUniform.nameLabel,sprintf('(%1.1f)',lsdynaMuscleUniform.act(end,1))],...
                'HandleVisibility','on');
        hold on;

        fAN = lsdynaMuscleUniform.eloutAxialBeamForceNorm(indexA,1);
        fA  = fAN.*maximumIsometricForce.*scaleF;
        fBN = lsdynaMuscleUniform.eloutAxialBeamForceNorm(indexB,1);
        fB  = fBN.*maximumIsometricForce.*scaleF;
        
        plot(timeA,fA,...
             lsdynaMuscleUniform.mark,...
             'Color',lineColor,...
             'MarkerFaceColor',lineColor,...
             'LineWidth',lineWidthModel,...
             'MarkerSize',markerSize,...
             'HandleVisibility','off');
        hold on;
        text(timeA,fA,'A',...
             'HorizontalAlignment','center',...
             'VerticalAlignment','bottom',...
             'Color',lineColor);
        hold on;

        plot(timeB,fB,...
             lsdynaMuscleUniform.mark,...
             'Color',lineColor,...
             'MarkerFaceColor',lineColor,...             
             'LineWidth',lineWidthModel,...
             'MarkerSize',markerSize,...
             'HandleVisibility','off');
        hold on;

        text(timeB,fB,'B',...
             'HorizontalAlignment','center',...
             'VerticalAlignment','bottom',...
             'Color',lineColor);
        hold on;
 
        if(timeEnd > 10)
            xlabel('Time (ms)');            
        else
            xlabel('Time (s)');
        end
        ylabel('Tendon Force (N)');  
        title('C. Example time series data',...
              'HorizontalAlignment','right');        

        box off;
    
        idx=3;
        xlim(plotSettings(idx).xLim);
        ylim(plotSettings(idx).yLim);
        xticks(plotSettings(idx).xTicks);
        yticks(plotSettings(idx).yTicks);      

        legend('Location','SouthWest');
        legend box off;

        here=1;
    end

end

pause(0.1);
    

end

