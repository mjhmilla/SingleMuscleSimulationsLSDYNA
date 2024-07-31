%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function keyPointsHL1997 = getHerzogLeonard1997KeyPoints(...
    matlabScriptPath,refExperimentFolder,flag_plotAnnotationData)


fileHL1997Length = [matlabScriptPath,filesep,...
                   refExperimentFolder,filesep,...
                   'force_velocity',filesep,...
                   'fig_HerzogLeonard1997Fig1A_length.csv'];

fileHL1997Force = [matlabScriptPath,filesep,...
                   refExperimentFolder,filesep,...
                   'force_velocity',filesep,...
                   'fig_HerzogLeonard1997Fig1A_forces.csv'];

dataHL1997Length = loadDigitizedData(fileHL1997Length,...
                'Time ($$s$$)','Length ($$mm$$)',...
                {'c01','c02','c03','c04','c05',...
                 'c06','c07','c08','c09','c10','c11'},...
                {'Herzog and Leonard 1997'}); 

dataHL1997Force = loadDigitizedData(fileHL1997Force,...
                'Time ($$s$$)','Force ($$N$$)',...
                {'c01','c02','c03','c04','c05',...
                 'c06','c07','c08','c09','c10','c11'},...
                {'Herzog and Leonard 1997'}); 


% The optimal fiber length and maximum isometric force are not reported
% in the paper. In the paper the force at a length of 0 corresponds to
% the length of the muscle when the cat's ankle is at an 80 degree angle.
% 
%keyPointsHL1997.fceOptAT = 0;
%keyPointsHL1997.lceOptAT = 0;




%Raw data
fpeSeries       = struct('l',[],'f',[]);
flIsoSeries    = struct('l',[],'fpe',[],'fmt',[]);
fmtVelSeries    = struct('v',[],'fmt',[],'l',[]);

%11 is isometric (around 37 N)
fmtMid  = dataHL1997Force(11).y(1);

forceASet=[];
for i=6:1:10
    forceASet=[forceASet; dataHL1997Force(i).y(1)];
end
forceBSet=[];
for i=1:1:5
    forceBSet=[forceBSet; dataHL1997Force(i).y(1)];
end

forceA  =  mean(forceASet); 
forceB  =  mean(forceBSet); 
fpeMid  = interp1([-4;4],[forceA;forceB],0);
fpeMid  = forceA + 0.5*(fpeMid-forceA); %To make the curve slightly concave up
fisoMid = fmtMid-fpeMid;

%1-5 is shortening;
for i=1:1:10

    timeFpe = dataHL1997Length(i).x(1);
    fpe     = dataHL1997Force(i).y(1);
    lpe     = dataHL1997Length(i).y(1);

    fpeSeries.l   = [fpeSeries.l; lpe];
    fpeSeries.f   = [fpeSeries.f; dataHL1997Force(i).y(1)];

    timeIso   = dataHL1997Length(i).x(2);
    lengthIso = dataHL1997Length(i).y(2);

    fmtIsoInterp = interp1(dataHL1997Force(i).x, ...
                             dataHL1997Force(i).y,...
                             timeIso);
    %Make sure we are using an annotated data point: I digitized the peak
    %of the isometric force.
    [errF, idxIso] = min(abs(dataHL1997Force(i).y-fmtIsoInterp));
    fmtIso = dataHL1997Force(i).y(idxIso);
    timeIso= dataHL1997Force(i).x(idxIso);
    fl = fmtIso-fpe;

