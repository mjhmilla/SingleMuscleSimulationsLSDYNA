function freqSimData = calcSignalGainAndPhase(...
                        tendonForce,...
                        nominalLength,...
                        nominalForce,...
                        activation,...
                        amplitudeMM,...
                        bandwidthHz,...
                        inputFunctions)



assert(size(tendonForce,2)==1)
samplePoints=inputFunctions.samples;

% flag_plotStiffnessDamping,...
% flag_plotDetailedSpectrumData,...
%simSeriesFiles,...   
%simSeriesNames,...
%simSeriesColors,...
%outputFolder
flag_usingOctave=0;
                        
numberOfSimulations=size(activation,2)*length(amplitudeMM)*length(bandwidthHz);
freqSimData = struct('force',  zeros(samplePoints, numberOfSimulations),...
                     'cxx',   zeros(samplePoints*2-1, numberOfSimulations),...
                     'cxy',   zeros(samplePoints*2-1, numberOfSimulations),...
                     'cyy',   zeros(samplePoints*2-1, numberOfSimulations),...
                     'fxx',   zeros(samplePoints*2, numberOfSimulations),...
                     'fxy',   zeros(samplePoints*2, numberOfSimulations),...
                     'fyy',   zeros(samplePoints*2, numberOfSimulations),...
                     'gain',  zeros(samplePoints*2, numberOfSimulations),...
                     'phase',         zeros(samplePoints*2, numberOfSimulations),...
                     'gainKD',  zeros(samplePoints*2, numberOfSimulations),...
                     'phaseKD',         zeros(samplePoints*2, numberOfSimulations),...                     
                     'coherence2',    zeros(samplePoints*2, numberOfSimulations),... 
                     'coherence2Frequency',zeros(samplePoints*2, numberOfSimulations),...
                     'freqHz',        zeros(samplePoints*2, 1),...
                     'freq',          zeros(samplePoints*2, 1),...     
                     'idxFreqRange',  zeros(2, numberOfSimulations),...                
                     'stiffness',     zeros(1,numberOfSimulations),...
                     'damping',       zeros(1,numberOfSimulations),...
                     'vafTime',           zeros(1,numberOfSimulations),...
                     'vafGain',           zeros(1,numberOfSimulations),...          
                     'vafPhase',          zeros(1,numberOfSimulations),...                               
                     'forceKD',       zeros(samplePoints,numberOfSimulations),...
                     'amplitudeMM',   zeros(1,numberOfSimulations),...
                     'bandwidthHz',   zeros(1,numberOfSimulations),...
                     'nominalLength', zeros(1,numberOfSimulations),...
                     'activation',      zeros(1,numberOfSimulations),...
                     'nominalForceDesired', zeros(1,numberOfSimulations),...
                     'nominalForce'      ,zeros(1,numberOfSimulations)); 

% if(flag_plotDetailedSpectrumData == 1)
%   fig_phaseMdl        = figure;
%   fig_magMdl          = figure;
%   fig_coherenceSqMdl  = figure;
%   fig_timeResponseMdl = figure;
%   fig_kin             = figure;      
% end
% if(flag_plotDetailedSpectrumData == 1 || ...
%    flag_plotStiffnessDamping == 1)
%   fig_stiffness = figure;
%   fig_damping   = figure;     
% end

freqMax = inputFunctions.sampleFrequency;
omegaMax = 2*pi*freqMax;
freqCorr =  [1:1:(inputFunctions.samples*2)]' ...
              .*(omegaMax/(inputFunctions.samples*2));
freqHzCorr = [1:1:(inputFunctions.samples*2)]' ...
              .*(freqMax/(inputFunctions.samples*2));

freqSimData.freq = freqCorr;
freqSimData.freqHz=freqHzCorr;

lengthNorm = 1;
forceNorm = 1;

%for idxModel = 1:1:length(simSeriesFiles)
%  tmp = load([outputFolder,simSeriesFiles{idxModel}]);
  idx=1;           

