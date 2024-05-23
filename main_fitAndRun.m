clc;
close all;
clear all;

fitFlags= [0;0;0];
%1 HL2002 - curve fit
%2 HL1997 - curve fit
%3 HL2002 - run time fit

runFlags = [1;1;0;1];
simMode = 'run';
% 1. force-length run
% 2. HL1997 simulate
% 3. HL2002 simulate
% 4. KBR1994 simulate


for idx = 1:1:length(fitFlags)
    flagValue = fitFlags(idx);
    if(flagValue ==1)
        clc;
        close all;
        clearvars -except idx fitFlags flagValue runFlags simMode

        switch idx
            case 1
	            expData='HL2002';
	            main_fitMuscles;
            case 2
	            expData='HL1997';
	            main_fitMuscles;                
 
            case 3
                flag_fitInitialLength  = 0; 
                flag_fitTitinProperties= 1;                
        	    main_fitMusclesToHL2002Simulation;
            otherwise
                assert(0,'Error: index of the figFlags is larger than 3');
        end
        pause(0.1);
    end
end


for idx = 1:1:length(runFlags)
    runValue = runFlags(idx);
    if(runValue ==1)
        clc;
        close all;
        clearvars -except idx fitFlags flagValue runFlags runValue simMode

        switch idx
            case 1
                simulationConfig.type='fal';
                simulationConfig.mode=simMode;
                main_simulateExperiments;
            case 2
                simulationConfig.type='HL1997';
                simulationConfig.mode=simMode;
                main_simulateExperiments;               
            case 3
                simulationConfig.type='HL2002';
                simulationConfig.mode=simMode;
                main_simulateExperiments;               
            case 4
                simulationConfig.type='KBR1994';
                simulationConfig.mode=simMode;
                main_simulateExperiments;               

            otherwise
                assert(0,'Error: index of the runFlags is larger than 4');
        end
        pause(0.1);

    end
end


