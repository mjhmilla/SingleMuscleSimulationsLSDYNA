function figH = plotStiffnessDampingPublication(...
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
                      flag_addSimulationData,...
                      lineColorA, lineColorB, ...
                      referenceColorA, referenceColorB,...
                      modelName,...
                      simulationHandleVisibility,...
                      firstStiffnessDampingFile,...
                      lastStiffnessDampingFile)
                      
success = 0;
figure(figH);

idxStiffness=5;
idxDamping  =6;

simulationSpringDamperColor =lineColorA;
simulationModelColor        =lineColorA;

trialDir =pwd;
cd ..;
simTypeDir = pwd;
cd(trialDir);



legendFontSize=6;

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

flag_addRMSE=1;
lsqKBR1994K=struct('dydx',[],'x0',[]);
lsqKBR1994D=struct('dydx',[],'x0',[]);

if( flag_addRMSE==1)
    
    fittingFilesK      = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig12_K.dat'];
    fittingFilesD      = [referenceDataFolder,'/fig_KirschBoskovRymer1994_Fig12_D.dat'];

    dataKBR1994Fig12K = loadDigitizedData(fittingFilesK,...
                            'Force (N)','Stiffness (N/mm)',...
                            {'Soleus','MG'},'');
    numberOfRecordsK = length(dataKBR1994Fig12K);
    
    dataX = [dataKBR1994Fig12K(1).x;dataKBR1994Fig12K(2).x];
    dataY = [dataKBR1994Fig12K(1).y;dataKBR1994Fig12K(2).y];
    
    A = [dataX, ones(size(dataX))];
    b = (A'*A)\(A'*dataY);
    lsqKBR1994K.dydx=b(1,1);
    lsqKBR1994K.x0 = b(2,1);

    dataKBR1994Fig12D = loadDigitizedData(fittingFilesD,...
                             'Force (N)','Damping (N/(mm/s))',...
                             {'Soleus','MG'},'');
    numberOfRecordsD = length(dataKBR1994Fig12D);

    dataX = [dataKBR1994Fig12D(1).x;dataKBR1994Fig12D(2).x];
    dataY = [dataKBR1994Fig12D(1).y;dataKBR1994Fig12D(2).y];

    A = [dataX, ones(size(dataX))];
    b = (A'*A)\(A'*dataY);
    lsqKBR1994D.dydx=b(1,1);
    lsqKBR1994D.x0 = b(2,1);
    
    here=1;