%  flag_Hill = 0;
%  if(isempty(strfind(simSeriesFiles{idxModel},'Hill'))==0)
%    flag_Hill=1;
%  end

%  tag = 'benchRecord';
%  z = strfind(simSeriesFiles{idxModel},tag);
%  outputFileName = ['freqResponse',...
%                    simSeriesFiles{idxModel}(1,(z+length(tag)):end)];


  for idxNormFiberLength = 1:1:size(nominalLength,2)
    for idxActivation = 1:1:size(activation,2)      
      for i=1:1:length(amplitudeMM)        
        for j=1:1:length(bandwidthHz)

          % Save all of the configuration data
          freqSimData.amplitudeMM(1,idx)      = amplitudeMM(i);
          freqSimData.bandwidthHz(1,idx)      = bandwidthHz(j);
          freqSimData.nominalLength(1,idx)    = nominalLength(idxNormFiberLength);
          freqSimData.activation(1,idx)       = activation(1,idx);
          
          freqSimData.nominalForceDesired(1,idx) = nominalForce(1,idxActivation);
          
          idxMidPadding = round(0.5*inputFunctions.padding);
          freqSimData.nominalForce(1,idx)     = nominalForce(1,idxActivation);


          idxWave = getSignalIndex(amplitudeMM(i),bandwidthHz(j),...
                                    inputFunctions);

          %Pick out the frequency range over which this sample has data              
          minFreqHz = 4;
          idxCorrMinFreq = find(freqHzCorr <= minFreqHz, 1, 'last' );
          idxCorrMaxFreq = ...
            find(freqHzCorr <= inputFunctions.bandwidthHz(1,idxWave),...
                  1, 'last' );

          freqSimData.idxFreqRange(1,idx)=idxCorrMinFreq;
          freqSimData.idxFreqRange(2,idx)=idxCorrMaxFreq;

          indexCorrFreqRange = [idxCorrMinFreq:1:idxCorrMaxFreq]';
          indexCorrFreqRangeFull = [1:1:idxCorrMaxFreq]';

          x  = inputFunctions.x(   inputFunctions.idxSignal, idxWave)...
                            ./lengthNorm;
          y  = tendonForce(inputFunctions.idxSignal, 1)...
                            ./forceNorm;
          yo = y(round(inputFunctions.padding*0.5),1);
          y  = y - yo;
          freqSimData.force(:,idx)  =  tendonForce(:, 1);



          %Compute the cross-correlation vector
          %freqSimData.cyy(:,idx) = xcorr( y, y);
          %freqSimData.cxy(:,idx) = xcorr( x, y);
          %freqSimData.cxx(:,idx) = xcorr( x, x);
          freqSimData.cyy(:,idx) = conv( y, y);
          freqSimData.cxy(:,idx) = conv( x, y);
          freqSimData.cxx(:,idx) = conv( x, x);          

          %Compute the spectrum of the cross-correlation vectors
          freqSimData.fyy(:,idx) = ...
            fft([freqSimData.cyy(1,idx);freqSimData.cyy(:,idx)]);
          freqSimData.fxy(:,idx) = ...
            fft([freqSimData.cxy(1,idx);freqSimData.cxy(:,idx)]);
          freqSimData.fxx(:,idx) = ...
            fft([freqSimData.cxx(1,idx);freqSimData.cxx(:,idx)]);

          assert(length(freqSimData.fyy(:,idx))==length(freqCorr));
          assert(length(freqSimData.fyy(:,idx))==length(freqHzCorr));

          %Numerically evaluate the gain, phase, and coherence of the synthetic data
          freqSimData.gain(:,idx)   = ...
            abs(  freqSimData.fxy(:,idx)./freqSimData.fxx(:,idx));
          freqSimData.phase(:,idx)  =...
            angle(freqSimData.fxy(:,idx)./freqSimData.fxx(:,idx));

          %When the xcorr operator is used above a negative sign needs
          %to be used to get the correct sense of the phase.
          %freqSimData.phase(:,idx)  =...
          %  -angle(freqSimData.fxy(:,idx)./freqSimData.fxx(:,idx));

        [Gxy,Fxy] = cpsd(x,y,[],[],[],freqMax,'onesided');
        [Gxx,Fxx] = cpsd(x,x,[],[],[],freqMax,'onesided');
        [Gyy,Fyy] = cpsd(y,y,[],[],[],freqMax,'onesided');
        
        assert(length(Fxy)==length(Fxx) && length(Fxy) == length(Fyy));

        npts =size( freqSimData.coherence2,1);
        c01 = [1:1:npts]./npts;

        GxySampled = interp1(Fxy,Gxy,(c01.*(max(Fxy)-min(Fxy)) + min(Fxy)));
        GxxSampled = interp1(Fxx,Gxx,(c01.*(max(Fxx)-min(Fxx)) + min(Fxx)));
        GyySampled = interp1(Fyy,Gyy,(c01.*(max(Fyy)-min(Fyy)) + min(Fyy)));
        
        
        FxySampled = interp1(Fxy,Fxy,(c01.*(max(Fxy)-min(Fxy)) + min(Fxy)));
        %FxxSampled = interp1(Fxx,Fxx,(c01.*(max(Fxx)-min(Fxx)) + min(Fxx)));
        %FyySampled = interp1(Fyy,Fyy,(c01.*(max(Fyy)-min(Fyy)) + min(Fyy)));
        
        freqSimData.coherence2(:,idx) = ( abs(GxySampled).*abs(GxySampled) ) ./ (GxxSampled.*GyySampled) ;
        freqSimData.coherence2Frequency(:,idx) = FxySampled;
          
          
          %Get a decent starting solution for the optimization routine

          k0 = mean(freqSimData.gain(indexCorrFreqRange,idx));
          d0 = (max(freqSimData.gain(indexCorrFreqRange,idx)) ...
               -min(freqSimData.gain(indexCorrFreqRange,idx))) ...
               /(max(freqCorr(indexCorrFreqRange)));

          if(flag_usingOctave == 0)
            f0 = fit(freqCorr(indexCorrFreqRange,1),...
                     freqSimData.gain(indexCorrFreqRange,idx),...
                     'poly1');

            k0 = f0.p2;
            d0 = f0.p1;
          end

          if(k0 < 100)
            k0 = 100;
          end
          if(d0 < 1)
            d0 = 1;
          end

          %If fmincon is available, then constrain damping to be positive
          A0 = [0 -1];
          b0 = [ 0 ];
          
          x0 = [1,1];
          argScaling =[k0,d0];
          argScalingMin=1;
          argScaling(argScaling<argScalingMin) = argScalingMin;
          objScaling = 1;

          err0 = calcFrequencyDomainSquaredError(x0, ...
                    freqCorr(indexCorrFreqRange,1),...
                    freqSimData.gain(indexCorrFreqRange,idx),...
                    freqSimData.phase(indexCorrFreqRange,idx),...
                    argScaling, ...
                    objScaling);

          objScaling  = 1/max(abs(err0),sqrt(eps));

          errFcn0 = @(argX)calcFrequencyDomainSquaredError(argX, ...
                    freqCorr(indexCorrFreqRange,1),...
                    freqSimData.gain(indexCorrFreqRange,idx),...
                    freqSimData.phase(indexCorrFreqRange,idx),...
                    argScaling,objScaling);


          paramOpt  = []; 
          fval      = [];
          exitFlag  = 0;
          options   = [];
          if(flag_usingOctave == 0)               
            options=optimoptions('fmincon','Display','none','Algorithm','sqp');%optimset('Display','none');
            [paramOpt, fval, exitFlag] = fmincon(errFcn0, x0,A0,b0,[],[],[],[],[],options);        
          else
            options=optimset('Display','none','Algorithm','sqp');%optimset('Display','none');
            [paramOpt, fval, exitFlag] = fminsearch(errFcn0, x0,options);                        
          end
          k0 = paramOpt(1)*argScaling(1);
          d0 = paramOpt(2)*argScaling(2);

          %Now that we've got a decent initial solution, use it to
          %adjust the scaling to the inputs and run the optimization 
          %routine again.

          argScaling = [k0,d0];
          argScaling(argScaling<argScalingMin) = argScalingMin;

          x1 = [0,0];
          x1(1,1) = k0/argScaling(1);
          x1(1,2) = d0/argScaling(2);
          A1 = [0 -1];
          b1 = [ 0 ];


          err1 = calcFrequencyDomainSquaredError(x1, ...
                    freqCorr(indexCorrFreqRange,1),...
                    freqSimData.gain(indexCorrFreqRange,idx),...
                    freqSimData.phase(indexCorrFreqRange,idx),argScaling,1);

          objScaling = 1/max(sqrt(eps),abs(err1));

          errFcn1 = @(argX)calcFrequencyDomainSquaredError(argX, ...
                    freqCorr(indexCorrFreqRange,1),...
                    freqSimData.gain(indexCorrFreqRange,idx),...
                    freqSimData.phase(indexCorrFreqRange,idx),...
                    argScaling,...
                    objScaling);     

          %options=optimset('Display','none');
          %[paramOpt, fval, exitFlag] = fminsearch(errFcn, [k1, d1],options); 

          if(flag_usingOctave==0)       
            [paramOpt, fval, exitFlag] = fmincon(errFcn1, x1,A1,b1,[],[],[],[],[],options);        
          else
            [paramOpt, fval, exitFlag] = fminsearch(errFcn1, x1,options);
          end


          freqSimData.stiffness(1,idx) = paramOpt(1)*argScaling(1);
          freqSimData.damping(1,idx)   = paramOpt(2)*argScaling(2);

          %Evaluate the time-domain response and frequency-domain
          %response of the spring-damper model of best fit.

          modelResponseTime = ...
            (inputFunctions.x(inputFunctions.idxSignal,idxWave)./lengthNorm ...
             ).*freqSimData.stiffness(1,idx) ...
            +(inputFunctions.xdot(inputFunctions.idxSignal,idxWave...
             )./lengthNorm).*freqSimData.damping(1,idx);

          normFactor = forceNorm/lengthNorm;
          freqSimData.forceKD(:,idx) = ...
             (inputFunctions.x(:,idxWave)   ).*(freqSimData.stiffness(1,idx)*normFactor) ...
            +(inputFunctions.xdot(:,idxWave)).*(freqSimData.damping(1,idx)*normFactor);

          modelResponseFreq = ...
            calcFrequencyModelResponse( freqSimData.stiffness(1,idx),...
                                        freqSimData.damping(1,idx),freqCorr);

          %Evaluate the VAF or Variance Accounted For in the time
          %domain. I've also done this in the frequency domain, but
          %it is less insightful there: the nonlinearity of the model
          %introduces quite a bit of variance.
          yVar  = var(y);
          ymVar = var(y-modelResponseTime);              
          freqSimData.vafTime(1,idx)     = (yVar-ymVar)/yVar;

          modelGain  =    abs(modelResponseFreq);
          modelPhase =  angle(modelResponseFreq);

          freqSimData.gainKD(:,idx)  = modelGain;
          freqSimData.phaseKD(:,idx) = modelPhase;

          gVar  = var(freqSimData.gain(indexCorrFreqRange,idx));
          gmVar = var(freqSimData.gain(indexCorrFreqRange,idx) ...
                     - modelGain(indexCorrFreqRange,1));                                                
          freqSimData.vafGain(1,idx)     = (gVar-gmVar)/gVar;

          pVar  = var(freqSimData.phase(indexCorrFreqRange,idx));
          pmVar = var(freqSimData.phase(indexCorrFreqRange,idx) ...
                     -modelPhase(indexCorrFreqRange,1)); 

          freqSimData.vafPhase(1,idx)     = (pVar-pmVar)/pVar;

          trialLabel = '';

