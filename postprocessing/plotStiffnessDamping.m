function figH = plotStiffnessDamping(...
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
                      
success = 0;


idxStiffness=5;
idxDamping  =6;

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
  
    
  %%
  % Stiffness
  %%
  subplot('Position', reshape(subPlotLayout(idxStiffness,indexColumn,:),1,4));       

    idxSim=1;
    plot(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.stiffness(1,idxSim)/1000,...
         modelMarkType, ...
         'Color', modelLineColor,...
         'LineWidth',modelLineWidth,...
         'MarkerSize',modelMarkSize,...
         'MarkerFaceColor',modelFaceColor,...
         'DisplayName',freqSeriesName{z});
  
  %%
  %Plot the model data
  %%  
  
  for z=1:1:length(freqSeriesFiles)

    modelColor = freqSeriesColor(z,:);
    tmp = load([dataInputFolder, freqSeriesFiles{1,z}]);
    freqSimData = tmp.freqSimData;

    modelLineColor = [1,1,1];
    modelMarkType = 'o';
    modelMarkSize = 7;
    modelLineWidth= 1;
    modelFaceColor = modelColor;%[1,1,1];
    
    %if(z==2)
    %  modelMarkSize = modelMarkSize -1;
    %  modelMarkType = 'd';
    %end
    
    
    flag_Hill = 0;
    if(isempty(strfind(freqSeriesFiles{1,z},'Hill'))==0)
      flag_Hill = 1;
    end

    idxK = 1+freqSeriesSubPlotOffsetIdx(1,z);
    idxD = 2+freqSeriesSubPlotOffsetIdx(1,z);
    
    for i=1:1:length(nominalForce)
    
      idxSim = 0;
      tol = 1e-6;
      for m=1:1:size(freqSimData.force,2)     
        if( abs(freqSimData.amplitudeMM(1,m)     - targetAmplitude   ) <= tol && ...
            abs(freqSimData.bandwidthHz(1,m)     - targetBandwidth   ) <= tol && ...
            abs(freqSimData.nominalForceDesired(1,m) - nominalForce(1,i) ) <= tol && ...
            abs(freqSimData.normFiberLength(1,m) - normFiberLength   ) <= tol)
          if(idxSim == 0)
            idxSim = m;
          else
            assert(0); %Error condition: there should not be 2 simulations with 
                       %the same configuration
          end
        end
      end
      
      subplot('Position', [ subPlotList(idxK,1),...
                            subPlotList(idxK,2),...
                            subPlotList(idxK,3),...
                            subPlotList(idxK,4)]);    

      
      
      pid = 
      hold on;
      if(i > 1)
        set(get(get(pid,'Annotation'),...
                  'LegendInformation'),...
                  'IconDisplayStyle','off'); 
      end
      
      posTextK = [freqSimData.nominalForce(1,idxSim),...
                freqSimData.stiffness(1,idxSim)/1000];
      vafText = sprintf('%1.0f',freqSimData.vafTime(1,idxSim)*100); 
      if(i==3)
        vafText = ['VAF:',vafText];
      end

      
      textDeltaX  = 0;
      textDeltaY  = 0;
      textAlign   = '';      
      if(flag_useElasticTendon == 1)
        textDeltaX = -0.25;
        textDeltaY = 0;
        textAlign = 'right';
        if(flag_Hill == 1)
          textDeltaX = 0.25;%-0.25;
          textDeltaY = 0;
          textAlign = 'left';
        end
      else
        textDeltaX = -0.25;
        textDeltaY = 0;%0.25;
        textAlign = 'right';
        if(flag_Hill == 1)
          textDeltaX = 0.25;
          textDeltaY = 0;%-0.35;
          textAlign = 'left';
        end
        
      end
      text(posTextK(1,1)+textDeltaX,...
           posTextK(1,2)+textDeltaY,[vafText,'\%'],...
            'HorizontalAlignment',textAlign);
      hold on;
      xlim([fMin,fMax]);
      ylim([kMin,kMax]);      

      if(i == 1 && z==1 || i==1 && z==2)

        tc = text(fMin-0.1*(fMax-fMin), 1.1*kMax,...
               subPlotLabel{1,idxK},...
               'FontSize',figLabelFontSize);   
        hold on;
      end              
      
      
      if(z==1 && i==1)
        x0 = subPlotList(idxK,1);
        y0 = subPlotList(idxK,2);
        dx = subPlotList(idxK,3);
        dy = subPlotList(idxK,4);

        text(fMin,kMax*1.2,'Simulation of Kirsch, Boskov, \& Rymer 1994',...
        'FontSize',8*1.2,...
        'HorizontalAlignment','left',...
        'VerticalAlignment','bottom');
        hold on;     

      end
      
      subplot('Position', [ subPlotList(idxD,1),...
                            subPlotList(idxD,2),...
                            subPlotList(idxD,3),...
                            subPlotList(idxD,4)]);      

                          
      pid = plot( freqSimData.nominalForce(1,idxSim),...
                  freqSimData.damping(1,idxSim)/1000,...
                  modelMarkType, ...
                  'Color', modelLineColor,...
                  'LineWidth',modelLineWidth,...
                  'MarkerSize',modelMarkSize,...
                  'MarkerFaceColor',modelFaceColor,...
                  'DisplayName',[freqSeriesName{z},perturbationName]);
      hold on;
      posTextD = [freqSimData.nominalForce(1,idxSim),...
                freqSimData.damping(1,idxSim)/1000];
              
              
      text(posTextD(1,1)+textDeltaX,...
           posTextD(1,2)+textDeltaY,[vafText,'\%'],...
            'HorizontalAlignment',textAlign);
      hold on;
      
      if( i > 1)
        set(get(get(pid,'Annotation'),...
                  'LegendInformation'),...
                  'IconDisplayStyle','off'); 
      end 
      xlim([fMin,fMax]);
      ylim([dMin,dMax]);

      if(i == 1 && z==1 || i==1 && z==2)
        tc = text(fMin-0.1*(fMax-fMin), 1.1*dMax,...
               subPlotLabel{1,idxD},...
               'FontSize',figLabelFontSize);   
        hold on;
      end              
            
    end
  end
  
end