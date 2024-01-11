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
plotSettings(idx).xLim  = round([0,2.0].*optimalFiberLength,2,'significant');
plotSettings(idx).yLim  = round([0,1.201].*maximumIsometricForce.*scaleF,2,'significant');
plotSettings(idx).xTicks = round([0.2:0.2:1.8].*optimalFiberLength,2,'significant');
plotSettings(idx).yTicks = round([0,1].*maximumIsometricForce.*scaleF,2,'significant');

idx=2;
plotSettings(idx).xLim  = round([0,2.0].*optimalFiberLength,2,'significant');
plotSettings(idx).yLim  = round([0,1.201].*maximumIsometricForce.*scaleF,2,'significant');
plotSettings(idx).xTicks = round([0.2:0.2:1.8].*optimalFiberLength,2,'significant');
plotSettings(idx).yTicks = round([0,1].*maximumIsometricForce.*scaleF,2,'significant');

idx=3;
plotSettings(idx).xLim  = round([(timeStart-timeEpsilon),(timeEnd+timeEpsilon)],2,'significant');
plotSettings(idx).yLim  = round([0,1.101].*maximumIsometricForce.*scaleF,2,'significant');
plotSettings(idx).xTicks = round([timeStart,timeA,timeMid,timeB,timeEnd],2,'significant');
plotSettings(idx).yTicks = round([0,1,1.1].*maximumIsometricForce.*scaleF,2,'significant');


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
        subplot('Position',reshape(subPlotLayout(indexModel,2,:),1,4));

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
        else
            fid=fopen([simulationFolder,filesep,'record.csv'],'a');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lp,faeAT);
            fclose(fid);
        end

        if(contains(simulationFile,fileNameMaxActOpt) ...
                || contains(simulationFile,fileNameSubMaxActOpt))
            text(lp,faeAT,...
                 sprintf('*%1.1f',lsdynaMuscleUniform.act(indexB,1)),...
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
    
        xlabel('Norm. Length ($$\ell^{M} \cos \alpha / \ell^{M}_o$$)');
        ylabel('Norm. Force ($$f^{M} \cos \alpha / f^{M}_o$$)');   
        title('B. Active force-length relations',...
              'HorizontalAlignment','right');        
    end

    if(flag_passiveData)

        subplot('Position',reshape(subPlotLayout(indexModel,1,:),1,4));
        

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
   
        box off;    
        idx=1;
        xlim(plotSettings(idx).xLim);
        ylim(plotSettings(idx).yLim);
        xticks(plotSettings(idx).xTicks);
        yticks(plotSettings(idx).yTicks); 
    
        xlabel('Norm. Length ($$\ell^{M} \cos \alpha / \ell^{M}_o$$)');
        ylabel('Norm. Force ($$f^{M} \cos \alpha / f^{M}_o$$)');   
        title('A. Passive force-length relations',...
              'HorizontalAlignment','right');
    
        legend('Location','NorthWest');
        legend box off;
    end    


    

    if(contains(simulationFile,fileNameMaxActOpt) ...
        || contains(simulationFile,fileNameSubMaxActOpt))
        subplot('Position',reshape(subPlotLayout(indexModel,3,:),1,4));        
        %subplot('Position',reshape(subPlotLayout(1,2,:),1,4));
        


        plot(   lsdynaMuscleUniform.eloutTime(:,1),...
                lsdynaMuscleUniform.eloutAxialBeamForceNorm(:,1).*maximumIsometricForce.*scaleF,...
                lineType,...
                'Color',lineColor,...
                'LineWidth',lineWidthModel,...
                'DisplayName',lsdynaMuscleUniform.nameLabel,...
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
        ylabel('Norm. Force ($$f^{M} \cos \alpha /f^{M}_o$$)');  
        title('C. Example time series data',...
              'HorizontalAlignment','right');        

        box off;
    
        idx=3;
        xlim(plotSettings(idx).xLim);
        ylim(plotSettings(idx).yLim);
        xticks(plotSettings(idx).xTicks);
        yticks(plotSettings(idx).yTicks);      

        legend('Location','NorthWest');
        legend box off;

        here=1;
    end

end

pause(0.1);
    

end