%           if(flag_usingOctave==0)
%             trialLabel = inputFunctions.labels(idxWave,:);              
%           else
            trialLabel = sprintf('%s mm %s Hz',...
              num2str(inputFunctions.amplitudeMM(1,idxWave)),...
              num2str(inputFunctions.bandwidthHz(1,idxWave)));                
%          end



          %fprintf('%i. %s %s\n',idx, simSeriesNames{idxModel},trialLabel);
          fprintf('%i. %s\n',idx,trialLabel);
          fprintf('  K %1.3f N/mm D %1.3f N/(mm/s) vafTime %1.1f vafGain %1.1f vafPhase %1.1f Exit %i\n',...
            freqSimData.stiffness(1,idx)/1000,...
            freqSimData.damping(1,idx)/1000,...
            freqSimData.vafTime(1,idx)*100,...
            freqSimData.vafGain(1,idx)*100,...
            freqSimData.vafPhase(1,idx)*100,...
            exitFlag);

%           greyMix = 0.75;
%           dataColor = simSeriesColors(idxModel,:).*(1-greyMix) ...
%                              + [0.5,0.5,0.5].*greyMix;
%           modelColor = simSeriesColors(idxModel,:);
% 
%           if(exitFlag < 1)
%             dataColor =[1,0,0];
%           end
% 
%           idxSubplot = idxWave;
%           if(length(amplitudeMM)*length(bandwidthHz) < size(inputFunctions.bandwidthHz,2))
%             idxSubplot = mod(idx,length(amplitudeMM)*length(bandwidthHz))+1;
%           end

