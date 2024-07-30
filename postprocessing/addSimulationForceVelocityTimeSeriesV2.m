function [figH, simDataVector] = ...
    addSimulationForceVelocityTimeSeriesV2(...
        indexModel,lsdynaMuscleUniform,d3hspFileName,...
        simulationDirectoryName,simMetaData,...
        figH,subplotFvTimeSeries,...
        lineColorA, lineColorB,...
        lineColorRampA,lineColorRampB,...
        lineAndMarkerSettings,...
        plotSettings,...
        muscleArchitecture,...   
        musclePropertiesHL1997,...
        contractionDirection,...
        flag_plotSimulationTimeSeriesTrial)

figure(figH);

switch contractionDirection
    case -1
        idxStart=1;
        idxEnd = 5;
        vSign = -1;
        idxPlotSettings=2;
    case 1
        idxStart=6;
        idxEnd = 10;
        vSign=1;        
        idxPlotSettings=3;
        
    otherwise assert(0,'Error: contractionDirection must be -1 or 1');
end


%%
%Plot meta data
%%
lastTwoChar = simulationDirectoryName(1,end-1:1:end);
trialNumber  = str2num(lastTwoChar);
flag_subMax = 0;
if(isempty(trialNumber) == 0)
    if(trialNumber >= simMetaData.numberSubMaxActStart)
        lineType='--';
        flag_subMax = 1;
    end
end

lineType         = lineAndMarkerSettings.lineType        ;
lineColor        = lineAndMarkerSettings.lineColor       ;
lineWidth        = lineAndMarkerSettings.lineWidth       ;
mark             = lineAndMarkerSettings.mark            ;
markerFaceColor  = lineAndMarkerSettings.markerFaceColor ;
markerLineWidth  = lineAndMarkerSettings.markerLineWidth ;
markerSize       = lineAndMarkerSettings.markerSize      ;  

optimalFiberLength     = muscleArchitecture.lceOpt;
maximumIsometricForce  = muscleArchitecture.fiso;
tendonSlackLength      = muscleArchitecture.ltslk;
pennationAngle         = muscleArchitecture.alpha;
vceNMax                = getParameterValueFromD3HSPFile(d3hspFileName, 'VCEMAX');

timeS0      = getParameterValueFromD3HSPFile(d3hspFileName, 'TIMES0');
timeRamp0   = getParameterValueFromD3HSPFile(d3hspFileName, 'TIMERAMP0');
timeRamp1   = getParameterValueFromD3HSPFile(d3hspFileName, 'TIMERAMP1');

indexS0     = find(lsdynaMuscleUniform.time>=timeS0,1)-1;
indexRamp0  = find(lsdynaMuscleUniform.time>=timeRamp0,1);
indexRamp1  = find(lsdynaMuscleUniform.time>=timeRamp1,1);


%%
% Load the isometric trial at the target length and store the 
% passive and active forces at this length
%%
%Load the isometric binout file

currDir = pwd;    
fileNameIsometric='';

if(flag_subMax == 0)
    fileNameIsometric=fullfile('..','isometric_max');
    cd(fileNameIsometric);    
    [binoutIsometric,status] = ...
        binoutreader('dynaOutputFile','binout0000',...
                        'ignoreUnknownDataError',true);
    timeSampleExcitation1 = getParameterValueFromD3HSPFile('d3hsp', 'TIMES1'); 
    cd(currDir)
else
    fileNameIsometric=fullfile('..','isometric_sub_max');
    cd(fileNameIsometric);
    [binoutIsometric,status] = ...
        binoutreader('dynaOutputFile','binout0000',...
                        'ignoreUnknownDataError',true);
    timeSampleExcitation1 = getParameterValueFromD3HSPFile('d3hsp', 'TIMES1');   
    cd(currDir);    
end

idxPassive          = find(binoutIsometric.elout.beam.time ...
                           >= timeSampleExcitation1,1);
idxPassiveSample    = round(idxPassive*0.5);
idxActiveSample     = round(0.9*(length(binoutIsometric.elout.beam.time)-idxPassive)) ...
                    + idxPassive;

