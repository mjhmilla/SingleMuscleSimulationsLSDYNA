%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function musclePropertiesKBR1994 = getKirsch1994MuscleProperties()

%Fitted to Herzog & Leonard 2002
fisoHL2002 = (21.612138);

%Fitted to Herzog & Leonard 2002
vmaxHL2002 = 4.684921; 

%Fitted to Herzog & Leonard 2002
lceOptHL2002 = 0.0428571;

musclePropertiesKBR1994.fiso       = fisoHL2002;
musclePropertiesKBR1994.lceOpt     = lceOptHL2002;
musclePropertiesKBR1994.lceNOffset = 0;
musclePropertiesKBR1994.vmax       = vmaxHL2002;