%           if(flag_plotDetailedSpectrumData == 1)             
%             figure(fig_magMdl)
%             subplot(length(amplitudeMM),length(bandwidthHz),idxSubplot);    
% 
%               plot(freqCorr(indexCorrFreqRangeFull,:)./(2*pi), ...
%                    freqSimData.gain(indexCorrFreqRangeFull,idx)./1000,...
%                   'Color',dataColor,'LineWidth',2);    
%               hold on;
%               plot(freqCorr(indexCorrFreqRangeFull,:)./(2*pi),...
%                    abs(modelResponseFreq(indexCorrFreqRangeFull,:))./1000,...
%                    '-','Color',[1,1,1],'LineWidth',2);
%               hold on;                
%               plot(freqCorr(indexCorrFreqRangeFull,:)./(2*pi),...
%                    abs(modelResponseFreq(indexCorrFreqRangeFull,:))./1000,...
%                    '--','Color',modelColor);
%               hold on;
% 
%               xlabel('Frequency (Hz)');
%               ylabel('Magnitude  (N/mm)');
%               title(trialLabel);
% 
%             figure(fig_phaseMdl)
%             subplot(length(amplitudeMM),length(bandwidthHz),idxSubplot);      
% 
%               plot(freqCorr(indexCorrFreqRangeFull,:)./(2*pi), ...
%                    freqSimData.phase(indexCorrFreqRangeFull,idx).*(180/pi),...
%                   'Color',dataColor,'LineWidth',2);    
%               hold on;
%               plot(freqCorr(indexCorrFreqRangeFull,:)./(2*pi),...
%                    angle(modelResponseFreq(indexCorrFreqRangeFull,:)).*(180/pi),...
%                    '-','Color',[1,1,1],'LineWidth',2);
%               hold on;
% 
%               plot(freqCorr(indexCorrFreqRangeFull,:)./(2*pi),...
%                    angle(modelResponseFreq(indexCorrFreqRangeFull,:)).*(180/pi),...
%                    '--','Color',modelColor);
%               hold on;
% 
%               xlabel('Frequency (Hz)');
%               ylabel('Phase');
%               title(trialLabel);
% 
%             figure(fig_coherenceSqMdl)
%             subplot(length(amplitudeMM),length(bandwidthHz),idxSubplot);          
%               plot(freqCorr(indexCorrFreqRangeFull,:)./(2*pi), ...
%                    freqSimData.coherenceSq(indexCorrFreqRangeFull,idx),...
%                   'Color',dataColor,'LineWidth',2);    
%               hold on;
% 
%               ylim([min(0,min(freqSimData.coherenceSq(indexCorrFreqRange,idx))),...
%                     max(1.2,max(freqSimData.coherenceSq(indexCorrFreqRange,idx)))]);
%               xlabel('Frequency (Hz)');
%               ylabel('CoherenceSq');
%               title(trialLabel);
% 
%             figure(fig_timeResponseMdl)
%             subplot(length(amplitudeMM),length(bandwidthHz),idxSubplot);      
%               timeChunk = [1:1:100]';
%               plot(inputFunctions.time(inputFunctions.idxSignal(1,timeChunk),1), ...
%                    freqSimData.force(timeChunk,idx),...
%                   'Color',dataColor,'LineWidth',2);    
%               hold on;
%               plot(inputFunctions.time(inputFunctions.idxSignal(1,timeChunk),1), ...
%                    modelResponseTime(timeChunk,:)+yo.*forceNorm,...
%                    '-','Color',[1,1,1],'LineWidth',2);
%               hold on;
% 
%               plot(inputFunctions.time(inputFunctions.idxSignal(1,timeChunk),1), ...
%                    modelResponseTime(timeChunk,:)+yo.*forceNorm,...
%                    '--','Color',modelColor);
%               hold on;
% 
%               xlabel('Time (s)');
%               ylabel('Force (N)');
%               title(trialLabel);

