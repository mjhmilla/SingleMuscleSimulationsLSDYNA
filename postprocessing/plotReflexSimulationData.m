function figH = plotReflexSimulationData(figH, modelName, lceOpt, musout, uniformModelData, ...
                      normCERefrenceLength, normLengthChangeThreshold,...
                      indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations)

figure(figH);

trialName = simulationFile;
trialName(strfind(trialName,'_'))=' ';
i=strfind(trialName,'reflex');
i=i+6;
trialName = trialName((i+1):end);

n = (indexSimulation-1)/(totalSimulations);

simulationColorA = [0.5,0.5,1];
simulationColorB = [0,0,1];
simulationColor =simulationColorA.*n + simulationColorB.*(1-n);

thresholdColor   = simulationColor;



simulationLineWidth = 0.5;
thresholdLineType = '--';

subplotLength      = reshape(subPlotLayout(1,indexColumn,:),1,4);
subplotExcitation  = reshape(subPlotLayout(2,indexColumn,:),1,4);
subplotActivation  = reshape(subPlotLayout(3,indexColumn,:),1,4);
subplotForce       = reshape(subPlotLayout(4,indexColumn,:),1,4);

subplotLceN      = reshape(subPlotLayout(5,indexColumn,:),1,4);
subplotLceDotN   = reshape(subPlotLayout(6,indexColumn,:),1,4);
subplotL1N       = reshape(subPlotLayout(7,indexColumn,:),1,4);

subplotForceTermsN       = reshape(subPlotLayout(8,indexColumn,:),1,4);
subplotMultipliersN      = reshape(subPlotLayout(9,indexColumn,:),1,4);
subplotAccelerationN      = reshape(subPlotLayout(10,indexColumn,:),1,4);


timeMin  = min(uniformModelData.time);
timeMax  = max(uniformModelData.time);

normLengthThreshold = (1+normLengthChangeThreshold)*normCERefrenceLength;
lengthThreshold     = normLengthThreshold*lceOpt;
lengthCEReference   = normCERefrenceLength*lceOpt;

indexLengthCrossing = [];
timeOfLengthCrossing = [];
flag_reflexActive = 0;
for i=1:1:(length(uniformModelData.time))

  if(flag_reflexActive == 1 ...
          && uniformModelData.lceATN(i,1) <= normCERefrenceLength)
      indexLengthCrossing   = [indexLengthCrossing;i];
      timeOfLengthCrossing  = ...
          [timeOfLengthCrossing;uniformModelData.time(i,1)];
      flag_reflexActive=0;
  end
  
  normLengthChange = (uniformModelData.lceATN(i,1)-normCERefrenceLength)...
           /normCERefrenceLength;
  
  if(flag_reflexActive == 0 ...
          && normLengthChange > normLengthChangeThreshold)
      indexLengthCrossing = i;
      timeOfLengthCrossing  = uniformModelData.time(i,1);
      flag_reflexActive = 1;
  end
end

subplot('Position',subplotLength);
    
    plot( uniformModelData.time,...
          uniformModelData.lceATN,...
          '-','Color',simulationColor,...
          'LineWidth',simulationLineWidth)
    hold on;
    
    plot([timeMin;timeMax],...
         [1;1].*normLengthThreshold,...
         thresholdLineType,...
         'Color', thresholdColor);
    hold on;
    
    xlbl = timeMin + 0.05*(timeMax-timeMin);
    text(xlbl, normLengthThreshold,sprintf('%1.4f',normLengthThreshold));
    hold on;
    
    lmin = min(uniformModelData.lceATN);
    lmax = max(uniformModelData.lceATN);
    lmax = max(lmax,normLengthThreshold);
    
    lspan = lmax-lmin;
    l0 = lmin - 0.05*lspan;
    l1 = lmax + 0.05*lspan;
    
    ylim([l0,l1]);
    
    
    if(contains(modelName,'umat41')==1)
        
        
       plot(musout.data(:, musout.indexTime),...
            musout.data(:, musout.indexLceDelay)./lceOpt,...
            '--','Color',[1,0,0],...
            'LineWidth',1);
       hold on;
       
       flag_reflex = 0;
       for i=1:1:size(musout.data(:, musout.indexLceDelay),1)
          if (flag_reflex == 0 ...
                  && musout.data(i, musout.indexLceDelay) >= lengthThreshold)
            plot([1;1].*musout.data(i, musout.indexTime),[l0;l1],...
                 'Color',[1,0,0]);
            hold on;
            text(musout.data(i, musout.indexTime),l1,...
                 sprintf('%1.4f',musout.data(i, musout.indexTime)));
            hold on;
            flag_reflex=1;
          end
          
          if(flag_reflex == 1 ...
                  && musout.data(i, musout.indexLceDelay) <= lengthCEReference)
            plot([1;1].*musout.data(i, musout.indexTime),[l0;l1],...
                 'Color',[1,0,0]);
            hold on;
            text(musout.data(i, musout.indexTime),l1,...
                 sprintf('%1.4f',musout.data(i, musout.indexTime)));
            hold on;
            flag_reflex=0;
              
          end
          
       end
       
    end
    
    if(isempty(indexLengthCrossing)==0)
        for i=1:1:length(indexLengthCrossing)
          plot([1;1].*uniformModelData.time(indexLengthCrossing(i,1),1),...
               [lmin;lmax],...
               thresholdLineType,...
               'Color', simulationColor);
          hold on;
          text(uniformModelData.time(indexLengthCrossing(i,1),1),...
               uniformModelData.lceATN(indexLengthCrossing(i,1),1),...
               sprintf('%1.4f',uniformModelData.time(indexLengthCrossing(i,1))) );
          hold on;
        end
    end
    
    xlabel('Time');
    ylabel('Norm. Length');
    title([trialName,' : CE']);
    
    hold on;
    box off;

