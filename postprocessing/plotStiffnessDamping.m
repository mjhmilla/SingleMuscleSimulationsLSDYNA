function figH = plotStiffnessDamping(...
                      figH,...
                      simConfig,...
                      inputFunctions,...                      
                      frequencyAnalysisSimulationData,...
                      nominalForce,...
                      indexColumn,...
                      subPlotLayout,...
                      referenceDataFolder,...
                      flag_atTargetNominalForce,...
                      flag_addReferenceData,...
                      flag_addSimulationData)
                      
success = 0;

figure(figH);

idxStiffness=5;
idxDamping  =6;

simulationSpringDamperColor =[1,1,1].*0.7;
simulationModelColor        =[1,1,1].*0.9;

switch simConfig.bandwidthHz
    case 15
        simulationSpringDamperColor =[1,0,0];
        simulationModelColor        =[1,0,0].*0.5 + [1,1,1].*0.5;
        
    case 35
        simulationSpringDamperColor =[1,0,1];
        simulationModelColor        =[1,0,1].*0.5 + [1,1,1].*0.5;
        
    case 90
        simulationSpringDamperColor =[0,0,1];
        simulationModelColor        =[0,0,1].*0.5 + [1,1,1].*0.5;
        
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

  
k0=0;
k1=10;
dk =(k1-k0)/20;

d0=0;
d1=0.1;
dd =(d1-d0)/20;

f0=0;
f1=12;
df = (f1-f0)/20;



if(flag_addReferenceData==1)

    fittingFilesK      = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig12_K.dat'];
    fittingFilesD      = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig12_D.dat'];

    dataKBR1994Fig12K = loadDigitizedData(fittingFilesK,...
                            'Force (N)','Stiffness (N/mm)',...
                            {'Soleus','MG'},'');
    numberOfRecordsK = length(dataKBR1994Fig12K);
    
    dataKBR1994Fig12D = loadDigitizedData(fittingFilesD,...
                             'Force (N)','Damping (N/(mm/s))',...
                             {'Soleus','MG'},'');
    numberOfRecordsD = length(dataKBR1994Fig12D);

    darkGrey = [1,1,1].*0.25;
    lightGrey= [1,1,1].*0.75;

    amplitudeLabel    = sprintf('%1.1fmm',simConfig.amplitudeMM);
    frequencyLabel    = sprintf('%1.0fHz',simConfig.bandwidthHz);  
    
  subplot('Position', reshape(subPlotLayout(idxStiffness,indexColumn,:),1,4)); 
    

    xlbl = f0+df;
    ylbl = k1-dk;

    text(xlbl,ylbl,[amplitudeLabel,' ',frequencyLabel]);
    hold on;
    ylbl = ylbl-dk;
    for indexRecord=1:1:length(dataKBR1994Fig12K)
        n = (indexRecord-1)/(numberOfRecordsK-1);
        seriesColor = darkGrey.*n + lightGrey.*(1-n);
        plot(dataKBR1994Fig12K(indexRecord).x,...
             dataKBR1994Fig12K(indexRecord).y,...
             'o','Color',seriesColor,...
             'MarkerSize',4,...
             'MarkerFaceColor',seriesColor);
        hold on;

        plot(xlbl,ylbl,'o','Color',seriesColor,...
             'MarkerSize',4,...
             'MarkerFaceColor',seriesColor);
        hold on;
        text(xlbl+2*df,ylbl,dataKBR1994Fig12K(indexRecord).seriesName);
        hold on;
        ylbl = ylbl-dk;
    end
    plot(xlbl,ylbl,'o','Color',[1,1,1],...
         'MarkerSize',7,...
         'MarkerFaceColor',simulationSpringDamperColor);
    hold on;
    text(xlbl+2*df,ylbl,'Model');
    hold on;



    box off;
    
    ylabel('Stiffness (N/mm)');
    yticks([0:1:10]);

    xlabel('Force (N)');
    xticks([0:2:12]);
    
    xlim([f0,(f1+df)]);
    ylim([k0,(k1+dk)]);    



  subplot('Position', reshape(subPlotLayout(idxDamping,indexColumn,:),1,4)); 
  
    for indexRecord=1:1:length(dataKBR1994Fig12D)
        n = (indexRecord-1)/(numberOfRecordsD-1);
        seriesColor = darkGrey.*n + lightGrey.*(1-n);
        plot(dataKBR1994Fig12D(indexRecord).x,...
             dataKBR1994Fig12D(indexRecord).y,...
             'o','Color',seriesColor,...
             'MarkerSize',4,...
             'MarkerFaceColor',seriesColor);
        hold on;
    end

    box off;
    
    ylabel('Damping (N/(mm/s))');
    yticks([0:0.01:0.1]);

    xlabel('Force (N)');
    xticks([0:2:12]);

    xlim([f0,(f1+df)]);
    ylim([d0,(d1+dd)]);     
end

if(flag_addSimulationData==1)
  idxSim=1;
    
  vafTime           = frequencyAnalysisSimulationData.vafTime(1,idxSim);
  vafPercentLabel   = [sprintf('%d',(round(vafTime*100))),'\%'];
    
  if(flag_atTargetNominalForce==1)
     vafPercentLabel = ['VAF ',vafPercentLabel]; 
  end
  
  %%
  % Stiffness
  %%
  subplot('Position', reshape(subPlotLayout(idxStiffness,indexColumn,:),1,4));       


    plot(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.stiffness(1,idxSim)/1000,...
         'o', ...
         'Color', [1,1,1],...
         'LineWidth',1,...
         'MarkerSize',7,...
         'MarkerFaceColor',simulationSpringDamperColor);
    hold on;
    
    text(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.stiffness(1,idxSim)/1000 + dk,...
         vafPercentLabel,...
         'HorizontalAlignment','center',...
         'VerticalAlignment','bottom');
    hold on;
    
    xlim([f0,f1]);
    ylim([k0,k1]);  
    
    box off;
    hold on;

  subplot('Position', reshape(subPlotLayout(idxDamping,indexColumn,:),1,4));       

    idxSim=1;
    plot(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.damping(1,idxSim)/1000,...
         'o', ...
         'Color', [1,1,1],...
         'LineWidth',1,...
         'MarkerSize',7,...
         'MarkerFaceColor',simulationSpringDamperColor); 
    hold on;

    text(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.damping(1,idxSim)/1000 + dd,...
         vafPercentLabel,...
         'HorizontalAlignment','center',...
         'VerticalAlignment','bottom');
    hold on;
    
    
    xlim([f0,f1]);
    ylim([d0,d1]);
    
    box off;
    hold on;
end