%              if(isempty(tendonForce) == 0)
%                figure(fig_kin)
%                 subplot(length(amplitudeMM),length(bandwidthHz),idxSubplot);      
%                   timeChunk = [1:1:100]';
% 
%                   plot(inputFunctions.time(inputFunctions.idxSignal(1,timeChunk),1), ...
%                        benchRecord.dstate(inputFunctions.idxSignal(1,timeChunk),idx,1),...
%                       'Color',dataColor,'LineWidth',2);    
%                   hold on;
% 
%                   xlabel('Time (s)');
% 
%                   yLabelStr = '';
%                   if(flag_Hill==1 )
%                     yLabelStr = 'Velocity (m/s)';
%                   else
%                     yLabelStr = 'Acceleration (m/s2)';                          
%                   end
% 
%                   ylabel(yLabelStr);
%                   title(trialLabel);             
%              end
%          end
%           if(flag_plotDetailedSpectrumData == 1 || ...
%              flag_plotStiffnessDamping == 1)
% 
%           figure(fig_stiffness)
%             subplot(length(amplitudeMM),length(bandwidthHz),idxSubplot);      
% 
%               plot(activation(1,idx),...
%                    freqSimData.stiffness(1,idx)./1000,...
%                   'x','Color',dataColor,'LineWidth',2);    
%               hold on;
% 
%               xlabel('Activation');
%               ylabel('Stiffness (N/mm)');
%               title(trialLabel);             
% 
%           figure(fig_damping)
%             subplot(length(amplitudeMM),length(bandwidthHz),idxSubplot);      
% 
%               plot(activation(1,idx),...
%                    freqSimData.damping(1,idx)./1000,...
%                   'o','Color',dataColor,'LineWidth',2);    
%               hold on;
% 
%               xlabel('Activation');
%               ylabel('Damping (N/(mm/s))');
%               title(trialLabel);             
% 
% 
%          end

          idx=idx+1;

        end    
      end          
    end
  end
  %save([outputFolder,outputFileName],'freqSimData');
%end                      
                      

                      