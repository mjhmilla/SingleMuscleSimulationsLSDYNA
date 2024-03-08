clc;
close all;
clear all;

addpath(genpath('ReferenceExperiments'));

rootDir = pwd;

assert(contains(rootDir(1,end-29:end),'SingleMuscleSimulationsLSDYNA'),...
       'Error: must start this with matlab in the main directory');



%Settings
modelName       = 'umat43'; 
%Options:
%   umat41
%   umat43
%   mat156
%   viva

simulationName  = 'force_velocity'; 
%Options:
%   force_velocity                   (not with viva)
%   force_velocity_viva              (not with mat156)
releaseName     ='MPP_R931';

units_kNmmms = 0;
units_Nms    = 1; 



%%
% Units check
%%
switch simulationName
    case 'force_velocity'
        unitsSetting = units_Nms;   
        assert(strcmp(modelName,'viva')==0,'Error: simulation and model incompatible'); 
    case 'force_velocity_viva'
        unitsSetting = units_kNmmms;
        assert(strcmp(modelName,'mat156')==0,'Error: simulation and model incompatible');
    otherwise assert(0,'Error: invalid simulationName');
end    

%%
% Activation settings
%%
switch simulationName
    case 'force_velocity'
        exMax       = 1.0;
        exSubMax    = 0.18;
        if(contains(modelName,'umat41'))
            q0=1e-4;
            q=exSubMax;
            exSubMax=(0.5*(q-q0))/(1-(1-0.5)*(q-q0));
        end
    case 'force_velocity_viva'
        exMax       = 1.0;
        exSubMax    = 0.18;
        if(contains(modelName,'umat41'))
            q0=1e-4;
            q=exSubMax;
            exSubMax=(0.5*(q-q0))/(1-(1-0.5)*(q-q0));
        end
    otherwise
        assert(0,'Error: invalid simulation type chosen');
end

%%
% Data
%%
musclePropertiesHL1997 = getHerzogLeonard1997MuscleProperties();

fileHL1997Length = [...
           'ReferenceExperiments',filesep,...
           'force_velocity',filesep,...
           'fig_HerzogLeonard1997Fig1A_length.csv'];

