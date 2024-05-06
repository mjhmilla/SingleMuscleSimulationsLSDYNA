function modelParams = setArchitecturalParameters(modelParams,...
           dataHL1997Length,dataHL1997Force,dataHL2002KeyPoints)

lceOptScottLoeb1995  = 38/1000;
ltSlkScottLoeb1995   = 27/1000;
penOptDSacksLoeb1995 = 7;

lceOptHL2002 = (27/0.63)/1000; % From the text: pg 1277 paragraph 2;

% Sacks RD, Roy RR. Architecture of the hind limb muscles of cats: functional 
% significance. Journal of Morphology. 1982 Aug;173(2):185-95.
%
% Scott SH, Loeb GE. Mechanical properties of aponeurosis and tendon of the 
% cat soleus muscle during whole‐muscle isometric contractions. Journal of 
% Morphology. 1995 Apr;224(1):73-86.
%
% Herzog W, Leonard TR. Depression of cat soleus forces following 
% isokinetic shortening. Journal of biomechanics. 1997 Sep 1;30(9):865-72.
%
% Herzog W, Leonard TR. Force enhancement following stretching of skeletal 
% muscle: a new mechanism. Journal of Experimental Biology. 2002 
% May 1;205(9):1275-83.

switch expData
    case 'HL1997'

        %The optimal fiber length is not stated in Herzog & Leonard.
        %Here we take the largest active force as an estimate for the
        %optimal fiber force
       
        %longest ce length passive forces
        fpeOptATSeries = [];
        fmtOptATSeries = [];        
        for i=1:1:5
            timePassive = dataHL1997Length(i).x(1)+0.1;
            timeActive  = dataHL1997Length(i).x(2);
            fpe = interp1(dataHL1997Force(i).x,dataHL1997Force(i).y,...
                          timePassive);
            fmt = interp1(dataHL1997Force(i).x,dataHL1997Force(i).y,...
                          timeActive);
            fpeOptATSeries=[fpeOptATSeries;fpe];
            fmtOptATSeries=[fmtOptATSeries;fmt];            
        end

        arch.penOptD    = penOptDSacksLoeb1995;
        arch.penOpt     = arch.penOptD*(pi/180);
        
        %This ignores the small reduction in fpe that will occur 
        %due to the lengthening of the tendon. Since the tendon is 
        %short (27 mm) the amount of tendon strain (0.0458) is small
        %(1.2366 mm) in terms of the CE length (38 mm): around 3.25%        
        arch.fceOptAT   = mean(fmtOptATSeries)-mean(fpeOptATSeries);

        arch.fceOpt     = arch.fceOptAT/cos(arch.penOpt);
        arch.lceOpt     = lceOptScottLoeb1995;
        arch.ltSlk      = ltSlkScottLoeb1995;
        arch.fceOptAT   = arch.fceOpt*cos(arch.penOpt);
        arch.lceOptAT   = arch.lceOpt*cos(arch.penOpt);   
    case 'HL2002'
        %0mm passive forces
        fpeOptATSeries = ([dataHL2002KeyPoints(1:3,5);...
                   dataHL2002KeyPoints(10,5);...
                   dataHL2002KeyPoints(12:14,5)]);
        %0mm active forces
        fmtOptATSeries = ([dataHL2002KeyPoints(1:3,7);...
                   dataHL2002KeyPoints(10,7)]);

        %As before this ignores the small reduction in fpe ...
        fceOptAT = mean(fmtOptATSeries)-mean(fpeOptATSeries);

        arch.fceOptAT   = fceOptAT;
        arch.penOptD    = penOptDSacksLoeb1995;
        arch.penOpt     = arch.penOptD*(pi/180);
        arch.fceOpt     = arch.fceOptAT/cos(arch.penOpt);
        arch.lceOpt     = lceOptHL2002;
        arch.lceOptAT   = arch.lceOpt/cos(arch.penOpt);
        arch.ltSlk      = ...
            (ltSlkScottLoeb1995/lceOptScottLoeb1995)*lceOptHL2002;
        %Maintain the same tendon-to-ce length ratio as Scott & Loeb
end


%Not changed
params.mat156=mat156;
params.umat41=umat41;
params.umat43=umat43;

%These values will be updated during the fitting process
params.mat156Upd=mat156;
params.umat41Upd=umat41;
params.umat43Upd=umat43;

modelUpd = {'mat156Upd','umat41Upd','umat43Upd'};

%Update the architectural parameters of the updated model params
archParams = fields(arch);
for i=1:1:length(archParams)
    disp(['Difference ',archParams{i}]);
    disp(params.mat156Upd.(archParams{i})-arch.(archParams{i}));
    disp(params.umat41Upd.(archParams{i})-arch.(archParams{i}));
    disp(params.umat43Upd.(archParams{i})-arch.(archParams{i}));
    
    if(flag_zeroMAT156TendonSlackLength==1 && contains(archParams{i},'ltSlk')==0)
        params.mat156Upd.(archParams{i})=arch.(archParams{i});
        params.mat156Upd.('et')=0;
    end
    params.umat41Upd.(archParams{i})=arch.(archParams{i});
    params.umat43Upd.(archParams{i})=arch.(archParams{i});
end

for i=1:1:length(modelUpd)
    params.(modelUpd{i}).lmtOptAT = ...
        params.(modelUpd{i}).lceOptAT ... 
       +params.(modelUpd{i}).ltSlk;
end

here=1;