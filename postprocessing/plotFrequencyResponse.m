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
                      flag_addSimulationData,...                      
                      simulationColor, ...
                      springDamperColor,...
                      referenceColorA, ...
                      referenceColorB)
                      
figure(figH);


idxForce        = 1;
idxGain         = 2;
idxPhase        = 3;
idxCoherence    = 4;

samplePoints    = inputFunctions.samples;  
paddingPoints   = inputFunctions.padding;
sampleFrequency = inputFunctions.sampleFrequency;

numberOfSamplesInChunk = 0.5*sampleFrequency;

idxChunkStart   = paddingPoints - round(0.25*numberOfSamplesInChunk,0);
idxChunkEnd     = paddingPoints + round(0.75*numberOfSamplesInChunk,0);
idxChunk        = [idxChunkStart:1:idxChunkEnd];




%%
% Plot the experimental data
%%
%if(flag_addReferenceData==1)
%   for k=1:1:length(expAmpPlot)
% 
%     tol = 1e-6;
%     for m=1:1:size(frequencyAnalysisSimulationData.force,2)     
%       if( abs(frequencyAnalysisSimulationData.amplitudeMM(1,m) - expAmpPlot(1,k)) <= tol && ...
%           abs(frequencyAnalysisSimulationData.bandwidthHz(1,m) - expBWPlot(1,k))  <= tol && ...
%           abs(frequencyAnalysisSimulationData.nominalForceDesired(1,m)- modelForce(1,k)) <= tol && ...
%           abs(frequencyAnalysisSimulationData.normFiberLength(1,m)-modelNormFiberLength(1,k)) <= tol)
% 
%         if(1 == 0)
%           1 = m;
%         else
%           assert(0); %Error condition: there should not be 2 simulations with 
%                      %the same configuration
%         end
%       end
%     end      
% 
%     fprintf('%i. K: %1.3f D: %1.3f\n',1,...
%               frequencyAnalysisSimulationData.stiffness(1,1)./1000,...
%               frequencyAnalysisSimulationData.damping(1,1)./1000);
% 
%     %
%     idxRange = [frequencyAnalysisSimulationData.idxFreqRange(1,1):1: ...
%                 frequencyAnalysisSimulationData.idxFreqRange(2,1)];
% 
%     idxCutoff = frequencyAnalysisSimulationData.idxFreqRange(1,1);
% 
% 
%     subplot('Position', subPlotList(idxGain,:));
% 
%     markType = '.';
%     markFaceColor = freqSeriesColor(z,:);
%     markSize = 2;
%     lineWidth = 0.5;
%     kdMarkType = '-';
%     kdLineWidth= 1;
%     kdWhiteLineWidth = 2;
%     kdLineColor = freqSeriesColor(z,:);
%     if(k==2)        
%       markType = 'o';
%       markFaceColor = [1,1,1];
%       markSize = 3;
%       lineWidth=0.1;
%       kdMarkType = '-';
%       kdLineWidth= 1;
%       kdWhiteLineWidth = 3;
%       kdLineColor = freqSeriesColor(z,:).*0.5 + [1,1,1].*0.5;
% 
%     end
% 
%     trialName = sprintf(': %1.1fmm %1.0fHz',...
%                         frequencyAnalysisSimulationData.amplitudeMM(1,1),...
%                         frequencyAnalysisSimulationData.bandwidthHz(1,1));
% 
%     plot(frequencyAnalysisSimulationData.freqHz(idxRange,1), ...
%          frequencyAnalysisSimulationData.gain(idxRange,1)./1000,...
%          markType,'Color',kdLineColor, ...
%          'MarkerFaceColor',markFaceColor,'LineWidth',lineWidth,...
%          'MarkerSize',markSize,'DisplayName',[freqSeriesName{z},trialName]);  
%     hold on;
% 
%     pidW=plot(frequencyAnalysisSimulationData.freqHz(idxRange,1), ...
%          frequencyAnalysisSimulationData.gainKD(idxRange,1)./1000,...
%          '-','Color',[1,1,1], ...
%          'LineWidth',kdWhiteLineWidth);  
%     hold on;
%     set(get(get(pidW,'Annotation'),...
%               'LegendInformation'),...
%               'IconDisplayStyle','off');      
% 
%     pidL=plot(frequencyAnalysisSimulationData.freqHz(idxRange,1), ...
%          frequencyAnalysisSimulationData.gainKD(idxRange,1)./1000,...
%          kdMarkType,'Color',kdLineColor, ...
%          'LineWidth',kdLineWidth,'DisplayName', ['K-$$\beta$$',trialName]);
%     hold on;
% 
%     lineHandlesModelGain = [lineHandlesModelGain,...
%                             pidW,...
%                             pidL];
% 
% 
% 
%     fmin = 0.;
%     fmax = max(modelBWPlot);
%     gmin = 0.;%min(frequencyAnalysisSimulationData.gain(idxRange,1)./1000);
%     gmax = 8.01;
% 
%     if(k == 1)
%       idxSubPlot = idxGain;
%       text(fmin-0.1*(fmax-fmin), 1.1*gmax,...
%              subPlotLabel{1,idxSubPlot},...
%              'FontSize',figLabelFontSize);   
%       hold on;
%     end
% 
%     box off;
%     set(gca,'color','none')        
% 
% 
%     hold on;
% 
% 
%     ylim([gmin,gmax]);
%     xlim([fmin,fmax+0.01]);
%     xticks(xTicksVector);
%     yticks([0,2,4,6,8]);
% 
% 
%     %tc0 = text(fmin-0.15*(fmax-fmin), 1.45*(gmax),...
%     %       'C.','FontSize',11);       
% 
%     subplot('Position', subPlotList(idxPhase,:));
% 
%     plot(frequencyAnalysisSimulationData.freqHz(idxRange,1), ...
%          frequencyAnalysisSimulationData.phase(idxRange,1).*(180/pi),...
%          markType,'Color',kdLineColor, ...
%          'MarkerFaceColor',markFaceColor,'LineWidth',0.5,...
%          'MarkerSize',markSize,...
%          'DisplayName',[freqSeriesName{z},trialName]);   
%     hold on;
% 
%     pidW=plot(frequencyAnalysisSimulationData.freqHz(idxRange,1), ...
%          frequencyAnalysisSimulationData.phaseKD(idxRange,1).*(180/pi),...
%          '-','Color',[1,1,1], ...
%          'LineWidth',kdWhiteLineWidth);  
%     hold on;
%     set(get(get(pidW,'Annotation'),...
%               'LegendInformation'),...
%               'IconDisplayStyle','off');      
% 
%     pidL=plot(frequencyAnalysisSimulationData.freqHz(idxRange,1), ...
%          frequencyAnalysisSimulationData.phaseKD(idxRange,1).*(180/pi),...
%          kdMarkType,'Color',kdLineColor, ...
%          'LineWidth',kdLineWidth,'DisplayName',['K-$$\beta$$',trialName]);  
%     hold on;      
% 
%     lineHandlesModelPhase = [lineHandlesModelPhase,...
%                             pidW,...
%                             pidL];
% 
% 
%     box off;
%     set(gca,'color','none')
% 
%     pmin = 0;
%     pmax = 90.01;
% 
%     ylim([pmin,pmax]);
%     xlim([fmin,fmax+0.01]);
%     xticks(xTicksVector);
%     yticks([0,45,90]);
% 
%     if(k == 1)
%       idxSubPlot = idxPhase;      
%       text(fmin-0.1*(fmax-fmin), 1.1*pmax,...
%              subPlotLabel{1,idxSubPlot},...
%              'FontSize',figLabelFontSize);   
%       hold on;
%     end
% 
% 
%   end

