function figH = plotFrequencyResponsePublication(...
                              figH,...
                              simConfig,...
                              inputFunctions,...                      
                              frequencyAnalysisSimulationData,...
                              nominalForce,...
                              coherenceSqThreshold,...
                              indexColumn,...
                              subPlotLayout,...
                              referenceDataFolder,... 
                              flag_addReferenceData,...
                              flag_addSimulationData,...
                              lineColorA, lineColorB, ...
                              referenceColorA, referenceColorB,...
                              modelName)
                      

figure(figH);


idxForce        = 1;
idxGain         = 2;
idxPhase        = 3;
idxCoherence    = 4;
legendFontSize=6;

samplePoints    = inputFunctions.samples;  
paddingPoints   = inputFunctions.padding;
sampleFrequency = inputFunctions.sampleFrequency;

timeDelta              = 0.3;
numberOfSamplesInChunk = timeDelta*sampleFrequency;

timeChunkStart      = 0.4;
timeMovementStart   = 0.5;
timeChunkEnd        = timeChunkStart+timeDelta;

idxChunkStart = find(inputFunctions.time<timeChunkStart,1,'last');
idxChunkEnd     = find(inputFunctions.time>timeChunkEnd,1,'first');
idxChunk        = [idxChunkStart:1:idxChunkEnd];


simulationSpringDamperColor =lineColorB;
simulationModelColor        =lineColorA;

epsRoot=sqrt(eps);
yLimSettings=[-0.05,13.0+epsRoot;...
              0,10.0+epsRoot;...
              0,100.0+epsRoot;...
              0,1.0+epsRoot;...
              0,10.0+epsRoot;...
              0,0.10+epsRoot];


bandwidthColumn = 0;
titleLabels = {};
switch indexColumn
  case 1
      bandwidthColumn=15;
      titleLabels = {'A.','D.','G.','A.','B.'};
  case 2
      bandwidthColumn=15;
      titleLabels = {'B.','E.','H.','A.','B.'};          
  case 3
      bandwidthColumn=15;
      titleLabels = {'C.','F.','I.','A.','B.'};                    
  case 4
      bandwidthColumn=90;
      titleLabels = {'A.','D.','G.','A.','B.'}; 
      yLimSettings(3,:)=[0,150.1];
  case 5
      bandwidthColumn=90;          
      titleLabels = {'B.','E.','H.','A.','B.'}; 
      yLimSettings(3,:)=[0,150.1];      
  case 6
      bandwidthColumn=90;          
      titleLabels = {'C.','F.','I.','A.','B.'};                              
      yLimSettings(3,:)=[0,150.1];      
end
seriesName = sprintf('%1.1fmm %dHz',1.6,round(bandwidthColumn));


flag_addRMSE = 1;
if(flag_addRMSE ==1 && ...
   flag_addSimulationData==1 && ...
   flag_addReferenceData==0)

    fittingFilesGain      = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig3_gain.dat'];
    fittingFilesPhase     = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig3_phase.dat'];
    fittingFilesCoherence = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig3_coherence.dat'];

    dataKBR1994Fig3Gain = loadDigitizedData(fittingFilesGain,...
                            'Frequency (Hz)','Stiffness (N/mm)',...
                            {'1.6mm, 90Hz','1.6mm, 15Hz'},'');
    dataKBR1994Fig3Phase = loadDigitizedData(fittingFilesPhase,...
                             'Frequency (Hz)','Phase (deg)',...
                             {'1.6mm, 90Hz','1.6mm, 15Hz'},'');
    dataKBR1994Fig3Coherence = loadDigitizedData(fittingFilesCoherence,...
                              'Frequency (Hz)','Coherence$$^2$$',...
                              {'1.6mm, 90Hz','1.6mm, 15Hz'},'');    
end    

%%
% Plot the experimental data
%%
labelYNorm          = 0.2; %For the experimental data
labelYDeltaNorm     = 0.05;
labelXNorm          = 0.075+(20/90);  
labelLineXNorm      = [0.0,0.05]+(20/90);
labelXTimeNorm      = 0.075;  
labelLineXTimeNorm  = [0.0,0.05];

freqMax = 90;
m2mm=1000;
rad2Deg = (180/pi);

legendLineLength=0.5; %Makes the lines 25% the original length