end



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

    referenceColorA = [1,1,1].*0.25;
    referenceColorB= [1,1,1].*0.75;

    amplitudeLabel    = sprintf('%1.1fmm',simConfig.amplitudeMM);
    frequencyLabel    = sprintf('%1.0fHz',simConfig.bandwidthHz);  
    
  subplot('Position', reshape(subPlotLayout(idxStiffness,indexColumn,:),1,4)); 
    

    for indexRecord=1:1:length(dataKBR1994Fig12K)
        n = (indexRecord-1)/(numberOfRecordsK-1);
        seriesColor = referenceColorA.*n + referenceColorB.*(1-n);
        plot(dataKBR1994Fig12K(indexRecord).x,...
             dataKBR1994Fig12K(indexRecord).y,...
             'o','Color',seriesColor,...
             'MarkerSize',4,...
             'MarkerFaceColor',seriesColor,...
             'DisplayName',['KBR1994 ',dataKBR1994Fig12K(indexRecord).seriesName]);
        hold on;        

    end
    x = [0:1:12];
    y = lsqKBR1994K.dydx.*x + lsqKBR1994K.x0;
    plot(x,y,'-','Color',[1,1,1],'LineWidth',2,...
        'HandleVisibility','off');
    hold on;
    plot(x,y,'-','Color',[0,0,0],'LineWidth',0.75,...
        'DisplayName','KBR1994: LSQ');
    hold on;

    set(gca,'color','none');    
    box off;
    
    ylabel('Stiffness (N/mm)');
    yticks([-5:5:10]);

    xlabel('Force (N)');
    xticks([0:6:12]);
    
    xlim([0,12.1]);
    ylim([-5.01,10.01]);    



  subplot('Position', reshape(subPlotLayout(idxDamping,indexColumn,:),1,4)); 
  
    for indexRecord=1:1:length(dataKBR1994Fig12D)
        n = (indexRecord-1)/(numberOfRecordsD-1);
        seriesColor = referenceColorA.*n + referenceColorB.*(1-n);
        plot(dataKBR1994Fig12D(indexRecord).x,...
             dataKBR1994Fig12D(indexRecord).y,...
             'o','Color',seriesColor,...
             'MarkerSize',4,...
             'MarkerFaceColor',seriesColor,...
             'DisplayName',['KBR1994 ',dataKBR1994Fig12D(indexRecord).seriesName]);
        hold on;
    end
    x = [0:1:12];
    y = lsqKBR1994D.dydx.*x + lsqKBR1994D.x0;
    plot(x,y,'-','Color',[1,1,1],'LineWidth',2,...
        'HandleVisibility','off');
    hold on;
    plot(x,y,'-','Color',[0,0,0],'LineWidth',0.75,...
        'DisplayName','KBR1994: LSQ');
    hold on;


    set(gca,'color','none');    
    box off;
    
    ylabel('Damping (N/(mm/s))');
    yticks([0:0.02:0.12]);

    xlabel('Force (N)');
    xticks([0:6:12]);

    xlim([0,12.01]);
    ylim([0,0.121]);     
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
         'MarkerFaceColor',simulationSpringDamperColor,...
         'DisplayName',modelName,...
         'HandleVisibility',simulationHandleVisibility);
    hold on;
    
    text(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.stiffness(1,idxSim)/1000 + dk,...
         vafPercentLabel,...
         'HorizontalAlignment','center',...
         'VerticalAlignment','bottom');
    hold on;
    box off;

    if(firstStiffnessDampingFile==1)
        fid =fopen(fullfile(simTypeDir,'simKRecord.csv'),'w');
        fprintf(fid,'%e,%e\n',...
            frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
            frequencyAnalysisSimulationData.stiffness(1,idxSim)/1000);
        fclose(fid);
    else
        fid =fopen(fullfile(simTypeDir,'simKRecord.csv'),'a');
        fprintf(fid,'%e,%e\n',...
            frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
            frequencyAnalysisSimulationData.stiffness(1,idxSim)/1000);
        fclose(fid);    
    end    
    if(lastStiffnessDampingFile==1 && flag_addRMSE==1)
        dataK = readmatrix(fullfile(simTypeDir,'simKRecord.csv'),'Delimiter',',');
        %Evaluate the error relative to the lsq model
        errK = zeros(size(dataK,1),1);
        for i=1:1:length(errK)
            simF = dataK(i,1);
            simK = dataK(i,2);
            expK = lsqKBR1994K.dydx*simF + lsqKBR1994K.x0;
            errK(i,1) = simK-expK;
        end
        lsqErrK = sqrt(mean(errK.^2));
        text(0.5,-5,...
             sprintf('RMSE\n%1.2f N/mm\n\n',...
             lsqErrK),...
             'FontSize',6,...
             'Color',simulationModelColor,...
             'HorizontalAlignment','left',...
             'VerticalAlignment','bottom');        
        text(0.5,-5,...
             sprintf('\n\nKBR1994 LSQ\n k=%1.2ff+%1.2f',...
             lsqKBR1994K.dydx,lsqKBR1994K.x0),...
             'FontSize',6,...
             'Color',[0,0,0],...
             'HorizontalAlignment','left',...
             'VerticalAlignment','bottom');
        hold on;        
    end

    if(contains(simulationHandleVisibility,'on'))
        lgdH=legend('Location','NorthEast');
        %set(lgdH,'FontSize',legendFontSize);  
        lgdPos = lgdH.Position;
        lgdH.Position = [lgdPos(1)+lgdPos(3)*0.15,lgdPos(2)+lgdPos(4)*0.5,lgdPos(3),lgdPos(4)];
        lgdH.FontSize=legendFontSize;
        legend boxoff;  
        hold on;
    end

  subplot('Position', reshape(subPlotLayout(idxDamping,indexColumn,:),1,4));       

    idxSim=1;
    plot(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.damping(1,idxSim)/1000,...
         'o', ...
         'Color', [1,1,1],...
         'LineWidth',1,...
         'MarkerSize',7,...
         'MarkerFaceColor',simulationSpringDamperColor,...
         'DisplayName',modelName,...
         'HandleVisibility',simulationHandleVisibility); 
    hold on;

    text(frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
         frequencyAnalysisSimulationData.damping(1,idxSim)/1000 + dd,...
         vafPercentLabel,...
         'HorizontalAlignment','center',...
         'VerticalAlignment','bottom');
    hold on;
    box off;
    
    if(firstStiffnessDampingFile==1)
        fid =fopen(fullfile(simTypeDir,'simDRecord.csv'),'w');
        fprintf(fid,'%e,%e\n',...
            frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
            frequencyAnalysisSimulationData.damping(1,idxSim)/1000);
        fclose(fid);
    else
        fid =fopen(fullfile(simTypeDir,'simDRecord.csv'),'a');
        fprintf(fid,'%e,%e\n',...
            frequencyAnalysisSimulationData.nominalForce(1,idxSim),...
            frequencyAnalysisSimulationData.damping(1,idxSim)/1000);
        fclose(fid);    
    end   
    if(lastStiffnessDampingFile==1 && flag_addRMSE==1)
        dataD = readmatrix(fullfile(simTypeDir,'simDRecord.csv'),'Delimiter',',');
        %Evaluate the error relative to the lsq model
        errD = zeros(size(dataD,1),1);
        for i=1:1:length(errD)
            simF = dataD(i,1);
            simD = dataD(i,2);
            expD = lsqKBR1994D.dydx*simF + lsqKBR1994D.x0;
            errD(i,1) = simD-expD;
        end
        lsqErrD = sqrt(mean(errD.^2));
        text(12,0,...
             sprintf('RMSE\n%1.3f N/(mm/s)\n\n',...
             lsqErrD),...
             'FontSize',6,...
             'Color',simulationModelColor,...
             'HorizontalAlignment','right',...
             'VerticalAlignment','bottom');
        hold on; 
        text(12,0,...
             sprintf('\n\nKBR1994 LSQ\n %s=%1.4ff+%1.4f',...
             '$$\beta$$',lsqKBR1994D.dydx,lsqKBR1994D.x0),...
             'FontSize',6,...
             'Color',[0,0,0],...
             'HorizontalAlignment','right',...
             'VerticalAlignment','bottom');
        hold on; 
    end

    if(contains(simulationHandleVisibility,'on'))    
        lgdH=legend('Location','NorthEast');
        lgdPos = lgdH.Position;
        lgdH.Position = [lgdPos(1)+lgdPos(3)*0.15,lgdPos(2)+lgdPos(4)*0.5,lgdPos(3),lgdPos(4)];        
        lgdH.FontSize=legendFontSize;
        legend boxoff;  
        hold on;
    end        
    
end