%end

if(flag_addSimulationData==1)

  assert(length(frequencyAnalysisSimulationData.vafTime)==1);    

  if(simConfig.amplitudeMM==1.6 && simConfig.frequencyHz == 15)
    
      subplot('Position', reshape(subPlotLayout(idxForce,indexColumn,:),1,4));       
                                                 
      yo = nominalForce;
    
      spring = frequencyAnalysisSimulationData.stiffness(1,1)./1000;
      damper = frequencyAnalysisSimulationData.damping(1,1)./1000;
      kLabel = sprintf('%1.1f',spring);
      dLabel = sprintf('%1.3f',damper);
    
      kLabel = ['  K: ',kLabel,'N/mm'];
      dLabel = ['  $$\beta$$: ',dLabel,'N/(mm/s)'];
      vafTime = frequencyAnalysisSimulationData.vafTime(1,1);
      vafLabel = [' VAF ', sprintf('%d',(round(vafTime*100))),'\%'];
    
      amplitudeLabel    = sprintf('%1.1fmm',simConfig.amplitudeMM);
      frequencyLabel    = sprintf('%1.0fHz',simConfig.frequencyHz);
    
      pidKD = plot( inputFunctions.time(idxChunk,1),...
                    frequencyAnalysisSimulationData.forceKD(idxChunk,1)+yo,...
                    'Color',springDamperColor,...
                    'LineWidth',2);
      hold on;
    
    
      pidMdl = plot(inputFunctions.time(idxChunk,1),...
                    frequencyAnalysisSimulationData.force(idxChunk,1),...
                    'Color',simulationColor,...
                    'LineWidth',1);
      hold on;  
    
      simText = ['Sim'];
    
            

    
      box off;
      set(gca,'color','none')
    
      tmin = inputFunctions.time(idxChunk(1),1  )-0.01;
      tmax = inputFunctions.time(idxChunk(end),1)+0.01;
      xlim([tmin,...
            tmax]);
      %ylim([0,plotForceMax]);
      xticks(timeTicks);
          
      fmax =max(frequencyAnalysisSimulationData.force(idxChunk,1));
      yticks([0,round(nominalForce,1),round(fmax,1)]);
      set(gca,'color','none')


      plot([0.05,0.1].*(tmax-tmin)+tmin,...
           [0.9,0.9].*(fmax-0)+0,...
           'Color',simulationColor);

      text( 0.15,0.9,simText,'Units','normalized' );        
      hold on;    

      plot([0.05,0.1].*(tmax-tmin)+tmin,...
           [0.8,0.8].*(fmax-0)+0,...
           'Color',springDamperColor);

      text( 0.15,0.8,kLabel,'Units','normalized');        
      hold on;
    
      text( 0.15,0.7,dLabel,'Units','normalized');        
      hold on;
      text( 0.15,0.6,vafLabel);        
      hold on;      
      
      ylabel('Force (N)');
      xlabel('Time (s)');
      title(['A. Time domain response (',amplitudeLabel,' ',frequencyLabel,')']);
  end