if(flag_addSimulationData==1)

    assert(length(frequencyAnalysisSimulationData.vafTime)==1);    
    
    spring            = frequencyAnalysisSimulationData.stiffness(1,1)./1000;
    damper            = frequencyAnalysisSimulationData.damping(1,1)./1000;
    kLabel            = sprintf('%1.1f',spring);
    dLabel            = sprintf('%1.3f',damper);    
    kLabel            = ['  K: ',kLabel,'N/mm'];
    dLabel            = ['  $$\beta$$: ',dLabel,'N/(mm/s)'];
    vafTime           = frequencyAnalysisSimulationData.vafTime(1,1);
    vafLabel          = ['VAF ', sprintf('%d',(round(vafTime*100))),'\%'];
    amplitudeLabel    = sprintf('%1.1fmm',simConfig.amplitudeMM);
    frequencyLabel    = sprintf('%1.0fHz',simConfig.bandwidthHz);  
    
    simTextShort   = modelName;
    simTextAmpFreqVaf = [modelName,' (',vafLabel,')'];  
    %simTextVaf     = ['Sim: ',vafLabel];
    
    simTextKDAmpFreq = ['Spring-damper (best fit)'];
    kdLabel = sprintf('%s\n%s',kLabel,dLabel);

    subplot('Position', reshape(subPlotLayout(idxForce,indexColumn,:),1,4));       
                                             
        yo = nominalForce;
        
        plot( inputFunctions.time(idxChunk,1),...
            frequencyAnalysisSimulationData.forceKD(idxChunk,1)+yo,...
            '-','Color',simulationSpringDamperColor,...
            'LineWidth',0.75,...
            'DisplayName',simTextKDAmpFreq);
        hold on;
        
        plot(inputFunctions.time(idxChunk,1),...
                    frequencyAnalysisSimulationData.force(idxChunk,1),...
                    '-', 'Color',[1,1,1],...
                    'LineWidth',3,...
                    'HandleVisibility','off');
                
        plot(inputFunctions.time(idxChunk,1),...
                    frequencyAnalysisSimulationData.force(idxChunk,1),...
                    '-', 'Color',simulationModelColor,...
                    'LineWidth',1,...
                    'DisplayName',modelName);
        hold on;  
        
        set(gca,'color','none');
        ylim(yLimSettings(idxForce,:));        
        title([titleLabels{idxForce},' Time domain response (',seriesName,')']);
        
        box off;

        fmax   = max(frequencyAnalysisSimulationData.force(idxChunk,1));
        fmaxKD = max(frequencyAnalysisSimulationData.forceKD(idxChunk,1)+yo);
        yticks([0,round(nominalForce,2,'significant')]);
        set(gca,'color','none')
        ylim(yLimSettings(idxForce,:));

        t0 = min(inputFunctions.time(idxChunk,1));
        t1 = max(inputFunctions.time(idxChunk,1));
        dt = t1-t0;
        text(t0+dt*0.01,...
             4.0,...
             vafLabel,...
             'FontSize',8,...
             'Color',simulationModelColor,...
             'HorizontalAlignment','left',...
             'VerticalAlignment','top');
        hold on;
        plot([1;1].*(t0+dt*0.01), [4;5],'-', ...
            'Color',simulationModelColor,...
            'LineWidth',0.5,'HandleVisibility','off');
        hold on;
        plot(t0+dt*0.01, 4.8,'^', ...
            'MarkerSize',2,...
            'Color',simulationModelColor,...
            'MarkerFaceColor',simulationModelColor,...
            'HandleVisibility','off');
        hold on;

        [valMaxKD, idxMaxKD]=max(frequencyAnalysisSimulationData.forceKD(idxChunk,1)+yo);
        t1 = inputFunctions.time(idxChunk(1,idxMaxKD));
        f1 = valMaxKD;
        text(t0+dt*0.01,f1+0.01,kdLabel,...
            'FontSize',6,...
            'Color',simulationSpringDamperColor,...
            'HorizontalAlignment','left',...
            'VerticalAlignment','top');
        hold on;
        plot([t0;t1],[f1;f1],'-',...
            'Color',simulationSpringDamperColor,...
            'LineWidth',0.5,'HandleVisibility','off');
        hold on;
        plot(t1-dt*0.02, f1,'>', ...
            'MarkerSize',2,...
            'Color',simulationSpringDamperColor,...
            'MarkerFaceColor',simulationSpringDamperColor,...
            'HandleVisibility','off');
        hold on;        

        xlim([timeChunkStart-timeDelta*0.01,...
              timeChunkEnd+timeDelta*0.01]);

        lgdH=legend('Location','NorthEast');        
        lgdH.FontSize=legendFontSize;        
        legend boxoff;
        hold on;
  

    %%Gain
    subplot('Position', reshape(subPlotLayout(idxGain,indexColumn,:),1,4));       

        idxMin = frequencyAnalysisSimulationData.idxFreqRange(1,1);
        idxMax = frequencyAnalysisSimulationData.idxFreqRange(2,1);
        plot( frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
              frequencyAnalysisSimulationData.gain(idxMin:1:idxMax,1)./m2mm,...
              '-', 'Color', simulationModelColor,...
              'LineWidth',1,...
              'DisplayName',modelName);
        hold on;  

        plot(   frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
                frequencyAnalysisSimulationData.gainKD(idxMin:1:idxMax,1)./m2mm,...
                '-', 'Color', [1,1,1],...
                'LineWidth', 2,...
                'HandleVisibility','off');
        hold on;  

        plot(   frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
                frequencyAnalysisSimulationData.gainKD(idxMin:1:idxMax,1)./m2mm,...
                '-', 'Color', simulationSpringDamperColor,...
                'LineWidth', 0.75,...
                'DisplayName',simTextKDAmpFreq);
        hold on
        box off; 


        set(gca,'color','none');
        ylim(yLimSettings(idxGain,:));
        title([titleLabels{idxGain},' Frequency-response: gain (',seriesName,')']);

      
        if(flag_addRMSE == 1)
            simIdxMin = frequencyAnalysisSimulationData.idxFreqRange(1,1);
            simIdxMax = frequencyAnalysisSimulationData.idxFreqRange(2,1);
            simFreqRange = [simIdxMin:1:simIdxMax];

            f0=max(4,frequencyAnalysisSimulationData.freqHz(simIdxMin));
            f1=min(simConfig.bandwidthHz,frequencyAnalysisSimulationData.freqHz(simIdxMax)) ;
            npts=100;
            freqRmse = [f0:((f1-f0)/(npts-1)):f1]';
            indexExp = 0;
            switch simConfig.bandwidthHz
                case 15
                    indexExp=2;
                case 90
                    indexExp=1;
            end

            errVec = zeros(size(freqRmse));

            for i=1:1:npts
                expData = interp1(dataKBR1994Fig3Gain(indexExp).x,...
                                  dataKBR1994Fig3Gain(indexExp).y,...
                                  freqRmse(i,1),'linear');
                
                simData = interp1(frequencyAnalysisSimulationData.freqHz(simFreqRange,1),...
                                  frequencyAnalysisSimulationData.gain(simFreqRange,1),...
                                  freqRmse(i,1),'linear');
                simData = simData/m2mm;
                errVec(i,1)=simData-expData;                
            end            
            rmse = sqrt(mean(errVec.^2));
            
            text(simConfig.bandwidthHz,0,...
                 sprintf('RMSE %1.2f%s',rmse,'N/mm'),...
                'FontSize',8,...
                'Color',simulationModelColor,...
                'HorizontalAlignment','right',...
                'VerticalAlignment','bottom');
            hold on;
        end

        
        ylim(yLimSettings(idxGain,:));


  
    
    %%Phase
    subplot('Position', reshape(subPlotLayout(idxPhase,indexColumn,:),1,4));       

        idxMin = frequencyAnalysisSimulationData.idxFreqRange(1,1);
        idxMax = frequencyAnalysisSimulationData.idxFreqRange(2,1);
        plot( frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
              frequencyAnalysisSimulationData.phase(idxMin:1:idxMax,1).*rad2Deg,...
              '-', 'Color', simulationModelColor,...
              'LineWidth',1,...
              'DisplayName',modelName);
        hold on;  

        plot(   frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
                frequencyAnalysisSimulationData.phaseKD(idxMin:1:idxMax,1).*rad2Deg,...
                '-', 'Color', [1,1,1],...
                'LineWidth', 2,...
                'HandleVisibility','off');
        hold on;  

        plot(   frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
                frequencyAnalysisSimulationData.phaseKD(idxMin:1:idxMax,1).*rad2Deg,...
                '-', 'Color', simulationSpringDamperColor,...
                'LineWidth', 0.75,...
                'DisplayName',simTextKDAmpFreq);
        hold on
        box off;    
  
        set(gca,'color','none');
        ylim(yLimSettings(idxPhase,:));
        title([titleLabels{idxPhase},' Frequency-response: phase (',seriesName,')']);

        if(flag_addRMSE == 1)
            simIdxMin = frequencyAnalysisSimulationData.idxFreqRange(1,1);
            simIdxMax = frequencyAnalysisSimulationData.idxFreqRange(2,1);
            simFreqRange = [simIdxMin:1:simIdxMax];   

            f0=max(4,frequencyAnalysisSimulationData.freqHz(simIdxMin));
            f1=simConfig.bandwidthHz;
            npts=100;
            freqRmse = [f0:((f1-f0)/(npts-1)):f1]';
            indexExp = 0;
            switch simConfig.bandwidthHz
                case 15
                    indexExp=2;
                case 90
                    indexExp=1;
            end

            errVec = zeros(size(freqRmse));
         
            for i=1:1:npts
                expData = interp1(dataKBR1994Fig3Phase(indexExp).x,...
                                  dataKBR1994Fig3Phase(indexExp).y,...
                                  freqRmse(i,1),'linear','extrap');
                simData = interp1(frequencyAnalysisSimulationData.freqHz(simFreqRange,1),...
                                  frequencyAnalysisSimulationData.phase(simFreqRange,1).*rad2Deg,...
                                  freqRmse(i,1),'linear','extrap');
                errVec(i,1)=simData-expData;                
            end            
            rmse = sqrt(mean(errVec.^2));
            
            text(simConfig.bandwidthHz,0,sprintf('RMSE %1.2f%s',rmse,'$$^\circ$$'),...
                'FontSize',8,...
                'Color',simulationModelColor,...
                'HorizontalAlignment','right',...
                'VerticalAlignment','bottom');
            hold on;
        end