subplot('Position',subplotExcitation);

    indexExcitationCrossing = [];
    timeOfExcitationCrossing = [];
    excitationThreshold = min(uniformModelData.exc) ...
        + 0.95*(max(uniformModelData.exc)-min(uniformModelData.exc));
    
    if(max(uniformModelData.exc) > 0.99)
        for i=2:1:(length(uniformModelData.time)-1)
          deR = uniformModelData.exc(i+1,1)  -excitationThreshold;
          deL = uniformModelData.exc(i-1,1)  -excitationThreshold;

          dt   = (uniformModelData.time(i+1,1)-uniformModelData.time(i-1,1));
          de = (uniformModelData.exc(i+1,1)-uniformModelData.exc(i-1,1));
          dedt = de/dt;
          
          if(deR*deL <= 0)
              
            if(dedt > 0 && isempty(indexExcitationCrossing)==1)  
              indexExcitationCrossing = i;
              timeOfExcitationCrossing  = uniformModelData.time(i,1);
            end
            if(dedt < 0 && length(indexExcitationCrossing)==1)
              indexExcitationCrossing = [indexExcitationCrossing;i];
              timeOfExcitationCrossing = [timeOfExcitationCrossing;...
                                      uniformModelData.time(i,1)];
            end
          end
        end
    end


    plot(uniformModelData.time,...
         uniformModelData.exc,...
         '-','Color',simulationColor,...
          'LineWidth',simulationLineWidth);
    hold on;

    ylim([-0.1,1.1]);

    if(isempty(indexLengthCrossing)==0)
        for i=1:1:length(indexLengthCrossing)
          plot([1;1].*uniformModelData.time(indexLengthCrossing(i,1),1),...
               [0;1.05],...
               thresholdLineType,...
               'Color', simulationColor);
          hold on;
          text(uniformModelData.time(indexLengthCrossing(i,1),1),...
               uniformModelData.lceATN(indexLengthCrossing(i,1),1),...
               sprintf('%1.4f',uniformModelData.time(indexLengthCrossing(i,1))) );
          hold on;
        end
    end
    
    if(isempty(indexExcitationCrossing)==0)
        for i=1:1:length(indexExcitationCrossing)
          plot([1;1].*uniformModelData.time(indexExcitationCrossing(i,1),1),...
               [0;1.05],...
               thresholdLineType,...
               'Color', [0,0,0]);
          hold on;
          text(uniformModelData.time(indexExcitationCrossing(i,1),1),...
               1.1,...
               sprintf('%1.4f',uniformModelData.time(indexExcitationCrossing(i,1))) );
          hold on;
        end
    end

    if(isempty(indexExcitationCrossing)==0 ...
            && isempty(indexLengthCrossing)==0)
        n = min(length(indexLengthCrossing),...
                length(indexExcitationCrossing));
        for i=1:1:n
          dt = uniformModelData.time(indexExcitationCrossing(i,1),1) ...
               - uniformModelData.time(indexLengthCrossing(i,1),1);
          text(uniformModelData.time(indexLengthCrossing(i,1),1),...
               0.5,...
               sprintf('%1.4f',dt) );
          hold on;
        end
        
    end
    
    xlabel('Time');
    ylabel('Stimulation (0-1)');
    title([trialName,': excitation']);
    
    hold on;
    box off;

