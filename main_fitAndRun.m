clc;
close all;
clear all;

flag_fit=0;

flag_runFal		=	1
flag_runHL1997	=	1;
flag_runHL2002	=	0;
flag_runKBR1994=	1;
%Fit curves to data

if(flag_fit==1)
	expData='HL2002';
	main_fitMuscles;
	expData='HL1997';
	main_fitMuscles;
end
%Numerically polish the starting lengths, and titin properties

if(flag_fit==1)
	clc;
	close all;
	clearvars -except flag_fit, flag_runFal, flag_runHL1997, flag
	main_fitMusclesToHL2002Simulation;
end


clc;
close all;
clear all;

simulationConfig.type='fal';
simulationConfig.mode='run';
main_simulateExperiments;




%Run the simulations
if(flag_runHL2002==1)
	clc;
	close all;
	clear all;

	simulationConfig.type='HL2002';
	simulationConfig.mode='run';
	main_simulateExperiments;
end
% clc;
% close all;
% clear all;
% 
% simulationMode=0;
% main_simulateExperiments;
% 
% clc;
% close all;
% clear all;
% 
% simulationMode=1;
% main_simulateExperiments;
% 
% clc;
% close all;
% clear all;
% 
% simulationMode=2;
% main_simulateExperiments;
% 
% clc;
% close all;
% clear all;
% 
% simulationMode=3;
% main_simulateExperiments;
