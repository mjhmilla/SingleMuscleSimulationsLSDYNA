function modelParams = setArchitecturalParameters(modelParams,...
           expData,keyPointsHL1997,keyPointsHL2002,...
           flag_zeroMAT156TendonSlackLength)

mm2m=0.001;

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


        arch.penOptD    = penOptDSacksLoeb1995;
        arch.penOpt     = arch.penOptD*(pi/180);
        
        %The optimal fiber length is not stated in Herzog & Leonard.
        %Here we take the largest active force as an estimate for the
        %optimal fiber force     
        arch.fceOptAT   = max(keyPointsHL1997.fl.fmt...
                             -keyPointsHL1997.fl.fpe);
        arch.fceOpt     = arch.fceOptAT/cos(arch.penOpt);

        %The optimal fiber length is not measured nor stated in HL1997
        arch.lceOpt     = lceOptScottLoeb1995;
        arch.ltSlk      = ltSlkScottLoeb1995;
        arch.fceOptAT   = arch.fceOpt*cos(arch.penOpt);
        arch.lceOptAT   = arch.lceOpt*cos(arch.penOpt);   

    case 'HL2002'
        arch.penOptD    = penOptDSacksLoeb1995;
        arch.penOpt     = arch.penOptD*(pi/180);

        [fceOptAT, idxFceOptAT] = max(keyPointsHL2002.fl.fmt...
                                     -keyPointsHL2002.fl.fpe);
        arch.fceOptAT   = fceOptAT;
        arch.fceOpt     = arch.fceOptAT/cos(arch.penOpt);
        arch.lceOptAT   = lceOptHL2002 + keyPointsHL2002.fl.l(idxFceOptAT)*mm2m;
        arch.lceOpt     = arch.lceOptAT/cos(arch.penOpt);
        arch.ltSlk      = ...
            (ltSlkScottLoeb1995/lceOptScottLoeb1995)*lceOptHL2002;
        %Maintain the same tendon-to-ce length ratio as Scott & Loeb
end


modelUpd = {'mat156Upd','umat41Upd','umat43Upd'};

%Update the architectural parameters of the updated model params
archParams = fields(arch);
disp('setArchitecturalParameters')
for i=1:1:length(archParams)
    fprintf('\tDifference %s\n',archParams{i});
    if(flag_zeroMAT156TendonSlackLength==1 && contains(archParams{i},'ltSlk')==1)
        fprintf('\t\t%s\t%1.3e\n','mat156',...
                modelParams.mat156Upd.(archParams{i})-0);
    else
        fprintf('\t\t%s\t%1.3e\n','mat156',...
                modelParams.mat156Upd.(archParams{i})-arch.(archParams{i}));        
    end

    fprintf('\t\t%s\t%1.3e\n','umat41',...
        modelParams.umat41Upd.(archParams{i})-arch.(archParams{i}));
    fprintf('\t\t%s\t%1.3e\n','umat43',...
        modelParams.umat43Upd.(archParams{i})-arch.(archParams{i}));
    
    if(flag_zeroMAT156TendonSlackLength==1 && contains(archParams{i},'ltSlk')==1)
        modelParams.mat156Upd.(archParams{i})=0;
        modelParams.mat156Upd.('et')=0;
    end
    modelParams.umat41Upd.(archParams{i})=arch.(archParams{i});
    modelParams.umat43Upd.(archParams{i})=arch.(archParams{i});
end

for i=1:1:length(modelUpd)
    modelParams.(modelUpd{i}).lmtOptAT = ...
        modelParams.(modelUpd{i}).lceOptAT ... 
       +modelParams.(modelUpd{i}).ltSlk;
end

here=1;