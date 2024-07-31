%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function dataHL1997 = getHerzogLeonard1997Keypoints()

dataHL1997.l    = [0.688979,0.9011];
dataHL1997.dl   = dataHL1997.l-0.688979;
dataHL1997.fpe  = [0.0237796,0.0760336];
dataHL1997.fa   = [0.770336,1.03486]-dataHL1997.fpe;
dataHL1997.dfa   = dataHL1997.fa-dataHL1997.fa(1,1);
dataHL1997.rectangle.fl =   [dataHL1997.dl(1,1),dataHL1997.fa(1,1);...
                             dataHL1997.dl(1,2),dataHL1997.fa(1,1);...
                             dataHL1997.dl(1,2),dataHL1997.fa(1,2);...
                             dataHL1997.dl(1,1),dataHL1997.fa(1,2);...
                             dataHL1997.dl(1,1),dataHL1997.fa(1,1)];
dataHL1997.rectangle.fpe =  [dataHL1997.dl(1,1),dataHL1997.fpe(1,1);...
                             dataHL1997.dl(1,2),dataHL1997.fpe(1,1);...
                             dataHL1997.dl(1,2),dataHL1997.fpe(1,2);...
                             dataHL1997.dl(1,1),dataHL1997.fpe(1,2);...
                  
                             dataHL1997.dl(1,1),dataHL1997.fpe(1,1)];

%The middle point. This is not included as a 3rd point in l, fpe, and fa
%because the passive value at this point is not recorded. I have
%estimated fpe using a model and subtracted it off from the digitized
%MT value to obtain 0.8930
dataHL1997.lMid     =0.792;
dataHL1997.faMid    =0.8930;
