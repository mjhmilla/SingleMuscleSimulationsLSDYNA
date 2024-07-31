%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function figH = plotFrequencyResponse(...
                      figH,...
                      simConfig,...
                      inputFunctions,...                      
                      frequencyAnalysisSimulationData,...
                      nominalForce,...
                      indexColumn,...
                      subPlotLayout,...
                      referenceDataFolder,... 
                      flag_addReferenceData,...
                      flag_addSimulationData)
                      
figure(figH);


idxForce        = 1;
idxGain         = 2;
idxPhase        = 3;
idxCoherence    = 4;

samplePoints    = inputFunctions.samples;  
paddingPoints   = inputFunctions.padding;
sampleFrequency = inputFunctions.sampleFrequency;

timeDelta              = 0.5;
numberOfSamplesInChunk = timeDelta*sampleFrequency;

idxChunkStart   = paddingPoints - round(0.25*numberOfSamplesInChunk,0);
idxChunkEnd     = paddingPoints + round(0.75*numberOfSamplesInChunk,0);
idxChunk        = [idxChunkStart:1:idxChunkEnd];


simulationSpringDamperColor =[1,1,1].*0.5;
simulationModelColor        =[1,1,1].*0.9;

switch simConfig.bandwidthHz
    case 15
        simulationSpringDamperColor =[1,0,0];
        simulationModelColor        =[1,0,0].*0.5 + [1,1,1].*0.5;
        
    case 35
        simulationSpringDamperColor =[0.5,0,1].*0.5;
        simulationModelColor        =[0.5,0,1].*0.5 + [1,1,1].*0.5;
        
    case 90
        simulationSpringDamperColor =[0,0,1];
        simulationModelColor        =[0,0,1].*0.5 + [1,1,1].*0.5;
        
end


%%
% Plot the experimental data
%%
labelYNorm = 0.2; %For the experimental data
labelYDeltaNorm = 0.05;
labelXNorm = 0.075+(20/90);  
labelLineXNorm = [0.0,0.05]+(20/90);
labelXTimeNorm     = 0.075;  
labelLineXTimeNorm = [0.0,0.05];

freqMax = 90;
m2mm=1000;
rad2Deg = (180/pi);