fileHL1997Force = [...
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

assert(length(dataHL1997Force)==length(dataHL1997Length));

%%
%  Identify the beginning & ending of the ramp from the force data
%  of Herzog and Leonard 1997
%%
rows = 2;
cols = 5;
figData = figure;

rampDataHL1997(10) = struct('time',zeros(1,2),'length',zeros(1,2),'force',zeros(1,2),...
                      'velocity',zeros(1,1));
disp('HL1997 Trial Normalized Velocity');
for idx=1:1:length(dataHL1997Force)
    figure(figData);
    subplot(rows,cols,idx);
    
    velSign=1;
    if( (dataHL1997Length(idx).y(3,1)-dataHL1997Length(idx).y(2,1)) < 0 )
        velSign = -1;
    end

    df = calcCentralDifferenceDataSeries(dataHL1997Force(idx).x,...
                                         dataHL1997Force(idx).y);

    %These are rough
    timeLength0 = dataHL1997Length(idx).x(2,1);
    timeLength1 = dataHL1997Length(idx).x(3,1);
    idxPreRamp0  = find(dataHL1997Force(idx).x < timeLength0,1,'last');
    idxPreRamp1  = find(dataHL1997Force(idx).x < timeLength1,1,'last');


    for i=1:1:2
        switch i
            case 1
                idxA = idxPreRamp0;
                idxB = (idxPreRamp0+3);
            case 2
                idxA = idxPreRamp1;
                idxB = (idxPreRamp1+3);                
        end
        valMaxDeltaDf = 0;
        for j=idxA:1:idxB
            dfLeft = dataHL1997Force(idx).y(j,1)-dataHL1997Force(idx).y(j-1,1);
            dtLeft = dataHL1997Force(idx).x(j,1)-dataHL1997Force(idx).x(j-1,1);
            dfdtL = dfLeft./dtLeft;
    
            dfRight= dataHL1997Force(idx).y(j+1,1)-dataHL1997Force(idx).y(j,1);
            dtRight= dataHL1997Force(idx).x(j+1,1)-dataHL1997Force(idx).x(j,1);
            dfdtR = dfRight./dtRight;
            
            if(abs(dfdtL-dfdtR) > valMaxDeltaDf)
                valMaxDeltaDf=abs(dfdtL-dfdtR);
                rampDataHL1997(idx).time(1,i)= dataHL1997Force(idx).x(j,1);
                rampDataHL1997(idx).force(1,i)=dataHL1997Force(idx).y(j,1);

            end        
        end
    end

    dl = 0;
    switch unitsSetting
        case units_kNmmms
            dl = 4;
        case units_Nms
            dl = 0.004;
    end
    rampDataHL1997(idx).length(1,1) = -dl*velSign;
    rampDataHL1997(idx).length(1,2) = 0;
    rampDataHL1997(idx).velocity(1,1) = dl*velSign / diff(rampDataHL1997(idx).time);

    fprintf('%i. %1.3f\n',idx,rampDataHL1997(idx).velocity(1,1)./musclePropertiesHL1997.lceOpt);

    yyaxis left;
    plot(dataHL1997Force(idx).x,...
         dataHL1997Force(idx).y);
    hold on;
    plot(dataHL1997Force(idx).x,...
         (df-min(df))./(max(df)-min(df)),'k');
    
    hold on;
    plot(rampDataHL1997(idx).time,...
         rampDataHL1997(idx).force,'.k');
    hold on;
    
    xlabel('Time (s)');
    ylabel('Force (N)');



    yyaxis right;
    plot(dataHL1997Length(idx).x,...
         dataHL1997Length(idx).y);
    xlabel('Time (s)');
    ylabel('Length (mm)');

    box off;

end

%%
% Generate the trial files
%%

cd(releaseName);
cd(modelName);
cd(simulationName);

trialNumber = 0;
for indexExcitation=1:1:2

    switch indexExcitation
        case 1
            ex = exMax;
        case 2
            ex = exSubMax;
    end

    for indexDirection=1:1:2
        velSign = 0;
        switch indexDirection
            case 1
                velSign = -1;                
            case 2
                velSign = 1;                                
        end
        idxHL1997Offset=1;
        while rampDataHL1997(idxHL1997Offset).velocity*velSign < 0
            idxHL1997Offset=idxHL1997Offset+1;
        end


        %The first 5 come from HL1997
        for idx = idxHL1997Offset:1:(idxHL1997Offset+4)
            assert(rampDataHL1997(idx).velocity*velSign > 0);

            trialNumberStr = num2str(trialNumber);
            while(length(trialNumberStr)<2)
                trialNumberStr = ['0', trialNumberStr];
            end
            simName = ['force_velocity_',trialNumberStr];
            if(exist(simName)~=7)
                mkdir(simName);
            end
            cd(simName);            

            lceOpt = musclePropertiesHL1997.lceOpt;
            lceOptNOffset= musclePropertiesHL1997.lceNOffset;

            length0 = rampDataHL1997(idx).length(1,1)...
                         + lceOpt*lceOptNOffset;
            length1 = rampDataHL1997(idx).length(1,2)...
                         + lceOpt*lceOptNOffset;

            time0 = rampDataHL1997(idx).time(1,1);
            time1 = rampDataHL1997(idx).time(1,2);


            success = writeForceVelocityLSDYNAFile(...
                        [simName,'.k'], ex,...
                        length0,length1,lceOpt,...
                        time0,time1);

            trialNumber=trialNumber+1;
            cd ..;
        end
        
        %The next two trials are faster than HL1997
        for idx=1:1:2
            trialNumberStr = num2str(trialNumber);
            while(length(trialNumberStr)<2)
                trialNumberStr = ['0', trialNumberStr];
            end
            simName = ['force_velocity_',trialNumberStr];
            if(exist(simName)~=7)
                mkdir(simName);
            end
            cd(simName);  
    
            lceOpt = musclePropertiesHL1997.lceOpt;
            lceOptNOffset= musclePropertiesHL1997.lceNOffset;

            idxHL1997Ref = idxHL1997Offset+4;
            length0 = rampDataHL1997(idxHL1997Ref).length(1,1)...
                         + lceOpt*lceOptNOffset;
            length1 = rampDataHL1997(idxHL1997Ref).length(1,2)...
                         + lceOpt*lceOptNOffset;

            velocity = rampDataHL1997(idxHL1997Ref).velocity(1,1);
            velocity = velocity*(2^idx);
            time0 = 1.5;
            time1 = time0 + (length1-length0)/velocity;

            success = writeForceVelocityLSDYNAFile(...
                        [simName,'.k'], ex, ...
                        length0,length1,lceOpt,...
                        time0,time1);            
    
            trialNumber=trialNumber+1;
            cd ..;
        end
    end
    %%
    % Generate the isometric trial
    %%
    
    simName = '';
    if(abs(ex - exMax) < 1e-6)
        simName = 'isometric_max';
    else
        simName = 'isometric_sub_max';
    end
    if(exist(simName)~=7)
        mkdir(simName);
    end
    cd(simName);  
    
    lceOpt = musclePropertiesHL1997.lceOpt;
    lceOptNOffset= musclePropertiesHL1997.lceNOffset;
    
    idxHL1997Ref = idxHL1997Offset+4;
    length0 = lceOpt*lceOptNOffset;
    length1 = lceOpt*lceOptNOffset;
    
    velocity = 0;
    time0 = 1.5;
    time1 = time0+1;
    
    success = writeForceVelocityLSDYNAFile(...
                [simName,'.k'], ex, ...
                length0,length1,lceOpt,...
                time0,time1);            
    
    trialNumber=trialNumber+1;
    cd ..;    
end