fA = binoutIsometric.elout.beam.axial(idxPassiveSample,1);
fB = binoutIsometric.elout.beam.axial(idxActiveSample,1);

fpNSample = (fA)/maximumIsometricForce;
faNSample = (fB-fA)/maximumIsometricForce;




%%
% Sample the model force when lceN is equal to lceNSample
%%

%Sampling at the time that lceNSample will not work with elastic tendon
%models using the protocol of Herzog & Leonard 1997 which ends at
%the same length. Why? During lenthening the CE's force is enhanced and
%it will remain shorter than lceNSample until well after the shortening
%has ceased.

%timeSample = interp1(lsdynaMuscleUniform.lceN(indexRamp0:indexRamp1,1),...
%                     lsdynaMuscleUniform.time(indexRamp0:indexRamp1,1),...
%                     lceNSample);

%And so, I'm using the very end time of the ramp as the sample time,
%which matches the protocol of Herzog and Leonard. This is only 
%really acceptable if all of the lceN's end up being similar, which 
%in turn, is only possible with a short tendon. Lucky for me a cat 
%soleus has a short tendon relative to the optimal fiber length.
%
%To ensure that I'm sampling the last instant in which the
%muscle is at its maximum shortening rate, I have to make a small
%adjustment because LS-DYNA transitions from the target velocity
%to zero over a few steps. 
idx = indexRamp1;
if(contains(simulationDirectoryName,'isometric')==0)
%     dfR =(lsdynaMuscleUniform.vp(idx,1)...
%         - lsdynaMuscleUniform.vp(idx-1,1));
%     while( abs(dfR) > 1e-8 && idx > indexRamp0)
%         idx=idx-1;
%         dfR =(lsdynaMuscleUniform.vp(idx,1)...
%             - lsdynaMuscleUniform.vp(idx-1,1));                
%     end        
%     if(idx <= indexRamp0)
%         [val,idx]=max(abs(lsdynaMuscleUniform.vp(indexRamp0:indexRamp1,1)));
%         idx = indexRamp0+idx-1;
%     end
%     assert(idx >= indexRamp0,...
%         ['Error: the loop used to refine the end of'...
%          ' the ramp continued to the beginning of the ramp']);
    idx = find( abs(lsdynaMuscleUniform.vp) > 1e-6,1,'last');

else
    idx=indexRamp1;
end
indexSample=idx;
timeSample = lsdynaMuscleUniform.time(indexSample,1);



act = lsdynaMuscleUniform.act(indexSample,1);    
% if(contains(lsdynaMuscleUniform.nameLabel,'VIVA+') ...
%    || contains(lsdynaMuscleUniform.nameLabel,'MAT156'))
%     act=faNSample;
% end

lceN    = lsdynaMuscleUniform.lceN(indexSample,1);
fsN     = lsdynaMuscleUniform.fmtN(indexSample,1);
vsN     = lsdynaMuscleUniform.lceNDot(indexSample,1);






switch lsdynaMuscleUniform.name
    case 'umat41'
        vsN = vsN.*(1/vceNMax); 
    case 'umat43'
        vsN = vsN;           
    case 'viva'
        vsN = vsN.*(1/vceNMax);
    case 'mat156'
        vsN = vsN.*(1/vceNMax);
    otherwise assert(0)
end    

fvN = (fsN-fpNSample);
  
simDataVector = [timeSample,act,lceN,vsN,fvN];

%%
% Plot the time domain signals
%%

