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

  subplot('Position', reshape(subPlotLayout(idxStiffness,indexColumn,:),1,4)); 
    

    xlbl = f0+df;
    ylbl = k1-dk;

    for indexRecord=1:1:length(dataKBR1994Fig12K)
        n = (indexRecord-1)/(numberOfRecordsK-1);
        seriesColor = darkGrey.*n + lightGrey.*(1-n);
        plot(dataKBR1994Fig12K(indexRecord).x,...
             dataKBR1994Fig12K(indexRecord).y,...
             'o','Color',seriesColor,...
             'MarkerSize',7,...
             'MarkerFaceColor',seriesColor);
        hold on;

        plot(xlbl,ylbl,'o','Color',seriesColor,...
             'MarkerSize',7,...
             'MarkerFaceColor',seriesColor);
        hold on;
        text(xlbl+2*df,ylbl,dataKBR1994Fig12K(indexRecord).seriesName);
        hold on;
        ylbl = ylbl-2*df;
    end

    

    ylabel('Stiffness (N/mm)');
    yticks([0:1:8]);

    xlabel('Force (N)');
    xticks([0:2:12]);
    
    xlim([f0,(f1+df)]);
    ylim([d0,(d1+dd)]);    



  subplot('Position', reshape(subPlotLayout(idxDamping,indexColumn,:),1,4)); 
  
    for indexRecord=1:1:length(dataKBR1994Fig12D)
        n = (indexRecord-1)/(numberOfRecordsD-1);
        seriesColor = darkGrey.*n + lightGrey.*(1-n);
        plot(dataKBR1994Fig12D(indexRecord).x,...
             dataKBR1994Fig12D(indexRecord).y,...
             'o','Color',seriesColor,...
             'MarkerSize',7,...
             'MarkerFaceColor',seriesColor);
        hold on;
    end

    ylabel('Damping (N/(mm/s))');
    yticks([0:0.01:0.1]);

    xlabel('Force (N)');
    xticks([0:2:12]);

    xlim([f0,(f1+df)]);
    ylim([k0,k1]);     
end

if(flag_addSimulationData==1)
    
  assert(length(frequencyAnalysisSimulationData.vafTime)==1);    

  vafPercentLabel   = [sprintf('%d',(round(vafTime*100))),'\%'];
    
  %%
  % Stiffness
  %%
  subplot('Position', reshape(subPlotLayout(idxStiffness,indexColumn,:),1,4));       

    idxSim=1;
    plot(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.stiffness(1,idxSim)/1000,...
         'o', ...
         'Color', simulationSpringDamperColor,...
         'LineWidth',1,...
         'MarkerSize',7,...
         'MarkerFaceColor',simulationSpringDamperColor);

    text(frequencyAnalysisSimulationData.nominalForce(1,idxSim)+df,...
         frequencyAnalysisSimulationData.stiffness(1,idxSim)/1000,...
         vafPercentLabel);

    xlim([f0,f1]);
    ylim([k0,k1]);    

    hold on;

  subplot('Position', reshape(subPlotLayout(idxDamping,indexColumn,:),1,4));       

    idxSim=1;
    plot(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.damping(1,idxSim)/1000,...
         'o', ...
         'Color', simulationSpringDamperColor,...
         'LineWidth',1,...
         'MarkerSize',7,...
         'MarkerFaceColor',simulationSpringDamperColor); 

    xlim([f0,f1]);
    ylim([d0,d1]);

    hold on;
end