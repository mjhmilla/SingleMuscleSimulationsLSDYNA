function figH = plotReflexSimulationData(figH, uniformModelData, ...
                      normLengthChangeThreshold, indexColumn,...
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


lengthThreshold = uniformModelData.lp(1,1)*(normLengthChangeThreshold+1);
timeMin  = min(uniformModelData.time);
timeMax  = max(uniformModelData.time);

indexLengthCrossing = [];
timeOfLengthCrossing = [];
for i=2:1:(length(uniformModelData.time))
  dlL = uniformModelData.lp(i-1,1)-lengthThreshold;
  dlR = uniformModelData.lp(i,1)-lengthThreshold;

  if(dlL*dlR <= 0)
    if(isempty(indexLengthCrossing))
      indexLengthCrossing = i;
      timeOfLengthCrossing  = uniformModelData.time(i,1);
    else
      indexLengthCrossing = [indexLengthCrossing;i];
      timeOfLengthCrossing = [timeOfLengthCrossing;...
                              uniformModelData.time(i,1)];
    end
  end
end

subplot('Position',subplotLength);
    
    plot( uniformModelData.time,...
          uniformModelData.lp,...
          '-','Color',simulationColor,...
          'LineWidth',simulationLineWidth)
    hold on;
    plot([timeMin;timeMax],...
         [1;1].*lengthThreshold,...
         thresholdLineType,...
         'Color', thresholdColor);
    hold on;
    
    lmin = min(uniformModelData.lp);
    lmax = max(uniformModelData.lp);
    lmax = max(lmax,lengthThreshold);
    
    lspan = lmax-lmin;
    l0 = lmin - 0.05*lspan;
    l1 = lmax + 0.05*lspan;
    
    ylim([l0,l1]);
    
    if(isempty(indexLengthCrossing)==0)
        for i=1:1:length(indexLengthCrossing)
          plot([1;1].*uniformModelData.time(indexLengthCrossing(i,1),1),...
               [lmin;lmax],...
               thresholdLineType,...
               'Color', simulationColor);
          hold on;
          text(uniformModelData.time(indexLengthCrossing(i,1),1),...
               uniformModelData.lp(indexLengthCrossing(i,1),1),...
               sprintf('%1.3f',uniformModelData.time(indexLengthCrossing(i,1))) );
          hold on;
        end
    end
    
    xlabel('Time (s)');
    ylabel('Length (m)');
    title([trialName,' :Path Length']);
    
    hold on;
    box off;

subplot('Position',subplotExcitation);

    indexExcitationCrossing = [];
    timeOfExcitationCrossing = [];
    for i=2:1:(length(uniformModelData.time))
      de = uniformModelData.exc(i,1)-uniformModelData.exc(i-1,1);
    
      if(abs(de) > 0.5)
        if(isempty(indexExcitationCrossing))
          indexExcitationCrossing = i;
          timeOfExcitationCrossing  = uniformModelData.time(i,1);
        else
          indexExcitationCrossing = [indexExcitationCrossing;i];
          timeOfExcitationCrossing = [timeOfExcitationCrossing;...
                                  uniformModelData.time(i,1)];
        end
      end
    end


    plot(uniformModelData.time,...
         uniformModelData.exc,...
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
               sprintf('%1.3f',uniformModelData.time(indexExcitationCrossing(i,1))) );
          hold on;
        end
    end

    xlabel('Time (s)');
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
               sprintf('%1.3f',uniformModelData.time(indexExcitationCrossing(i,1))) );
          hold on;
        end
    end


    xlabel('Time (s)');
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
               sprintf('%1.3f',uniformModelData.time(indexExcitationCrossing(i,1))) );
          hold on;
        end
    end


    xlabel('Time (s)');
    ylabel('Norm. Force ($$f^{m}/f^{m}_{o}$$');
    title([trialName,': musculotendon force']);
    
    hold on;
    box off;      