if(flag_addSimulationData==1)

  assert(length(frequencyAnalysisSimulationData.vafTime)==1);    

  spring            = frequencyAnalysisSimulationData.stiffness(1,1)./1000;
  damper            = frequencyAnalysisSimulationData.damping(1,1)./1000;
  kLabel            = sprintf('%1.1f',spring);
  dLabel            = sprintf('%1.3f',damper);    
  kLabel            = ['  K: ',kLabel,'N/mm'];
  dLabel            = ['  $$\beta$$: ',dLabel,'N/(mm/s)'];
  vafTime           = frequencyAnalysisSimulationData.vafTime(1,1);
  vafLabel          = [' VAF ', sprintf('%d',(round(vafTime*100))),'\%'];
  amplitudeLabel    = sprintf('%1.1fmm',simConfig.amplitudeMM);
  frequencyLabel    = sprintf('%1.0fHz',simConfig.bandwidthHz);  
  
  simTextShort   = 'Sim';
  simTextAmpFreqVaf = ['Sim: ',amplitudeLabel,' ', frequencyLabel,' (',vafLabel,')'];  
  %simTextVaf     = ['Sim: ',vafLabel];
  
  simTextKDAmpFreq = ['K-$$\beta$$: ',amplitudeLabel,' ',frequencyLabel];
  

  
  if(simConfig.amplitudeMM==1.6 && simConfig.bandwidthHz == 15)
    
      subplot('Position', reshape(subPlotLayout(idxForce,indexColumn,:),1,4));       
                                                 
      yo = nominalForce;
        
      plot( inputFunctions.time(idxChunk,1),...
                    frequencyAnalysisSimulationData.forceKD(idxChunk,1)+yo,...
                    '-','Color',simulationSpringDamperColor,...
                    'LineWidth',0.75);
      hold on;
      
      plot(inputFunctions.time(idxChunk,1),...
                    frequencyAnalysisSimulationData.force(idxChunk,1),...
                    '-', 'Color',[1,1,1],...
                    'LineWidth',3);
                
      plot(inputFunctions.time(idxChunk,1),...
                    frequencyAnalysisSimulationData.force(idxChunk,1),...
                    '-', 'Color',simulationModelColor,...
                    'LineWidth',1);
      hold on;  
    


      box off;
      set(gca,'color','none')
    
      tmin = inputFunctions.time(idxChunk(1),1  )-0.01;
      tmax = inputFunctions.time(idxChunk(end),1)+0.01;
      timeTicks = round([inputFunctions.time(paddingPoints,1):(timeDelta/5):inputFunctions.time(max(idxChunk),1)],2);
      xlim([tmin,...
            tmax]);
      %ylim([0,plotForceMax]);
      xticks(timeTicks);
          
      fmax =max(frequencyAnalysisSimulationData.force(idxChunk,1));
      yticks([0,round(nominalForce,1),round(fmax,1)]);
      set(gca,'color','none')

      axisLim=axis;
      x0=axisLim(1,1);
      x1=axisLim(1,2);      
      y0=axisLim(1,3);
      y1=axisLim(1,4);      
      dx=x1-x0;
      dy=y1-y0;


      yNorm = 1-3*labelYDeltaNorm;

      plot(labelLineXTimeNorm.*dx+x0,...
           [yNorm,yNorm].*dy+y0,...
           'Color',simulationModelColor);

      text( max(labelLineXTimeNorm),yNorm,simTextAmpFreqVaf,'Units','normalized' );        
      hold on;    

      yNorm = 1-4*labelYDeltaNorm;
      plot(labelLineXTimeNorm.*dx+x0,...
           [yNorm,yNorm].*(dy)+y0,...
           'Color',simulationSpringDamperColor);

      text( max(labelLineXTimeNorm),yNorm,[kLabel,' ',dLabel],'Units','normalized');        
      hold on;
    
      axis([x0,x1,y0,y1]);

      %yNorm = labelYNorm+labelYDeltaNorm*0;
      %text( labelXNorm,yNorm,dLabel,'Units','normalized');        
      %hold on;
      %text( labelXNorm,0.15,vafLabel,'Units','normalized');        
      %hold on;      
      
      ylabel('Force (N)');
      xlabel('Time (s)');
      title(['A. Time domain response (',amplitudeLabel,' ',frequencyLabel,')']);
  end
  
  %%Gain
  subplot('Position', reshape(subPlotLayout(idxGain,indexColumn,:),1,4));       
  
    idxMin = find(frequencyAnalysisSimulationData.freqHz >= 4 ,1, 'first' );
    idxMax = find(frequencyAnalysisSimulationData.freqHz <= simConfig.bandwidthHz ,1, 'last' );
    plot( frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
          frequencyAnalysisSimulationData.gain(idxMin:1:idxMax,1)./m2mm,...
          '-', 'Color', simulationModelColor);
    hold on;  
  
    plot(   frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
            frequencyAnalysisSimulationData.gainKD(idxMin:1:idxMax,1)./m2mm,...
            '-', 'Color', [1,1,1],...
            'LineWidth', 2);
    hold on;  
  
    plot(   frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
            frequencyAnalysisSimulationData.gainKD(idxMin:1:idxMax,1)./m2mm,...
            '-', 'Color', simulationSpringDamperColor,...
            'LineWidth', 0.75);
    hold on
    

    
    if(simConfig.bandwidthHz==90)
        xticks([4,15,90]);
        maxGainKD = max(frequencyAnalysisSimulationData.gainKD(idxMin:1:idxMax,1)./m2mm);
        yticks([0,round(maxGainKD,1)]);
        
        xlim([0,90.1]);
        ylim([0, maxGainKD*1.1]);
        
        xlabel('Frequency (Hz)');
        ylabel('Gain (N/mm)');
        
        %h = get(gca,'Children');
        %set(gca,'Children',[h(4:end);h(1:3)]);
    end
    box off;   
    
  %%Phase
  subplot('Position', reshape(subPlotLayout(idxPhase,indexColumn,:),1,4));       
  
    idxMin = find(frequencyAnalysisSimulationData.freqHz >= 4 ,1, 'first' );
    idxMax = find(frequencyAnalysisSimulationData.freqHz <= simConfig.bandwidthHz ,1, 'last' );
    plot( frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
          frequencyAnalysisSimulationData.phase(idxMin:1:idxMax,1).*rad2Deg,...
          '-', 'Color', simulationModelColor);
    hold on;  
  
    plot(   frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
            frequencyAnalysisSimulationData.phaseKD(idxMin:1:idxMax,1).*rad2Deg,...
            '-', 'Color', [1,1,1],...
            'LineWidth', 2);
    hold on;  
  
    plot(   frequencyAnalysisSimulationData.freqHz(idxMin:1:idxMax,1),...
            frequencyAnalysisSimulationData.phaseKD(idxMin:1:idxMax,1).*rad2Deg,...
            '-', 'Color', simulationSpringDamperColor,...
            'LineWidth', 0.75);
    hold on
    

    
    if(simConfig.bandwidthHz==90)
        xticks([4,15,90]);
        maxPhaseKD = max(frequencyAnalysisSimulationData.phaseKD(idxMin:1:idxMax,1).*rad2Deg);
        yticks([0,round(maxPhaseKD,1)]);
        
        xlim([0,90.1]);
        ylim([0, maxPhaseKD*1.1]);
        
        xlabel('Frequency (Hz)');
        ylabel('Phase ($$^\circ$$)');
        
        %h = get(gca,'Children');
        %set(gca,'Children',[h(4:6),h(1:3)]);

    end
    box off;        
    here=1;
    
    %% Coherence
  subplot('Position', reshape(subPlotLayout(idxCoherence,indexColumn,:),1,4));       
  
 
    idxMinCoherence = find(frequencyAnalysisSimulationData.coherenceSqFrequency >= 4 ,1, 'first' );
    idxMaxCoherence = find(frequencyAnalysisSimulationData.coherenceSqFrequency <= simConfig.bandwidthHz ,1, 'last' );
    
    plot( frequencyAnalysisSimulationData.coherenceSqFrequency(1:idxMaxCoherence,1),...
          frequencyAnalysisSimulationData.coherenceSq(1:idxMaxCoherence,1),...
          '-', 'Color', simulationModelColor);
    hold on;

    yPosNorm = 0.;
    switch simConfig.bandwidthHz
        case 15
            yPosNorm = labelYNorm+labelYDeltaNorm*5;            
        case 90
            yPosNorm = labelYNorm+labelYDeltaNorm*3;
    end
    


    
        xticks([4,15,90]);
        yticks([0,1]);
        
        xlim([0,90.1]);
        ylim([0, 1.05]);
        
        xlabel('Frequency (Hz)');
        ylabel('Coherence$$^2$$');
        

          axisLim=axis;
          x0=axisLim(1,1);
          x1=axisLim(1,2);      
          y0=axisLim(1,3);
          y1=axisLim(1,4);      
          dx=x1-x0;
          dy=y1-y0;


        text(labelXNorm, yPosNorm, ...
              simTextAmpFreqVaf,...
              'Units','normalized');
        hold on;    
        plot(mean(labelLineXNorm).*dx+x0, ...
             yPosNorm.*dy+y0,...
             '.','Color',simulationModelColor);
        hold on;
        text(labelXNorm, ...
             (yPosNorm-labelYDeltaNorm), ...
             simTextKDAmpFreq,'Units','normalized');
        hold on;
        plot(labelLineXNorm.*dx+x0,...
             [1,1].*( (yPosNorm-labelYDeltaNorm).*dy+y0),...
             '-','Color',simulationSpringDamperColor);
        hold on;  

    if(simConfig.bandwidthHz==90)
        %h = get(gca,'Children');
        %set(gca,'Children',h(end:-1:1));    
    end
    box off;        
    here=1;    

  

    
    
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

  seriesColor = [0,0,0;0.5,0.5,0.5];
  seriesLineWidth = [1.0,1.5];

  subplot('Position', reshape(subPlotLayout(idxGain,indexColumn,:),1,4)); 

  for indexRecord=1:1:length(dataKBR1994Fig3Gain)
      plot(dataKBR1994Fig3Gain(indexRecord).x,...
           dataKBR1994Fig3Gain(indexRecord).y,...
           '-','Color',[1,1,1],...
           'LineWidth',seriesLineWidth(1,indexRecord)+1);
      hold on;
      
      plot(dataKBR1994Fig3Gain(indexRecord).x,...
           dataKBR1994Fig3Gain(indexRecord).y,...
           '-','Color',seriesColor(indexRecord,:),...
           'LineWidth',seriesLineWidth(1,indexRecord));
      hold on;


