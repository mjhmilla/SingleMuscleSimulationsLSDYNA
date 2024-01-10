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
fileNameMaxActOpt       = 'active_force_length_06';
fileNameSubMaxActOpt    = 'active_force_length_16';



plotSettings(3) = struct('yLim',[],'xLim',[],'yTicks',[],'xTicks',[]);

timeEnd   = lsdynaMuscleUniform.time(end,1);
timeStart = lsdynaMuscleUniform.time(1,1);
timeEpsilon = (timeEnd-timeStart)/1000;
timeDelta   = (timeEnd-timeStart)/100;

timeA = timeStart + (timeEnd-timeStart)*(0.25);
timeMid=timeStart + (timeEnd-timeStart)*(0.5);
timeB = timeStart + (timeEnd-timeStart)*(0.75);

indexA = find(lsdynaMuscleUniform.time > timeA,1);
indexB = find(lsdynaMuscleUniform.time > timeB,1);
timeA = lsdynaMuscleUniform.time(indexA,1);
timeB = lsdynaMuscleUniform.time(indexB,1);

idx=1;
plotSettings(idx).xLim  = [0,2.0];
plotSettings(idx).yLim  = [0,1.201];
plotSettings(idx).xTicks = [0.2:0.2:1.8];
plotSettings(idx).yTicks = [0,1];

idx=2;
plotSettings(idx).xLim  = [0,2.0];
plotSettings(idx).yLim  = [0,1.201];
plotSettings(idx).xTicks = [0.2:0.2:1.8];
plotSettings(idx).yTicks = [0,1];

idx=3;
plotSettings(idx).xLim  = [(timeStart-timeEpsilon),(timeEnd+timeEpsilon)];
plotSettings(idx).yLim  = [0,1.101];
plotSettings(idx).xTicks = round([timeStart,timeA,timeMid,timeB,timeEnd],2,'significant');
plotSettings(idx).yTicks = [0,1,1.1];


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

        fAN = lsdynaMuscleUniform.fseN(indexA,1);

        fBN = lsdynaMuscleUniform.fseN(indexB,1);

        act = lsdynaMuscleUniform.act(indexB,1);
        lceN= lsdynaMuscleUniform.lceN(indexB,1);

        fpeATN =(fAN);
        faeATN =(fBN-fAN);

        lp1 = lsdynaMuscleUniform.lp(indexB,1);
        ltN = lsdynaMuscleUniform.ltN(indexB,1);
        
        lceATN = (lp1-ltN*tendonSlackLength)/optimalFiberLength;
        displayNameStr ='';
        handleVisibility='off';

        if(contains(lsdynaMuscleUniform.nameLabel,'EHTMM'))
            displayNameStr=[lsdynaMuscleUniform.nameLabel,...
                  sprintf('(%1.1f)',lsdynaMuscleUniform.act(end,1))];
            
        else
            displayNameStr=[lsdynaMuscleUniform.nameLabel,...
                  sprintf('(%1.1f)',lsdynaMuscleUniform.act(end,1))];
            
        end



        plot(lceATN,faeATN,...
             lsdynaMuscleUniform.mark,...
            'Color',lineColor,...
            'LineWidth',markerLineWidth,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize);
        hold on;

        entryHeadings = {'act','lN','fN'};
        entryData = [act,lceATN,faeATN];

        %Start a new file
        if(contains(simulationFile,fileNameMaxActStart))
            fid=fopen([simulationFolder,filesep,'record.csv'],'w');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lceATN,faeATN);
            fclose(fid);
        elseif(contains(simulationFile,fileNameMaxActLast))
            fid=fopen([simulationFolder,filesep,'record.csv'],'a');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lceATN,faeATN);
            fclose(fid);
            dataMax = csvread([simulationFolder,filesep,'record.csv']);
            plot(dataMax(:,2),dataMax(:,3),...
                 '-',...
                'Color',lineColor,...
                'LineWidth',lineWidthModel,...
                'DisplayName',displayNameStr,...
                'HandleVisibility','on',...
                'MarkerFaceColor',markerFaceColor,...
                'MarkerSize',markerSize);
            hold on;
        elseif(contains(simulationFile,fileNameSubMaxActStart))
            fid=fopen([simulationFolder,filesep,'record.csv'],'w');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lceATN,faeATN);
            fclose(fid);
        elseif(contains(simulationFile,fileNameSubMaxActLast))
            fid=fopen([simulationFolder,filesep,'record.csv'],'a');
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lceATN,faeATN);
            fclose(fid);
            dataMax = csvread([simulationFolder,filesep,'record.csv']);
            plot(dataMax(:,2),dataMax(:,3),...
                 '--',...
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
            fprintf(fid,'%1.3e,%1.3e,%1.3e\n',act,lceATN,faeATN);
            fclose(fid);
        end

        if(contains(simulationFile,fileNameMaxActOpt) ...
                || contains(simulationFile,fileNameSubMaxActOpt))
            text(lceATN,faeATN,...
                 sprintf('*%1.1f',lsdynaMuscleUniform.act(end,1)),...
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

        plot(lsdynaMuscleUniform.lceATN,...
             lsdynaMuscleUniform.fseN,'-',...
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


    

    if(contains(simulationFile,fileNameMaxActOpt))
        subplot('Position',reshape(subPlotLayout(indexModel,3,:),1,4));        
        %subplot('Position',reshape(subPlotLayout(1,2,:),1,4));
        
        plot(   lsdynaMuscleUniform.time(:,1),...
                lsdynaMuscleUniform.fseN(:,1),...
                '-',...
                'Color',lineColor,...
                'LineWidth',lineWidthModel,...
                'DisplayName',lsdynaMuscleUniform.nameLabel,...
                'HandleVisibility','on');
        hold on;

        fAN = lsdynaMuscleUniform.fseN(indexA,1);
        fBN = lsdynaMuscleUniform.fseN(indexB,1);

        plot(timeA,fAN,...
             lsdynaMuscleUniform.mark,...
             'Color',lineColor,...
             'MarkerFaceColor',lineColor,...
             'LineWidth',lineWidthModel,...
             'MarkerSize',markerSize,...
             'HandleVisibility','off');
        hold on;
        text(timeA,fAN,'A',...
             'HorizontalAlignment','center',...
             'VerticalAlignment','bottom',...
             'Color',lineColor);
        hold on;

        plot(timeB,fBN,...
             lsdynaMuscleUniform.mark,...
             'Color',lineColor,...
             'MarkerFaceColor',lineColor,...             
             'LineWidth',lineWidthModel,...
             'MarkerSize',markerSize,...
             'HandleVisibility','off');
        hold on;

        text(timeB,fBN,'B',...
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

