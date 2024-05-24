%%
% SPDX-FileCopyrightText: 2023 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
% If you use this code in your work please cite the pre-print of this paper
% or the most recent peer-reviewed version of this paper:
%
%    Matthew Millard, David W. Franklin, Walter Herzog. 
%    A three filament mechanistic model of musculotendon force and impedance. 
%    bioRxiv 2023.03.27.534347; doi: https://doi.org/10.1101/2023.03.27.534347 
%
%%

function freqSimData = calcSignalGainAndPhase(...
                        pathLength,...
                        tendonForce,...
                        nominalLength,...
                        nominalForce,...
                        activation,...
                        amplitudeMM,...
                        bandwidthHz,...
                        inputFunctions,...
                        minimumFrequency,...
                        coherenceSqThreshold)

%                        nominalForceSteps,...
%                        amplitudeMM,...
%                        bandwidthHz,...
%                        numberOfSimulations,...
%                        minFreqHz,...
%                        coherenceSqThreshold,...
%                       simSeriesFiles,...   
%                        simSeriesNames,...
%                        simSeriesColors,...
%                        outputFolder,...
%                        flag_plotStiffnessDamping,...
%                        flag_plotDetailedSpectrumData,...
%                        flag_zeroPaddingData,...
%                        flag_usingOctave)

success = 0;


assert(inputFunctions.samples==length(pathLength));
assert(inputFunctions.samples==length(tendonForce));

samplePoints=inputFunctions.samples;



