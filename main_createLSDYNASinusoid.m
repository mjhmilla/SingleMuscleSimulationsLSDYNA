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


npts = 100;


fid = fopen('output/curves/sinusoid_curve.k','w');

fprintf(fid,'*DEFINE_CURVE\n');
fprintf(fid,'$#    lcid      sidr       sfa       sfo      offa      offo    dattyp\n');
fprintf(fid,'         %i         0       1.0       1.0       0.0       0.0\n',...
            lcid);
fprintf(fid,'$#                a1                  o1\n');

% Padding
tpad = [tmin;tstart];
lpad = [0;0];
for idxPad=1:1:2
    tstr = sprintf('%1.6f',tpad(idxPad,1));
    assert(length(tstr) < 20);
    n = length(tstr);
    for i=n:1:18
        tstr = [' ',tstr];
    end
    
    lstr = sprintf('%1.6f*%s+%s',lpad(idxPad,1),varAmp,varBias);
    assert(length(lstr) < 20);
    n = length(lstr);
    for i=n:1:18
        lstr = [' ',lstr];
    end
    
    fprintf(fid,' %s %s\n',tstr,lstr);
end

%Sinusoid A
for i=1:1:npts
    t = tstart + (i/(npts))*(tend-tstart);
    tstr = sprintf('%1.6f',t);
    assert(length(tstr) < 20);
    n = length(tstr);
    for i=n:1:18
        tstr = [' ',tstr];
    end
    
    l = sin(t*2*pi*freqHz);
    lstr = sprintf('%1.6f*%s+%s',l,varAmp,varBias);
    assert(length(lstr) < 20);
    n = length(lstr);
    for i=n:1:18
        lstr = [' ',lstr];
    end  
    line=sprintf(' %s %s\n',tstr,lstr);
    fprintf(fid,' %s %s\n',tstr,lstr);
end

% Padding
tpad = [(tend+0.001);tmax];
lpad = [0;0];
for idxPad=1:1:2
    tstr = sprintf('%1.6f',tpad(idxPad,1));
    assert(length(tstr) < 20);
    n = length(tstr);
    for i=n:1:18
        tstr = [' ',tstr];
    end
    
    lstr = sprintf('%1.6f*%s+%s',lpad(idxPad,1),varAmp,varBias);
    assert(length(lstr) < 20);
    n = length(lstr);
    for i=n:1:18
        lstr = [' ',lstr];
    end
    
    fprintf(fid,' %s %s\n',tstr,lstr);
end

fclose(fid);