%         [lgdH, lgdIcons, lgdPlots, lgdTxt] = ...
%             legend('Location','SouthEast','FontSize',legendFontSize);
% 
%         legend boxoff;



    %% Coherence
    subplot('Position', reshape(subPlotLayout(idxCoherence,indexColumn,:),1,4));       


        idxMin = frequencyAnalysisSimulationData.idxFreqRange(1,1);
        idxMax = frequencyAnalysisSimulationData.idxFreqRange(2,1);

        plot( frequencyAnalysisSimulationData.coherenceSqFrequency(idxMin:idxMax,1),...
              frequencyAnalysisSimulationData.coherenceSq(idxMin:idxMax,1),...
              '-', 'Color', simulationModelColor,...
              'LineWidth',1,...
              'DisplayName',modelName);
        hold on;
        box off;        

        if(flag_addRMSE == 1)
            simIdxMin = frequencyAnalysisSimulationData.idxFreqRange(1,1);
            simIdxMax = frequencyAnalysisSimulationData.idxFreqRange(2,1);
            simFreqRange = [simIdxMin:1:simIdxMax];   

            f0=max(4,frequencyAnalysisSimulationData.freqHz(simIdxMin));
            f1=simConfig.bandwidthHz;
            npts=100;
            freqRmse = [f0:((f1-f0)/(npts-1)):f1]';
            indexExp = 0;
            switch simConfig.bandwidthHz
                case 15
                    indexExp=2;
                case 90
                    indexExp=1;
            end

            errVec = zeros(size(freqRmse));

            for i=1:1:npts
                expData = interp1(dataKBR1994Fig3Coherence(indexExp).x,...
                                  dataKBR1994Fig3Coherence(indexExp).y,...
                                  freqRmse(i,1),'linear','extrap');
                simData = interp1(frequencyAnalysisSimulationData.freqHz(simFreqRange,1),...
                                  frequencyAnalysisSimulationData.coherenceSq(simFreqRange,1),...
                                  freqRmse(i,1),'linear','extrap');
                errVec(i,1)=simData-expData;                
            end            
            rmse = sqrt(mean(errVec.^2));
            
            text(simConfig.bandwidthHz,0,sprintf('RMSE %1.2f',rmse),...
                'FontSize',8,...
                'Color',simulationModelColor,...
                'HorizontalAlignment','right',...
                'VerticalAlignment','bottom');
            hold on;

            if(f0 > 4)
                plot(frequencyAnalysisSimulationData.freqHz(simFreqRange(1),1),...
                     frequencyAnalysisSimulationData.coherenceSq(simFreqRange(1),1),...
                     'o',...
                     'MarkerSize',2,...
                     'MarkerFaceColor',simulationModelColor,...
                     'Color',simulationModelColor,...
                     'HandleVisibility','off');
                hold on;
                text(frequencyAnalysisSimulationData.freqHz(simFreqRange(1),1),...
                     frequencyAnalysisSimulationData.coherenceSq(simFreqRange(1),1),...
                     sprintf('%1.1f Hz',frequencyAnalysisSimulationData.freqHz(simFreqRange(1),1)),...
                     'FontSize',8,...
                     'Color',simulationModelColor,...
                     'HorizontalAlignment','right',...
                     'VerticalAlignment','top');
                hold on;
            end
        end


        set(gca,'color','none');
        ylim(yLimSettings(idxCoherence,:)); 
        title([titleLabels{idxCoherence},' Coherence$$^2$$ (',seriesName,')']);



