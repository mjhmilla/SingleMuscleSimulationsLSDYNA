%% This script performs the validation tests isometric, concentric and quick release 
%% for different release version of the EHTMM

clear all;
close all;

%%
% User-defined script variables
%%

flag_runSimulationKleinbach     = 1;
flag_runPostprocessorKleinbach  = 0;

mainpath    = '/scratch/tmp/mmillard/SMP_R931/01_validationEHTMM';
addpath(mainpath);

binoutreaderPath='/home/itm/institut/tools/matlab/Apps/LS_Dyna/';
addpath(binoutreaderPath);

%% path to exp. reference
pathRef= fullfile(mainpath,'ReferenceExperiments/');

% Define which test shall be performed
validTypes  = {'eccentric'};%,'concentric','isometric','quickrelease'};

% Define which Releases shall be tested
Releases    =  {'SingleMuscleSimulations'};% Releases    = {'EHTM10','EHTM20'}; % Releases    = {'EHTM21'};

% Define if all all datapoints are used or only some of them?
deltaPoints  = 1; % every 2nd/3rd/...


%%
% Output Data Structure Layout
%%



%%
% Run each simulation and extract the desired output data
%%
for ReleaseID = 1:length(Releases)
    Release = cell2mat(Releases(ReleaseID));
    switch Release
        case 'Kleinbach2017'
            % define which solver version to use
            lsdynaBin = '/scratch/tmp/mmillard/SMP_R931/lsdyna';
%        case 'EHTM10'
%            lsdynaBin = '/space/fkempter_to_others/00_EHTM-Release/lsdyna-EHTM1.1-712/lsdyna';
%        case 'EHTM20'
%            lsdynaBin = '/space/fkempter_to_others/00_EHTM-Release/lsdyna-EHTM1.0-810/lsdyna';
            
        otherwise
            error('Release not specified yet')
    end
    mainpathEHTM = fullfile(mainpath,Release);
    
    
    for validTypeId = 1:length(validTypes)
        validType           = cell2mat(validTypes(validTypeId));
        mainpathEHTMValid   = fullfile(mainpathEHTM,validType);
        cd(mainpathEHTMValid);
        contValid           = dir;
        contValid           = contValid([contValid.isdir]==true);
        for idx=3:deltaPoints:length(contValid)
            cd(contValid(idx).name);
            
            %% generate output signals                        
            if(flag_runSimulationKleinbach==1)
                system('rm -f *.csv d3* matsum musout* messag* glstat nodout spcforc lspost*')
                if strcmp(validType,'concentric')
                    system( [lsdynaBin ' i=main.k']);
                else
                    system( [lsdynaBin ' i=' contValid(idx).name '.k']);
                end
            end
            
            if(flag_runPostprocessorKleinbach==1)
                system('lspp43 c=ausw.cfile -nographics');
            end
            
            %% import output signal
            data=[];
            switch validType
                case 'eccentric'
                    %signal = 'con_vel_nod2.csv';
                    [output, status] = binoutreader('dynaOutputFile','binout');
                    data  = [output.nodout.time',output.elout.beam.axial];                
                case 'isometric'
                    %signal = 'forc.csv';
                    [output, status] = binoutreader('dynaOutputFile','binout');
                    data  = [output.elout.beam.time',output.elout.beam.axial];
                case 'concentric'
                    %signal = 'con_vel_nod2.csv';
                    [output, status] = binoutreader('dynaOutputFile','binout');
                    data  = [output.nodout.time',output.nodout.z_velocity];
                case 'quickrelease'
                    %signal = 'quick_release_crossplot.csv';
                    [output, status] = binoutreader('dynaOutputFile','binout');
                    data  = [output.nodout.z_velocity,output.elout.beam.axial];
                otherwise
                    error('Check validation type - does not match any of them')
            end
            
            %dataHlp = importdata(signal);
            Validation.(Release).(validType)(idx-2).data = data;%dataHlp.data;
            Validation.(Release).(validType)(idx-2).name = contValid(idx).name;            
            
            %Validation.(Release).(validType)(idx-2).data = data;
            %Validation.(Release).(validType)(idx-2).name = contValid(idx).name;
                                   
            cd(mainpathEHTMValid);
        end
    end
end

%% PostProcessing 

validTypes = fieldnames(Validation.(Release));
for validId = 1:length( validTypes)
    validType = cell2mat(validTypes(validId));
    figure(validId);
    hold on;
    clear h;
    for dataPoints = 1:deltaPoints:length(Validation.(Release).(validType)) % only every 2nd point
        dataSet = Validation.(Release).(validType)(dataPoints);
        switch(validType)
            case 'eccentric'
                x = dataSet.data(find(dataSet.data(:,1), 1 )-1:end,1);
                y = dataSet.data(find(dataSet.data(:,1), 1 )-1:end,2);
                h(dataPoints)= ...
                    plot(x,y,...
                        'DisplayName',dataSet.name);
                %axis([0 12 0 35]);
                set(gca,'XTick',[1:1:12])
                ylabel('Force (N)','interpreter','latex'); 
                xlabel('Time (s)','interpreter','latex');
            case 'quickrelease'
                x = dataSet.data(find(dataSet.data(:,1), 1 )-1:end,1);
                y = dataSet.data(find(dataSet.data(:,1), 1 )-1:end,2);
                h(dataPoints)= ...
                    plot(x,y,...
                        'DisplayName',dataSet.name);
                axis([0 0.5 0 30]);
                set(gca,'XTick',0:0.10:0.5)
                ylabel('muscle force in N','interpreter','latex'); 
                xlabel('contraction velocity in $\frac{m}{s}$','interpreter','latex');
                        
            case 'concentric'
                % starttime = time of lift-off
                %dataSet.data      = dataSet.data((dataSet.data(:,2)~=0),:);
                %dataSet.data(:,1) = dataSet.data(:,1)-dataSet.data(1,1);
                indexStart = find(dataSet.data(:,2) > 0,1)-1;
                x = dataSet.data(indexStart:end,1)-dataSet.data(indexStart,1);
                y = dataSet.data(indexStart:end,2);
                
                h(dataPoints)=...
                    plot(   x,y,...
                            'DisplayName',dataSet.name);
                set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
                set(groot, 'defaultLegendInterpreter','latex');
                grid on
                axis([0 0.2 0 0.12]);
                set(gca,'XTick',0:0.05:0.2)
                set(gca,'YTick',0:0.02:0.12)
                ylabel('velocity in $\frac{m}{s}$','interpreter','latex'); 
                xlabel('time in s','interpreter','latex');
                
            case 'isometric'
                
                h(dataPoints)=...
                    plot(   dataSet.data(:,1),...
                            dataSet.data(:,2),...
                            'DisplayName',dataSet.name);
                        
                set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
                set(groot, 'defaultLegendInterpreter','latex');
                grid on
                axis([0 1.5 0 40]);
                set(gca,'XTick',0:0.2:1.5)
                set(gca,'YTick',0:10:40)
                ylabel('muscle force in N','interpreter','latex'); 
                xlabel('time in s','interpreter','latex');
                
            otherwise
                error('Plot error: validation type does not match ')
        end
        
    end

    %% Reference
    contRef = dir(fullfile(pathRef,validType,'*.dat'));
    for refId = 1:deltaPoints:length(contRef) %only every 2nd point
        refData = importdata(fullfile(contRef(refId).folder,contRef(refId).name));
        plot(refData.data(:,1),refData.data(:,2),'--k','DisplayName',['Ref' contRef(refId).name]);
    end
    %legend([h])
    
end

rmpath(mainpath);
rmpath(binoutreaderPath);