subplot('Position',subplotActivation);

    plot(uniformModelData.time,...
         uniformModelData.act,...
         '-','Color',simulationColor,...
          'LineWidth',simulationLineWidth);
    hold on;

    ylim([-0.1,1.1]);

    if(isempty(indexExcitationCrossing)==0)
        for i=1:1:length(indexExcitationCrossing)
          plot([1;1].*uniformModelData.time(indexExcitationCrossing(i,1),1),...
               [0;1.05],...
               thresholdLineType,...
               'Color', [0,0,0]);
          hold on;
          text(uniformModelData.time(indexExcitationCrossing(i,1),1),...
               1.1,...
               sprintf('%1.4f',uniformModelData.time(indexExcitationCrossing(i,1))) );
          hold on;
        end
    end


    xlabel('Time');
    ylabel('$$Ca^{2+}$$ (0-1)');
    title([trialName,': activation']);
    
    hold on;
    box off;  

subplot('Position',subplotForce);

    plot(uniformModelData.time,...
         uniformModelData.fmtN,...
         '-','Color',simulationColor,...
          'LineWidth',simulationLineWidth);
    hold on;
    

    if(isempty(indexExcitationCrossing)==0)
        for i=1:1:length(indexExcitationCrossing)
          plot([1;1].*uniformModelData.time(indexExcitationCrossing(i,1),1),...
               [0;1.05],...
               thresholdLineType,...
               'Color', [0,0,0]);
          hold on;
          text(uniformModelData.time(indexExcitationCrossing(i,1),1),...
               1.1,...
               sprintf('%1.4f',uniformModelData.time(indexExcitationCrossing(i,1))) );
          hold on;
        end
    end


    xlabel('Time');
    ylabel('Norm. Force ($$f^{m}/f^{m}_{o})$$');
    title([trialName,': musculotendon force']);
    
    hold on;
    box off; 
    
subplot('Position',subplotLceN);

    plot(uniformModelData.time,...
         uniformModelData.lceN,...
         '-','Color',simulationColor,...
          'LineWidth',simulationLineWidth);
    hold on;
    

 


    xlabel('Time');
    ylabel('Norm. Length ($$\ell^{m}/\ell^{m}_{o})$$');
    title([trialName,': CE Length']);
    
    hold on;
    box off;     

subplot('Position',subplotLceDotN);

    plot(uniformModelData.time,...
         uniformModelData.lceNDot,...
         '-','Color',simulationColor,...
          'LineWidth',simulationLineWidth);
    hold on;
    




    xlabel('Time');
    ylabel('Norm. Velocity ($$\dot{\ell}^{m}/\ell^{m}_{o})$$');
    title([trialName,': CE Length']);
    
    hold on;
    box off;     
    
if(contains(modelName,'umat43'))
   subplot('Position',subplotL1N);

    plot(musout.data(:,musout.indexTime),...
         musout.data(:,musout.indexL1HN),...
         '-','Color',simulationColor,...
          'LineWidth',simulationLineWidth);
    hold on;
    




    xlabel('Time');
    ylabel('Norm. Length ($$\ell^{1}/\ell^{m}_{o})$$');
    title([trialName,': Prox. Titin Length']);
    
    hold on;
    box off;     

  subplot('Position',subplotForceTermsN);
  
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexFceATN),...
             '-','Color',[0,0,0],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','fceATN');
        hold on;
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexFecmHN),...
             '-','Color',[0,0,1],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','fecmHN');
      hold on;
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexF2HN),...
             '-','Color',[0,1,0],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','f2HN');
      hold on;  
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexFxHN),...
             '-','Color',[1,0,0],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','fxHN');
      hold on;
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexFxHN),...
             '-','Color',[1,0,0],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','fxHN');
      hold on;
      legend;
      legend boxoff;
      xlabel('Time');
      ylabel('Norm. Force ($$f/f^{m}_{o})$$');
      title([trialName,': Component Forces']);

      hold on;
      box off;     

subplot('Position',subplotMultipliersN);
  
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexFalN),...
             '-','Color',[0.5,0.5,1],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','falN');
        hold on;
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexFvN),...
             '-','Color',[1,0.5,0.5],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','fvN');
      hold on;

      hold on;    
      legend;
      legend boxoff;
      xlabel('Time');
      ylabel('Multipliers ($$f/f^{m}_{o})$$');
      title([trialName,': Multipliers']);

      hold on;
      box off;      
      
subplot('Position',subplotAccelerationN);
  
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexDvsHNHill),...
             '-','Color',[0,0,0],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','Hill');
      hold on;
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexDvsHNDamping),...
             '-','Color',[0,0,1],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','Damping');
      hold on;
      plot(musout.data(:,musout.indexTime),...
             musout.data(:,musout.indexDvsHNTracking),...
             '-','Color',[1,0,0],...
              'LineWidth',simulationLineWidth,...
              'DisplayName','Tracking');
      hold on;

      legend;
      legend boxoff;
      xlabel('Time');
      ylabel('Norm. Acceleration ($$\dot{v}/v^{m}_{o})$$');
      title([trialName,': Acceleration Terms']);

      hold on;
      box off;        
      
end


    