if(      (   trialNumber >= simMetaData.numberHL1997ShorteningStart ...
          && trialNumber <= simMetaData.numberHL1997ShorteningEnd) ...
      || (   trialNumber >= simMetaData.numberHL1997LengtheningStart ...
          && trialNumber <= simMetaData.numberHL1997LengtheningEnd) ) 

    typeDirection   = nan;
    typeTrial       = nan;
    typeShortening  = 0;
    typeLengthening = 1;


    if(   trialNumber >= simMetaData.numberHL1997ShorteningStart ...
          && trialNumber <= simMetaData.numberHL1997ShorteningEnd)
        typeDirection=typeShortening;       
    end
    if(   trialNumber >= simMetaData.numberHL1997LengtheningStart ...
          && trialNumber <= simMetaData.numberHL1997LengtheningEnd)
        typeDirection=typeLengthening;        
    end

    if(flag_plotSimulationTimeSeriesTrial==1)
    
        flag_firstTrial=0;
        flag_lastTrial=0;
        if(    (   trialNumber >= simMetaData.numberHL1997ShorteningStart ...
                && trialNumber <=simMetaData.numberHL1997ShorteningEnd) )
    
            subplot('Position',subplotFvTimeSeries);
            n = (trialNumber-simMetaData.numberHL1997ShorteningStart)...
                /(simMetaData.numberHL1997ShorteningEnd-simMetaData.numberHL1997ShorteningStart);
            dySign=-1;
            idxColumn =2;
            if(trialNumber==simMetaData.numberHL1997ShorteningStart)
                flag_firstTrial=1;
            end
            if(trialNumber==simMetaData.numberHL1997ShorteningEnd)
                flag_lastTrial=1;
            end            
        elseif( (   trialNumber >= simMetaData.numberHL1997LengtheningStart ...
                 && trialNumber <= simMetaData.numberHL1997LengtheningEnd) )
            subplot('Position',subplotFvTimeSeries);
            n = (trialNumber-simMetaData.numberHL1997LengtheningStart)...
                /(simMetaData.numberHL1997LengtheningEnd-simMetaData.numberHL1997LengtheningStart);            
            dySign=1;            
            idxColumn =3;
            if(trialNumber==simMetaData.numberHL1997LengtheningStart)
                flag_firstTrial=1;
            end
            if(trialNumber==simMetaData.numberHL1997LengtheningEnd)
                flag_lastTrial=1;
            end
        else
            assert(0,'Error: Somehow an invalid trial number made it into this if statement');
        end
    
        handleVisibility='on';
        %if(flag_lastTrial==1)
        %    handleVisibility='on';
        %end
    
        lineColor = lineColorB.*(1-n) + lineColorA.*(n);
        lineColorRamp = lineColorRampB.*(1-n)+lineColorRampA.*n;
    
        displayNameStr = [lsdynaMuscleUniform.nameLabel, sprintf('(%1.1f)',act)];
        
        yyaxis left;
    
