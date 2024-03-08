function musclePropertiesHL1997 = getHerzogLeonard1997MuscleProperties()

% Graphically measured from Herzog and Leonard 1997 Fig. 1A    
flNStart   = 0.9593; 
fisoHL1997 = (43.0392-3.073)/flNStart;

% Graphically measured from Figure 4 of Scott, Brown, Loeb
%Scott SH, Brown IE, Loeb GE. Mechanics of feline soleus: I. Effect of 
% fascicle length and velocity on force output. Journal of Muscle 
% Research & Cell Motility. 1996 Apr;17:207-19.
vmaxSBL1996 = 4.65; 

% Optimal fiber length from 
% Scott SH, Loeb GE. Mechanical properties of aponeurosis and tendon 
% of the cat soleus muscle during whole‐muscle isometric contractions. 
% Journal of Morphology. 1995 Apr;224(1):73-86.
lceOptHL1997 = 38.0/1000;

musclePropertiesHL1997.fiso         = fisoHL1997;
musclePropertiesHL1997.lceOpt       = lceOptHL1997;
musclePropertiesHL1997.lceNOffset   = 0.900-(4/1000)/lceOptHL1997;
musclePropertiesHL1997.vmax         = vmaxSBL1996;