numberOfSimulations=size(activation,2)*length(amplitudeMM)*length(bandwidthHz);
freqSimData = struct('force',  zeros(samplePoints, numberOfSimulations),...      
                     'gain',   zeros(samplePoints*2, numberOfSimulations),...
                     'phase',  zeros(samplePoints*2, numberOfSimulations),...
                     'gainKD',  zeros(samplePoints*2, numberOfSimulations),...
                     'phaseKD',         zeros(samplePoints*2, numberOfSimulations),...                       
                     'coherenceSq',    zeros(samplePoints, numberOfSimulations),... 
                     'coherenceSqFrequency', zeros(samplePoints, numberOfSimulations),... 
                     'freqHz',        zeros(samplePoints, numberOfSimulations),...
                     'freq',          zeros(samplePoints, numberOfSimulations),...
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


 

flag_useKoopmansTransformEstimator=1;

freqMax = inputFunctions.sampleFrequency;



idx = 1;                    

for idxNominalLength = 1:1:size(nominalLength,2)
  for idxActivation = 1:1:size(activation,2)      
    for i=1:1:length(amplitudeMM)        
      for j=1:1:length(bandwidthHz)

        % Save all of the configuration data
        freqSimData.amplitudeMM(1,idx)      = amplitudeMM(i);
        freqSimData.bandwidthHz(1,idx)      = bandwidthHz(j);
        freqSimData.nominalLength(1,idx)    = nominalLength(idxNominalLength);
        freqSimData.activation(1,idx)       = activation(1,idx);
        
        freqSimData.nominalForceDesired(1,idx) = nominalForce(1,idxActivation);
        
        %idxMidPadding = round(0.5*inputFunctions.padding);
        freqSimData.nominalForce(1,idx)        = nominalForce(1,idxActivation);

        %x  = inputFunctions.x(   inputFunctions.idxSignal, idxWave);
        x = pathLength;
        xo= x(round(inputFunctions.padding*0.75),1);
        x=x-xo;

        xFFT = fft(x);
        s = complex(0,1).*(inputFunctions.freq(:,1));
        xdot = ifft(xFFT.*s,'symmetric');

        y  = tendonForce;%(inputFunctions.idxSignal, idx);
        yo = y(round(inputFunctions.padding*0.75),1);
        y  = y - yo;
        freqSimData.force(:,idx)  =  tendonForce(:, idx);


        %Evaluate the cross spectral densities
        [cpsd_Gxy,cpsd_FxyHz] = cpsd(x,y,[],[],[],freqMax,'onesided');
        [cpsd_Gxx,cpsd_FxxHz] = cpsd(x,x,[],[],[],freqMax,'onesided');
        [cpsd_Gyy,cpsd_FyyHz] = cpsd(y,y,[],[],[],freqMax,'onesided');
        [cpsd_Gyx,cpsd_FyxHz] = cpsd(y,x,[],[],[],freqMax,'onesided');
        


        %Make sure all of the cpsd results have the same length
        %which is equivalent to making sure that Matlab used the 
        %same window size for each one
        assert(length(cpsd_FyxHz)==length(cpsd_FxxHz));
        assert(length(cpsd_FyxHz)==length(cpsd_FyyHz));
        assert(length(cpsd_FyxHz)==length(cpsd_FxyHz));

        maxIdx = length(cpsd_Gxy);

        freqHz = cpsd_FyxHz;
        freq   = freqHz.*(2*pi);
        freqSimData.freq(1:maxIdx,idx)   =  cpsd_FyxHz.*(pi/180);
        freqSimData.freqHz(1:maxIdx,idx) =  cpsd_FyxHz;          
        freqSimData.gain(1:maxIdx,idx)   =  abs(  cpsd_Gyx./ cpsd_Gxx);
        freqSimData.phase(1:maxIdx,idx)  =  angle(cpsd_Gyx./ cpsd_Gxx);

        freqSimData.coherenceSq(1:maxIdx,idx) = ...
            ( abs(cpsd_Gxy).*abs(cpsd_Gxy) ) ./ (cpsd_Gxx.*cpsd_Gyy) ;
        freqSimData.coherenceSqFrequency(1:maxIdx,idx) = cpsd_FxyHz;


        idxKirschMin = find(freqSimData.freqHz(1:maxIdx,idx) >= max(0,minimumFrequency-0.1), 1);        
        idxKirschMax = find(freqSimData.freqHz(1:maxIdx,idx) <= bandwidthHz(j)+0.1, 1,'last');
        idxKirschMid = idxKirschMin + round(0.5*(idxKirschMax-idxKirschMin));

        %idxKmeans=kmeans(freqSimData.coherenceSqFrequency(0:idxKirschMax,idx),2);
        if(bandwidthHz==90 && amplitudeMM == 1.6 && abs(nominalForce-5)<0.1)
            here=1;
        end

        idxCoherenceSqHigh = ...
            find(freqSimData.coherenceSq(1:idxKirschMid,idx)...
                 < coherenceSqThreshold);
        idxLb = idxKirschMin;
        if(isempty(idxCoherenceSqHigh)==0)
            if(max(idxCoherenceSqHigh) > idxKirschMin)
                idxLb = max(idxCoherenceSqHigh)+1;
            end
        end

        idxCoherenceSqLow =  ...
            find(freqSimData.coherenceSq(idxKirschMid:idxKirschMax,idx)...
                 < coherenceSqThreshold);
        idxUb = idxKirschMax;
        if(isempty(idxCoherenceSqLow)==0)
            idxCoherenceSqLow=idxCoherenceSqLow+idxKirschMid-1;
            if(min(idxCoherenceSqLow)<idxKirschMax)
                idxUb = min(idxCoherenceSqLow)-1;
            end
        end

%         idxLb = idxKirschMin;
%         while(coherenceSqMedFilt(idxLb)<coherenceSqThreshold ...
%                 && idxLb < idxKirschMax)
%             idxLb=idxLb+1;
%         end
% 
%         idxUb = idxKirschMax;
%         while(coherenceSqMedFilt(idxUb)<coherenceSqThreshold ...
%                 && idxUb > idxKirschMin)
%             idxUb=idxUb-1;
%         end
        assert(idxUb > idxLb, 'Error: no part of the bandwidth meets the coherence threshold');
        
        idxFreqRange = [idxLb:1:idxUb]';
        idxFreqRangeFull = [1:1:idxUb]';

        freqSimData.idxFreqRange(1,idx)=idxLb;
        freqSimData.idxFreqRange(2,idx)=idxUb;          


        %Solve for the spring damping coefficients of best fit to the
        %data
        flag_usingOctave=0;
        [stiffness,damping,exitFlag] = ...
            fitSpringDamperToGainAndPhaseProfiles( ...
                           freq(idxFreqRange,1),...
                           freqSimData.gain(idxFreqRange,idx),...
                           freqSimData.phase(idxFreqRange,idx),...
                           flag_usingOctave);

        freqSimData.stiffness(1,idx) = stiffness;
        freqSimData.damping(1,idx)   = damping;

        %Evaluate the time-domain response and frequency-domain
        %response of the spring-damper model of best fit.

        modelResponseTime = ...
          (x(inputFunctions.idxSignal).*freqSimData.stiffness(1,idx) ...
          +xdot(inputFunctions.idxSignal).*freqSimData.damping(1,idx));

        %idxMidPadding = round(inputFunctions.padding*0.5);
        %x0 = tendonForce(idxMidPadding,1) - modelResponseTime(idxMidPadding,1);
        %modelResponseTime = modelResponseTime+x0;

        freqSimData.forceKD(:,idx) = ...
           (x   ).*(freqSimData.stiffness(1,idx)) ...
          +(xdot).*(freqSimData.damping(1,idx));% ...
%          +x0;

        modelResponseFreq = ...
          calcFrequencyModelResponse( freqSimData.stiffness(1,idx),...
                                      freqSimData.damping(1,idx),freq);     

        %Evaluate the VAF or Variance Accounted For in the time
        %domain. 
        
        yVar  = var(y);
        ymVar = var(y-modelResponseTime);              
        freqSimData.vafTime(1,idx)     = (yVar-ymVar)/yVar;

        modelGain  =    abs(modelResponseFreq);
        modelPhase =  angle(modelResponseFreq);

        freqSimData.gainKD(1:maxIdx,idx) = modelGain;
        freqSimData.phaseKD(1:maxIdx,idx) = modelPhase;

        gVar  = var(freqSimData.gain(idxFreqRange,idx));
        gmVar = var(freqSimData.gain(idxFreqRange,idx) ...
                   - modelGain(idxFreqRange,1));                                                
        freqSimData.vafGain(1,idx)     = (gVar-gmVar)/gVar;

        pVar  = var(freqSimData.phase(idxFreqRange,idx));
        pmVar = var(freqSimData.phase(idxFreqRange,idx) ...
                   -modelPhase(idxFreqRange,1)); 

        freqSimData.vafPhase(1,idx)     = (pVar-pmVar)/pVar;              


        flag_debugW=0;
        if(flag_debugW==1)
            
            figW = figure;
            subplot(1,3,1);

                yyaxis left;
                plot(inputFunctions.time, ...
                     x,...
                     'b');
                hold on;
                xlabel('Time (s)');
                ylabel('Distance (mm)');
  
                yyaxis right;
                plot(inputFunctions.time, ...
                     y,...
                     'b');
                plot(inputFunctions.time,...
                     modelResponseTime, 'm');
                hold on;
                ylabel('Force (N)');
                box off;
  
            subplot(1,3,2);
                plot(freqHz(idxFreqRange,1),...
                        freqSimData.gain(idxFreqRange,idx),'b');
                hold on;
                plot(freqHz(idxFreqRange,1),...
                     abs(modelResponseFreq(idxFreqRange,1)),'--k');
                hold on;
                box off
                xlabel('Frequency (Hz)');
                ylabel('Gain (N/m)');

            subplot(1,3,3);            
                plot( freqHz(idxFreqRange,1),...
                      freqSimData.phase(idxFreqRange,idx).*(180/pi),'b');
                hold on;
                plot(freqHz(idxFreqRange,1),...
                     angle(modelResponseFreq(idxFreqRange,1)).*(180/pi),'--k');
                hold on;
                box off;
                xlabel('Frequency (Hz)');
                ylabel('Phase (degrees)');
            fprintf('%1.2f\t%1.1f\t%1.1f : VAF, k, d\n',freqSimData.vafTime(1,idx), stiffness, damping);
            here=1;
            pause(0.1);
            close(figW);
        end



       
        trialLabel = '';

        if(flag_usingOctave==0)
          idxWave = getSignalIndex(amplitudeMM(i),bandwidthHz(j),...
                                     inputFunctions);            
          trialLabel = inputFunctions.labels(idxWave,:);              
        else
          trialLabel = sprintf('%s mm %s Hz',...
            num2str(amplitudeMM(i)),...
            num2str(bandwidthHz(j)));                
        end



        fprintf('%i. %s\n',idx,trialLabel);
        fprintf('  K %1.3f N/mm D %1.3f N/(mm/s) vafTime %1.1f vafGain %1.1f vafPhase %1.1f Exit %i\n',...
          freqSimData.stiffness(1,idx)/1000,...
          freqSimData.damping(1,idx)/1000,...
          freqSimData.vafTime(1,idx)*100,...
          freqSimData.vafGain(1,idx)*100,...
          freqSimData.vafPhase(1,idx)*100,...
          exitFlag);

          
       end

        idx=idx+1;

    end    
  end          
end

here=1;


                    
                      
                      