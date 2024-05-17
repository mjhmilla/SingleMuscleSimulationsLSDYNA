clc;
close all;
clear all;

%Fit curves to data
expData='HL2002';
main_fitMuscles;
expData='HL1997';
main_fitMuscles;

%Numerically polish the starting lengths, and titin properties
clc;
close all;
clear all;
main_fitMusclesToHL2002Simulation;

%Run the simulations
clc;
close all;
clear all;

simulationMode=2;
main_simulateExperiments;

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