% 
%         [lgdH, lgdIcons, lgdPlots, lgdTxt] = ...
%             legend('Location','SouthEast','FontSize',legendFontSize);
%         legend boxoff;        


end


if(flag_addReferenceData==1)

    fittingFilesGain      = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig3_gain.dat'];
    fittingFilesPhase     = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig3_phase.dat'];
    fittingFilesCoherence = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig3_coherence.dat'];

    dataKBR1994Fig3Gain = loadDigitizedData(fittingFilesGain,...
                            'Frequency (Hz)','Stiffness (N/mm)',...
                            {'1.6mm, 90Hz','1.6mm, 15Hz'},'');
    dataKBR1994Fig3Phase = loadDigitizedData(fittingFilesPhase,...
                             'Frequency (Hz)','Phase (deg)',...
                             {'1.6mm, 90Hz','1.6mm, 15Hz'},'');
    dataKBR1994Fig3Coherence = loadDigitizedData(fittingFilesCoherence,...
                              'Frequency (Hz)','Coherence$$^2$$',...
                              {'1.6mm, 90Hz','1.6mm, 15Hz'},'');

    seriesColor = [referenceColorA;referenceColorB];
    seriesLineWidth = [1.0,1.5];


    subplot('Position', reshape(subPlotLayout(idxForce,indexColumn,:),1,4)); 

        plot([timeChunkStart-0.01,timeChunkEnd+0.01],...
             [0,0],...
             '-k','LineWidth',0.5,...
             'HandleVisibility','off');
        hold on;
        xlim([timeChunkStart-0.01,timeChunkStart+0.01]);
        ylim(yLimSettings(idxForce,:));

        ylabel('Force (N)');
        xlabel('Time (s)');
        title([titleLabels{idxForce},' Time domain response (',seriesName,')']);
        set(gca,'color','none');            
        box off;

    subplot('Position', reshape(subPlotLayout(idxGain,indexColumn,:),1,4)); 

        indexRecord=nan;
        if(indexColumn >= 1 && indexColumn <=3)
          indexRecord=2;      
        end
        if(indexColumn >= 4 && indexColumn <=6)   
          indexRecord=1; 
        end

        plot([4,4],yLimSettings(idxGain,:),...
             '-k','HandleVisibility','off');
        hold on;

        plot(dataKBR1994Fig3Gain(indexRecord).x,...
             dataKBR1994Fig3Gain(indexRecord).y,...
           '-','Color',[1,1,1],...
           'LineWidth',seriesLineWidth(1,indexRecord)+1,...
           'HandleVisibility','off');
        hold on;
        plot(dataKBR1994Fig3Gain(indexRecord).x,...
             dataKBR1994Fig3Gain(indexRecord).y,...
           '-','Color',seriesColor(indexRecord,:),...
           'LineWidth',seriesLineWidth(1,indexRecord),...
           'DisplayName','KBR1994');
        hold on;
        set(gca,'color','none');    
        box off;

        xlim([0,bandwidthColumn+0.1]);              
        switch bandwidthColumn
            case 15
                xticks([4,15]);                          
            case 90
                xticks([4,90]);                    
        end  
        yVal0 = interp1(dataKBR1994Fig3Gain(indexRecord).x,...
                     dataKBR1994Fig3Gain(indexRecord).y,...
                     4);
        yVal1 = interp1(dataKBR1994Fig3Gain(indexRecord).x,...
                     dataKBR1994Fig3Gain(indexRecord).y,...
                     bandwidthColumn);
        ylim(yLimSettings(idxGain,:));
        yticks(round([0,yVal0,yVal1],3,'significant'));

        xlabel('Frequency (Hz)');
        ylabel('Gain (N/mm)');
        title([titleLabels{idxGain},' Frequency-response: gain (',seriesName,')']);


    subplot('Position', reshape(subPlotLayout(idxPhase,indexColumn,:),1,4)); 


        plot([4,4],yLimSettings(idxPhase,:),...
             '-k','HandleVisibility','off');
        hold on;

        plot(dataKBR1994Fig3Phase(indexRecord).x,...
             dataKBR1994Fig3Phase(indexRecord).y,...
           '-','Color',[1,1,1],...
           'LineWidth',seriesLineWidth(1,indexRecord)+1,...
           'HandleVisibility','off');
        hold on;

        plot(dataKBR1994Fig3Phase(indexRecord).x,...
             dataKBR1994Fig3Phase(indexRecord).y,...
           '-','Color',seriesColor(indexRecord,:),...
           'LineWidth',seriesLineWidth(1,indexRecord),...
           'DisplayName','KBR1994');
        hold on;

        yVal0 = interp1(dataKBR1994Fig3Phase(indexRecord).x,...
                        dataKBR1994Fig3Phase(indexRecord).y,...
                        4);
        yVal1 = interp1(dataKBR1994Fig3Phase(indexRecord).x,...
                        dataKBR1994Fig3Phase(indexRecord).y,...
                        bandwidthColumn);
        if(indexColumn >3)
            yticks(round([0,yVal0,yVal1, 90, 150],3,'significant'));
        else
            yticks(round([0,yVal0,yVal1, 90],3,'significant'));    
        end
        ylim(yLimSettings(idxPhase,:));


        xlim([0,bandwidthColumn+0.1]);              
        switch bandwidthColumn
            case 15
                xticks([4,15]);                          
            case 90
                xticks([4,90]);                    
        end  
        set(gca,'color','none');            
        box off;

        xlabel('Frequency (Hz)');
        ylabel('Phase ($$^\circ$$)');    
        title([titleLabels{idxPhase},' Frequency-response: phase (',seriesName,')']);


  subplot('Position', reshape(subPlotLayout(idxCoherence,indexColumn,:),1,4)); 
   
    plot([4,4],yLimSettings(idxCoherence,:),...
         '-k','HandleVisibility','off');
    hold on;
  
    plot(dataKBR1994Fig3Coherence(indexRecord).x,...
       dataKBR1994Fig3Coherence(indexRecord).y,...
       '-','Color',[1,1,1],...
       'LineWidth',seriesLineWidth(1,indexRecord)+1,...
       'HandleVisibility','off');
    hold on;
    
    plot(dataKBR1994Fig3Coherence(indexRecord).x,...
       dataKBR1994Fig3Coherence(indexRecord).y,...
       '-','Color',seriesColor(indexRecord,:),...
       'LineWidth',seriesLineWidth(1,indexRecord),...
       'DisplayName','KBR1994');
    hold on;


    xlim([0,bandwidthColumn+0.01]);              
    switch bandwidthColumn
        case 15
            xticks([4,15]);                          
        case 90
            xticks([4,90]);                    
    end  
    set(gca,'color','none');        
    box off;
               
    
    yticks([0,coherenceSqThreshold,1]);
    xlabel('Frequency (Hz)');
    ylabel('Coherence$$^2$$');

    ylim(yLimSettings(idxCoherence,:));
    title([titleLabels{idxCoherence},' Coherence$$^2$$ (',seriesName,')']);

end