% 
%     for z=1:1:length(freqSeriesFiles)
%     
%       flag_Hill = 0;
%       if(isempty(strfind(freqSeriesFiles{1,z},'Hill'))==0)
%         flag_Hill = 1;
%       end    
%     
%       idxForce = 3*(z-1)+1;
%       idxGain  = 3*(z-1)+2;
%       idxPhase = 3*(z-1)+3;  
%       
%     %   idxForce = 1;
%     %   idxGain  = 3;
%     %   idxPhase = 4;
%     %   if(flag_Hill)
%     %     idxForce = 2;
%     %     idxGain  = 5;
%     %     idxPhase = 6;
%     %   end
%     
%       subplot('Position', subPlotList(idxGain,:));
%     
%       for k=1:1:length(expAmpPlot)
%     
%         strAmp = num2str(expAmpPlot(1,k));
%         strFreq= num2str(expBWPlot(1,k));
%         
%         idxExp = 0;
%         tol = 1e-6;
%         for m=1:1:length(dataKBR1994Fig3Gain)           
%           if( contains(dataKBR1994Fig3Gain(m).seriesName,strFreq) && ...
%               contains(dataKBR1994Fig3Gain(m).seriesName,strAmp))        
%             if(idxExp == 0)
%               idxExp = m;
%             else
%               assert(0); %Error condition: there should not be 2 simulations with 
%                          %the same configuration
%             end
%           end
%         end      
%         
%         idxMin = find(dataKBR1994Fig3Gain(idxExp).x >= 4 ,1, 'first' );
%         idxMax = find(dataKBR1994Fig3Gain(idxExp).x <= expBWPlot(1,k) ,1, 'last' );
%         pid = plot( dataKBR1994Fig3Gain(idxExp).x(idxMin:1:idxMax),...
%               dataKBR1994Fig3Gain(idxExp).y(idxMin:1:idxMax),...
%               '-', 'Color', [1,1,1],...
%               'LineWidth', expLineWidth(1,k)*3,...
%               'DisplayName','');
%         hold on;
%     
%         set(get(get(pid,'Annotation'),...
%                     'LegendInformation'),...
%                     'IconDisplayStyle','off');
%     
%         plot( dataKBR1994Fig3Gain(idxExp).x(idxMin:1:idxMax),...
%               dataKBR1994Fig3Gain(idxExp).y(idxMin:1:idxMax),...
%               expMarkType{1,k}, 'Color', expPlotColor(k,:),...
%               'LineWidth',expLineWidth(1,k),...
%               'DisplayName', expLegendEntry{k});
%     
%         hold on;
%       end
%     
%       box off;
%       set(gca,'color','none')  
%       xlabel(dataKBR1994Fig3Gain(idxExp).xName);
%       ylabel('Gain (N/mm)');
%     
%       %if(flag_useElasticTendon==0 )
%         
%         %lh = legend('Location','SouthEast');
%         %lh.Position(1,1) = lh.Position(1,1)+0.03;
%         %lh.Position(1,2) = lh.Position(1,2)-0.03;
%         
%       %end
%     
%       subplot('Position', subPlotList(idxPhase,:));
%     
%       for k=1:1:length(expAmpPlot)
%         
%         strAmp = num2str(expAmpPlot(1,k));
%         strFreq= num2str(expBWPlot(1,k));
%         
%         idxExp = 0;
%         tol = 1e-6;
%         for m=1:1:length(dataKBR1994Fig3Phase)           
%           if( contains(dataKBR1994Fig3Phase(m).seriesName,strFreq) && ...
%               contains(dataKBR1994Fig3Phase(m).seriesName,strAmp))        
%             if(idxExp == 0)
%               idxExp = m;
%             else
%               assert(0); %Error condition: there should not be 2 simulations with 
%                          %the same configuration
%             end
%           end
%         end       
%         
%     
%         idxMin = find(dataKBR1994Fig3Phase(idxExp).x >= 4,1, 'first' );
%         idxMax = find(dataKBR1994Fig3Phase(idxExp).x <= expBWPlot(1,k),1, 'last' );
%         
%         pid = plot( dataKBR1994Fig3Phase(idxExp).x(idxMin:1:idxMax),...
%               dataKBR1994Fig3Phase(idxExp).y(idxMin:1:idxMax),...
%               '-', 'Color', [1,1,1],...
%               'LineWidth',expLineWidth(1,k)*3); 
%         hold on;
%     
%         set(get(get(pid,'Annotation'),...
%                     'LegendInformation'),...
%                     'IconDisplayStyle','off');
%     
%         plot( dataKBR1994Fig3Phase(idxExp).x(idxMin:1:idxMax),...
%               dataKBR1994Fig3Phase(idxExp).y(idxMin:1:idxMax),...
%               expMarkType{1,k}, 'Color', expPlotColor(k,:),...
%               'LineWidth',expLineWidth(1,k),...
%               'DisplayName', expLegendEntry{k}); 
%         hold on;    
%       end
%     
%     
%       xlabel(dataKBR1994Fig3Phase(idxExp).xName);
%       ylabel(dataKBR1994Fig3Phase(idxExp).yName);
%       box off;
%       set(gca,'color','none')
%     
%     
%       %if(flag_useElasticTendon==1 )
%       if(z == 2)
%         lh = legend('Location','South');    
%         lh.Position(1,1) = lh.Position(1,1) -0.15625;        
%         lh.Position(1,2) = lh.Position(1,2) -0.140625;   
%         lh.NumColumns=3;
%         legend boxoff;        
%       end
%       if(z == 4)%length(freqSeriesFiles))
%         lh = legend('Location','South');    
%         lh.Position(1,1) = lh.Position(1,1) -0.15625;            
%         lh.Position(1,2) = lh.Position(1,2) -0.140625;    
%         lh.NumColumns=3;    
%         legend boxoff;    
%       end
%       
%     
%     end
end





success = 1;