%     if(i==1)
%         fprintf('getHerzogLeonard1997KeyPoints\n');
%         fprintf('\t\tfl=fmt-fpe is an approximation because fmt and fpe\n')
%         fprintf('\t\thave different CE lengths because the tendon is \n')
%         fprintf('\t\tunder different loads, but the musculotendon has \n')
%         fprintf('\t\tthe same length\n');
%     end

    flIsoSeries.l   = [flIsoSeries.l; lengthIso];
    flIsoSeries.fpe   = [flIsoSeries.fpe; fpe];
    flIsoSeries.fmt = [flIsoSeries.fmt; fmtIso];

    timeVel   = dataHL1997Length(i).x(3);
    lengthVel = dataHL1997Length(i).y(3);

    forceVelInterp = interp1(dataHL1997Force(i).x, ...
                             dataHL1997Force(i).y,...
                             timeVel);
    
    %Make sure we are using an annotated data point: I digitized the peak
    %of the isometric force.
    [errF, idxVel] = min(abs(dataHL1997Force(i).y-forceVelInterp));
    fmtVel  = dataHL1997Force(i).y(idxVel);
    timeVel = dataHL1997Force(i).x(idxVel);
    %This is a simplified calculation of fv that works only for
    %short tendons that do not strain much relative to the contractile 
    %element. Lucky for us the cat soleus has a short tendon (27 mm)
    %relative to the contractile element length (38 mm)
    %fv = (fmtVel-fpe)/fisoMid;

    dl = dataHL1997Length(i).y(3)-dataHL1997Length(i).y(2);
    dt = dataHL1997Length(i).x(3)-dataHL1997Length(i).x(2);
    v  = dl/dt;

    lend = dataHL1997Length(i).y(end);

    fmtVelSeries.l     = [fmtVelSeries.l;lend];
    fmtVelSeries.v     = [fmtVelSeries.v;v];
    fmtVelSeries.fmt   = [fmtVelSeries.fmt;fmtVel];

    if(flag_plotAnnotationData==1)
        if(i==1)
            figHL1997 = figure;
        else
            figure(figHL1997);
        end

        subplot(3,4,i);
        
        yyaxis left;
            plot(dataHL1997Force(i).x,dataHL1997Force(i).y, ...
                '-','Color',[1,0.5,0.5]);
            hold on;
            plot(timeFpe, fpe,'xr');
            hold on;
            plot(timeIso, fmtIso,'og');
            hold on;
            plot(timeVel, fmtVel,'sb');
            hold on;
            
            box off;
    
            xlabel('Time (s)');
            ylabel('Force (N)');             

        yyaxis right;
            plot(dataHL1997Length(i).x,dataHL1997Length(i).y, ...
                '-','Color',[0.5,0.5,1]);
            hold on;
            plot(timeFpe,lpe ,'xr');
            hold on;
            plot(timeIso, lengthIso,'og');
            hold on;
            plot(timeVel, lengthVel,'sb');
            hold on;

            box off;

            ylim([-4.5,16]);

        title(['Fig.1A HL1997: ',sprintf('%1.1f mm/s',v)]);
        ylabel('Length (mm)');        

    end    
end


idxShortening=[1:5];
idxLengthening=[6:10];

keyPointsHL1997.units.l='m';
keyPointsHL1997.units.v='m/s';
keyPointsHL1997.units.f='N';
keyPointsHL1997.units.t='seconds';

%Scaling to bring the units to Newton, meter, second
mm2m=0.001;

%Passive force length
keyPointsHL1997.fpe.l = [fpeSeries.l(idxShortening);...
                         fpeSeries.l(idxLengthening)].*mm2m;

keyPointsHL1997.fpe.fmt=[fpeSeries.f(idxShortening);...
                         fpeSeries.f(idxLengthening)];

[lengthOrdered, indexOrdered] = sort(keyPointsHL1997.fpe.l);
keyPointsHL1997.fpe.l = keyPointsHL1997.fpe.l(indexOrdered);
keyPointsHL1997.fpe.fmt = keyPointsHL1997.fpe.fmt(indexOrdered);
keyPointsHL1997.fpe.clusters=2;
%Active force length
keyPointsHL1997.fl.l = [flIsoSeries.l(idxShortening);...
                        flIsoSeries.l(idxLengthening)].*mm2m;

keyPointsHL1997.fl.fpe = [flIsoSeries.fpe(idxShortening);...
                          flIsoSeries.fpe(idxLengthening)];

keyPointsHL1997.fl.fmt = [flIsoSeries.fmt(idxShortening);...
                          flIsoSeries.fmt(idxLengthening)];
keyPointsHL1997.fl.clusters=2;

[lengthOrdered, indexOrdered] = sort(keyPointsHL1997.fl.l);
keyPointsHL1997.fl.l = keyPointsHL1997.fl.l(indexOrdered);
keyPointsHL1997.fl.fpe = keyPointsHL1997.fl.fpe(indexOrdered);
keyPointsHL1997.fl.fmt= keyPointsHL1997.fl.fmt(indexOrdered);


%Force velocity
[vSorted, idxSorted] = sort(fmtVelSeries.v);

keyPointsHL1997.fv.l   = fmtVelSeries.l(idxSorted).*mm2m;
keyPointsHL1997.fv.v   = fmtVelSeries.v(idxSorted).*mm2m;
keyPointsHL1997.fv.fmt = fmtVelSeries.fmt(idxSorted);
keyPointsHL1997.fv.fmtMid=fisoMid;
keyPointsHL1997.fv.clusters=length(fmtVelSeries.l(idxSorted));

if(flag_plotAnnotationData==1)
    figDebug=figure;
    subplot(1,3,1);
        plot(keyPointsHL1997.fpe.l,keyPointsHL1997.fpe.fmt,'ok');
        hold on;
        xlabel('Length (m)');
        ylabel('Force (N)');
        box off;
        title('Passive force-length relation')
    subplot(1,3,2);
        plot(keyPointsHL1997.fl.l,keyPointsHL1997.fl.fmt,'or');
        hold on;
        plot(keyPointsHL1997.fl.l,keyPointsHL1997.fl.fpe,'xk');
        hold on;
        xlabel('Length (m)');
        ylabel('Force (N)');
        box off;
        title('Active force-length relation');
    subplot(1,3,3);
        plot(keyPointsHL1997.fv.v,keyPointsHL1997.fv.fmt,'ok');
        hold on;
        xlabel('Velocity (m/s)');
        ylabel('Force (N)');
        box off;
        title('Active force-length relation');
        
    here=1;
end