% labelYNorm = 0.2; %For the experimental data
% labelYDeltaNorm = 0.1;
% labelXNorm = 1+0.075;  
% labelLineXNorm = 1+[0.0,0.05];
     
  end
  %plot(dataKBR1994Fig3Gain(1).)

  subplot('Position', reshape(subPlotLayout(idxPhase,indexColumn,:),1,4)); 
  for indexRecord=1:1:length(dataKBR1994Fig3Coherence)
      plot(dataKBR1994Fig3Phase(indexRecord).x,...
           dataKBR1994Fig3Phase(indexRecord).y,...
           '-','Color',[1,1,1],...
           'LineWidth',seriesLineWidth(1,indexRecord)+1);
      hold on;
      
      plot(dataKBR1994Fig3Phase(indexRecord).x,...
           dataKBR1994Fig3Phase(indexRecord).y,...
           '-','Color',seriesColor(indexRecord,:),...
           'LineWidth',seriesLineWidth(1,indexRecord));
      hold on;
     
  end

  subplot('Position', reshape(subPlotLayout(idxCoherence,indexColumn,:),1,4)); 
  for indexRecord=1:1:length(dataKBR1994Fig3Coherence)
      plot(dataKBR1994Fig3Coherence(indexRecord).x,...
           dataKBR1994Fig3Coherence(indexRecord).y,...
           '-','Color',[1,1,1],...
           'LineWidth',seriesLineWidth(1,indexRecord)+1);
      hold on;
      
      plot(dataKBR1994Fig3Coherence(indexRecord).x,...
           dataKBR1994Fig3Coherence(indexRecord).y,...
           '-','Color',seriesColor(indexRecord,:),...
           'LineWidth',seriesLineWidth(1,indexRecord));
      hold on;
     

      axisLim=axis;
      x0=axisLim(1,1);
      x1=axisLim(1,2);      
      y0=axisLim(1,3);
      y1=axisLim(1,4);      
      dx=x1-x0;
      dy=y1-y0;

      yNorm = labelYNorm+(indexRecord-1)*labelYDeltaNorm;
      plot(labelLineXNorm.*dx+x0,...
           [yNorm,yNorm].*dy+y0,...
           'Color',seriesColor(indexRecord,:));

      here=1;
      seriesName=dataKBR1994Fig3Coherence(indexRecord).seriesName;      
      text( labelXNorm,yNorm,['KBR1994: ',seriesName],...
          'Units','normalized');        
      hold on;       
  end  
  here=1;
end