%         if(flag_firstTrial==1)
%             plot(plotSettings(idxColumn).xLim,[1,1],...
%                  '-',...
%                  'Color',[0,0,0],...
%                  'LineWidth',1,...
%                  'HandleVisibility','off');
%             hold on;
%             text(min(plotSettings(2).xLim),1,'$$f^M_o$$',...
%                 'HorizontalAlignment','left',...
%                 'VerticalAlignment','bottom',...
%                 'FontSize',6);
%             hold on;
%         end
    
        plot(lsdynaMuscleUniform.time,...
             lsdynaMuscleUniform.fmtN, ...
             '-',...
            'Color',[1,1,1],...
            'LineWidth',lineWidth+1,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off'); 
        hold on;
        plot(lsdynaMuscleUniform.time(indexSample,1),...
             lsdynaMuscleUniform.fmtN(indexSample,1), ...
             lsdynaMuscleUniform.mark,...
            'Color',[1,1,1],...
            'LineWidth',lineWidth,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',[1,1,1],...
            'MarkerSize',markerSize+2);
        hold on;
        plot(lsdynaMuscleUniform.time,...
             lsdynaMuscleUniform.fmtN, ...
             lineType,...
            'Color',lineColor,...
            'LineWidth',lineWidth,...
            'DisplayName',displayNameStr,...
            'HandleVisibility',handleVisibility,...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;
        plot(lsdynaMuscleUniform.time(indexSample,1),...
             lsdynaMuscleUniform.fmtN(indexSample,1), ...
             lsdynaMuscleUniform.mark,...
            'Color',lineColorA,...
            'LineWidth',lineWidth,...
            'DisplayName',displayNameStr,...
            'HandleVisibility','off',...
            'MarkerFaceColor',markerFaceColor,...
            'MarkerSize',markerSize); 
        hold on;
        box off;
    
    
    %         hTxt=text(   lsdynaMuscleUniform.time(indexSample,1),...
    %                      lsdynaMuscleUniform.fmtN(indexSample,1),...
    %                      sprintf('%s%1.2f%s','$$',pathVel,' \ell^M_o/s$$'),...
    %                      'HorizontalAlignment','left',...
    %                      'VerticalAlignment',vAlign,...
    %                      'FontSize',6);
    %         hold on;
    
        flag_plotModelPath=0;
        %The path is the same but offset from the experimental data
        %due to the tendon.

        if(flag_plotModelPath==1)
            yyaxis right;
            hold on;
            plot(lsdynaMuscleUniform.time,...
                 (lsdynaMuscleUniform.lp-tendonSlackLength)./optimalFiberLength, ...
                 '-',...
                'Color',[1,1,1],...
                'LineWidth',lineWidth+1,...
                'DisplayName',displayNameStr,...
                'HandleVisibility','off'); 
            hold on;
            plot(lsdynaMuscleUniform.time,...
                 (lsdynaMuscleUniform.lp-tendonSlackLength)./optimalFiberLength, ...
                 lineType,...
                'Color',lineColorRamp,...
                'LineWidth',lineWidth,...
                'DisplayName',displayNameStr,...
                'HandleVisibility','off',...
                'MarkerFaceColor',markerFaceColor,...
                'MarkerSize',markerSize); 
            hold on;
        end
    
        flag_plotRampStartEnd=1;
        if(flag_plotRampStartEnd==1)

            %%
            % Get the uniform muscle data for the isometric trial
            %%
            cd(fileNameIsometric);
            d3hspFileName = 'd3hsp';
            musout = [];
            switch lsdynaMuscleUniform.name
                case 'umat41'
                    [musout,success] = ...
                        readUmat41MusoutData('musout.0000000002.0');  
                case 'umat43'
                    [musout,success] = ...
                        readUmat43MusoutData('musout.0000000002'); 
                case 'mat156'
                    disp('  mat156: does not have any musout files');
                case 'viva'
                    disp('  viva: does not have any musout files');
                otherwise assert(0)
            end
            cd(currDir);  
            uniformModelDataIsometric = [];

            if(contains(lsdynaMuscleUniform.name,'mat156')==0)
                cd(fileNameIsometric);
                uniformModelDataIsometric = ...
                    createUniformMuscleModelData(...
                        lsdynaMuscleUniform.name,...
                        musout, binoutIsometric, d3hspFileName,...
                        optimalFiberLength,maximumIsometricForce,...
                        tendonSlackLength,pennationAngle,...
                        'isometric');
                cd(currDir);            
            end

            lceNPassive    = lsdynaMuscleUniform.lceN(indexS0,1);
            lceNRampStart  = lsdynaMuscleUniform.lceN(indexRamp0-5,1);
            lceNRampEnd    = lsdynaMuscleUniform.lceN(end,1);

            indexFeFd = find(lsdynaMuscleUniform.time(:,1)>(timeRamp1+1),1);
            if(isempty(indexFeFd))
                indexFeFd = length(lsdynaMuscleUniform.time(:,1));
            end
            fmtNFeFd = lsdynaMuscleUniform.fmtN(indexFeFd,1);
            fefdN = [];

            xWidth  = diff(plotSettings(idxPlotSettings).xLim);
            yHeight = diff(plotSettings(idxPlotSettings).yLim);            

            switch lsdynaMuscleUniform.name
                case 'mat156'
                     text(lsdynaMuscleUniform.time(end,1),...
                          0.45,...
                          sprintf('%1.3f,%1.3f,%1.3f',lceNRampEnd,fpNSample,faNSample),...
                          'HorizontalAlignment','right',...
                          'Color',markerFaceColor);
                     hold on;

                     fefdN = fmtNFeFd-(fB/maximumIsometricForce);

                     text(lsdynaMuscleUniform.time(indexFeFd,1),...
                          0.75,...
                          sprintf('%1.3f',fefdN),...
                          'HorizontalAlignment','right',...
                          'Color',markerFaceColor,...
                          'FontSize',6);
                     hold on;

                case 'umat41'
                    lceNIso = uniformModelDataIsometric.lceN(end,1);
                    fpeNIso = uniformModelDataIsometric.fpeN(end,1);
                    fmtNIso = uniformModelDataIsometric.fmtN(end,1);

                    text(lsdynaMuscleUniform.time(end,1),...
                          0.35,...
                          sprintf('%1.3f,%1.3f,%1.3f',lceNIso,fpeNIso,fmtNIso),...
                          'HorizontalAlignment','right',...
                          'Color',markerFaceColor);
                     hold on;
                     
                     fefdN = fmtNFeFd-fmtNIso;

                     text(lsdynaMuscleUniform.time(indexFeFd,1),...
                          0.70,...
                          sprintf('%1.3f',fefdN),...
                          'HorizontalAlignment','right',...
                          'Color',markerFaceColor,...
                          'FontSize',6);
                     hold on;                     

                case 'umat43'
                     lceNIso = uniformModelDataIsometric.lceN(end,1);
                     fpeNIso = uniformModelDataIsometric.fpeN(end,1);
                     fmtNIso = uniformModelDataIsometric.fmtN(end,1);

                     text(lsdynaMuscleUniform.time(end,1),...
                          0.25,...
                          sprintf('%1.3f,%1.3f,%1.3f',lceNIso,fpeNIso,fmtNIso),...
                          'HorizontalAlignment','right',...
                          'Color',markerFaceColor);
                     hold on;   

                     fefdN = fmtNFeFd-fmtNIso;

                     text(lsdynaMuscleUniform.time(indexFeFd,1),...
                          0.65,...
                          sprintf('%1.3f',fefdN),...
                          'HorizontalAlignment','right',...
                          'Color',markerFaceColor,...
                          'FontSize',6);
                     hold on;
            end

            

        end

        %%
        % Evaluate the RMSE error against the corresponding data series
        % from Herzog & Leonard 1997
        %%
        yyaxis left;
    
        %%
        %Experimental reference data
        %%
        
        fileHL1997Length = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
                   'ReferenceExperiments',filesep,...
                   'force_velocity',filesep,...
                   'fig_HerzogLeonard1997Fig1A_length.csv'];
        
        fileHL1997Force = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
                   'ReferenceExperiments',filesep,...
                   'force_velocity',filesep,...
                   'fig_HerzogLeonard1997Fig1A_forces.csv'];
        
        dataHL1997Length = loadDigitizedData(fileHL1997Length,...
                        'Time ($$s$$)','Length ($$mm$$)',...
                        {'c01','c02','c03','c04','c05',...
                         'c06','c07','c08','c09','c010'},...
                        {'Herzog and Leonard 1997'}); 
        
        dataHL1997Force = loadDigitizedData(fileHL1997Force,...
                        'Time ($$s$$)','Force ($$N$$)',...
                        {'c01','c02','c03','c04','c05',...
                         'c06','c07','c08','c09','c010'},...
                        {'Herzog and Leonard 1997'}); 
    
        timeRamp0 = getParameterValueFromD3HSPFile(d3hspFileName, 'TIMERAMP0');
        timeRamp1 = getParameterValueFromD3HSPFile(d3hspFileName, 'TIMERAMP1');
    
        pathLen0 = getParameterValueFromD3HSPFile(d3hspFileName, 'PATHLEN0');
        pathLen1 = getParameterValueFromD3HSPFile(d3hspFileName, 'PATHLEN1');
        rampTime = getParameterValueFromD3HSPFile(d3hspFileName, 'RAMPTIME');
        pathLen = (pathLen1-pathLen0).*1000;
        pathVelMM = ((pathLen1-pathLen0)./rampTime)*1000;


    
        idxClosest=nan;
        errSmallest=inf;
        velBest=0;
        for idx=1:1:length(dataHL1997Length)
            vel = diff(dataHL1997Length(idx).y)./diff(dataHL1997Length(idx).x);       
            err = abs(vel(2,1)-pathVelMM);
            if(err < errSmallest)
                idxClosest=idx;
                errSmallest=err;
                velBest=vel(2,1);
            end
        end
    
        %text(0,1,sprintf('%1.1fmm %1.1fmm/s',pathLen,velBest),...
        %     'FontSize',6,'HorizontalAlignment','left');
        %hold on;

        %Found a candidate. Evaluate the RMSE of the force signal
        errForce = zeros(size(lsdynaMuscleUniform.time,1),1).*nan;
        for i=1:1:length(lsdynaMuscleUniform.time)
            fexp = interp1(dataHL1997Force(idxClosest).x,...
                           dataHL1997Force(idxClosest).y,...
                           lsdynaMuscleUniform.time(i,1),...
                           'linear','extrap');
            fexpN = fexp./musclePropertiesHL1997.fiso;
            fsimN = lsdynaMuscleUniform.fmtN(i,1);
            errForce(i,1)=fsimN-fexpN;
        end
    
        idxRamp = find(lsdynaMuscleUniform.time>=timeRamp0 & ...
                       lsdynaMuscleUniform.time<=timeRamp1);
        idxRecovery=find(lsdynaMuscleUniform.time>timeRamp1);
    
        errRamp = errForce(idxRamp,1);
        errRecovery=errForce(idxRecovery,1);
    
        errRampRMSE = sqrt(mean(errRamp.^2));
        errRecoveryRMSE = sqrt(mean(errRecovery.^2));
    
        flag_addRMSE=0;
        if(flag_addRMSE==1)
            dx = (max(lsdynaMuscleUniform.time)-min(lsdynaMuscleUniform.time))./100;
            th=text( lsdynaMuscleUniform.time(indexSample,1)+2*dx,...
                   lsdynaMuscleUniform.fmtN(indexSample,1),...
                   sprintf(' %1.1e',errRampRMSE),...
                   'HorizontalAlignment','left',...
                   'VerticalAlignment','middle',...
                   'FontSize',6);
            if(pathVelMM<0)
                th.Rotation=-45;
            else
                th.Rotation=45;
            end
        end
        
        flag_addRMSE=1;
        if(flag_addRMSE==1)
            yLeft = 1.6;
            yRight= 1.6;
            dy = 0.075;
            dx = 0.02*(lsdynaMuscleUniform.time(end,1)...
                      -lsdynaMuscleUniform.time(1,1));

            timeLabelLeft  = max([1.6,timeRamp0]);
            timeLabelRight = lsdynaMuscleUniform.time(end,1)-dx;

            switch lsdynaMuscleUniform.name
                case 'mat156'
                    text(timeLabelLeft,...
                          yLeft,...
                          sprintf('RMSE'),...
                          'HorizontalAlignment','left',...
                          'Color',[0,0,0]);
                     hold on; 
                    text(timeLabelLeft,...
                          yLeft-dy,...
                          sprintf('%1.3f',errRampRMSE),...
                          'HorizontalAlignment','left',...
                          'Color',markerFaceColor);
                     hold on;

                    text(timeLabelRight,...
                          yRight,...
                          sprintf('RMSE'),...
                          'HorizontalAlignment','right',...
                          'Color',[0,0,0]);
                     hold on;
                     text(timeLabelRight,...
                          yRight-dy,...
                          sprintf('%1.3f',errRecoveryRMSE),...
                          'HorizontalAlignment','right',...
                          'Color',markerFaceColor);
                     hold on;
                case 'umat41'
                    text(timeLabelLeft,...
                          yLeft-2*dy,...
                          sprintf('%1.3f',errRampRMSE),...
                          'HorizontalAlignment','left',...
                          'Color',markerFaceColor);
                    hold on;
                    text(timeLabelRight,...
                         yRight-2*dy,...
                         sprintf('%1.3f',errRecoveryRMSE),...
                         'HorizontalAlignment','right',...
                         'Color',markerFaceColor);
                case 'umat43'
                     text(timeLabelLeft,...
                          yLeft-3*dy,...
                          sprintf('%1.3f',errRampRMSE),...
                          'HorizontalAlignment','left',...
                          'Color',markerFaceColor);
                     hold on;  
                     text(timeLabelRight,...
                          yRight-3*dy,...
                          sprintf('%1.3f',errRecoveryRMSE),...
                          'HorizontalAlignment','right',...
                          'Color',markerFaceColor);                     
            end              

        end

        hold on;
    end
    
end

