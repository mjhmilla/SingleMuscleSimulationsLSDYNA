%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
clc;
close all;
clear all;


lcid = 4;

period  = 1;
freqHz  = 10;

tmin    = 0.0; 
tstart  = 0.5;
tend    = tstart+period/freqHz;
tmax    = tend+0.5;

varBias = '&b';
varAmp  = '&a';
varTimePad = '&tp';
varTimeSine= '&ts';

npts = 100;


fid = fopen('output/curves/sinusoid_curve.k','w');

fprintf(fid,'*DEFINE_CURVE\n');
fprintf(fid,'$#    lcid      sidr       sfa       sfo      offa      offo    dattyp\n');
fprintf(fid,'         %i         0       1.0       1.0       0.0       0.0\n',...
            lcid);
fprintf(fid,'$#                a1                  o1\n');

% Padding
tpad = [0;1];
lpad = [0;0];
for idxPad=1:1:2
    tstr = sprintf('%s*%1.6f',varTimePad,tpad(idxPad,1));
    assert(length(tstr) < 20);
    n = length(tstr);
    for i=n:1:18
        tstr = [' ',tstr];
    end
    
    lstr = sprintf('%s*%1.6f+%s',varAmp,lpad(idxPad,1),varBias);
    assert(length(lstr) < 20);
    n = length(lstr);
    for i=n:1:18
        lstr = [' ',lstr];
    end
    
    fprintf(fid,' %s %s\n',tstr,lstr);
end

%Sinusoid A
for i=1:1:npts
    tn = i/npts;
    
    tstr = sprintf('%s*%1.6f+%s',varTimeSine,tn,varTimePad);
    assert(length(tstr) < 20);
    n = length(tstr);
    for i=n:1:18
        tstr = [' ',tstr];
    end
    
    
    l = cos(2*pi*tn)-1;
    lstr = sprintf('%s*%1.6f+%s',varAmp,l,varBias);
    assert(length(lstr) < 20);
    n = length(lstr);
    for i=n:1:18
        lstr = [' ',lstr];
    end  
    line=sprintf(' %s %s\n',tstr,lstr);
    fprintf(fid,' %s %s\n',tstr,lstr);
end

% Padding
tpad = [1.01;2];
lpad = [0;0];
for idxPad=1:1:2
    tstr = sprintf('%s+%s*%1.4f',varTimeSine,varTimePad,tpad(idxPad,1));
    assert(length(tstr) < 20);
    n = length(tstr);
    for i=n:1:18
        tstr = [' ',tstr];
    end
    
    lstr = sprintf('%s*%1.6f+%s',varAmp,lpad(idxPad,1),varBias);
    assert(length(lstr) < 20);
    n = length(lstr);
    for i=n:1:18
        lstr = [' ',lstr];
    end
    
    fprintf(fid,' %s %s\n',tstr,lstr);
end

fclose(fid);
