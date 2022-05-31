function uniformModelData = createUniformMuscleModelData(modelName, lsdynaMuscle,...
                                    optimalFiberLength, maxActiveIsometricForce, ...
                                    tendonSlackLength, pennationAngle)
%%
% 
%
%   @param modelName   : the name of the model (e.g. umat41 or umat43
%   @param lsdynaMuscle: the data stored in the model-specific text file
%   @param optimalFiberLength: the CE length at which the max. active force
%                               is developed
%   @param maxActiveIsometricForce: the maximum active isometric force
%   @param tendonSlackLength: the slack length of the tendon
%   @param pennationAngle: the pennation angle of the CE when it is
%                           developing its maximum isometric force.
%
%   @return uniformModelData a struct with the following fields
%
%   Notation conventions:
%   l     : length
%   f     : force
%   N     : 'normalized'. The CE length is normalized by lceOpt, the tendon by 
%          ltSlk. The CE force is normalized by fceOpt, the tendon by fceOpt
%   CE/ce : the contractile element: the part of the fiber that develops active 
%       force and can do net positive work.
%   PE/pe : the parallel element: the part of the fiber that is parallel to the
%       CE and cannot do not positive work.
%   T/t   : the tendon 
%   alpha : the pennation angle (radians)
%
%   Architectural Properties
%     lceOpt:   optimal fiber length (m)
%     fceOpt:   maximum active isometric force (N) of the contractile element
%     ltslk:    tendon slack length (m)
%     alphaOpt: the pennation angle of the CE at a length of lceOpt,
%                developing fceOpt
%   
%   Data series
%     time     : time (s)
%     exc      : excitation (0-1)
%     act      : activation (0-1)
%     lceN     : length of the CE normalized by lceOpt 
%     ltN      : length of the tendon normalized by ltslk
%     alpha    : the pennation angle of the CE (radians)
%     lceNDot  : length of the CE normalized by lceOpt 
%     ltNDot   : length of the tendon normalized by ltslk
%     alphaDot : the pennation angle of the CE (radians)
%     fceN     : the norm force developed by the CE
%     fpeN     : the norm force developed by the PE
%     fmtN     : the norm force applied by the musculotendon to its
%                attachment points (+ve is tension)
%
%%


uniformModelData = struct('lceOpt',optimalFiberLength,...
                          'fmtOpt',maxActiveIsometricForce,...
                          'ltSlk',tendonSlackLength,...
                          'alphaOpt',pennationAngle,...
                          'time',[],...
                          'exc',[],...
                          'act',[],...
                          'lp',[],'vp',[],...
                          'lceN',[],'ltN',[],'alpha',[],...
                          'lceNDot',[],'ltNDot',[],'alphaDot',[],...
                          'fceN',[],'fpeN',[],'fseN',[], 'dseN',[],...
                          'fmtN',[]);

switch modelName
    case 'umat41'
        indexMuscleTime         = lsdynaMuscle.indexTime;
        indexMuscleExcitation   = lsdynaMuscle.indexExcitation;
        indexMuscleActivation   = lsdynaMuscle.indexActivation; 
        indexMuscleFmt          = lsdynaMuscle.indexFmt;
        indexMuscleFce          = lsdynaMuscle.indexFce;
        indexMuscleFpee         = lsdynaMuscle.indexFpee;
        indexMuscleFsee         = lsdynaMuscle.indexFsee;
        indexMuscleFsde         = lsdynaMuscle.indexFsde;
        indexMuscleLmt          = lsdynaMuscle.indexLmt;
        indexMuscleLce          = lsdynaMuscle.indexLce;
        indexMuscleLmtDot       = lsdynaMuscle.indexLmtDot;
        indexMuscleLceDot       = lsdynaMuscle.indexLceDot;

        uniformModelData.time   = lsdynaMuscle.data(:,indexMuscleTime);
        uniformModelData.exc    = lsdynaMuscle.data(:,indexMuscleExcitation);
        uniformModelData.act    = lsdynaMuscle.data(:,indexMuscleActivation); 

        uniformModelData.lp = lsdynaMuscle.data(:,indexMuscleLmt);

        uniformModelData.vp = lsdynaMuscle.data(:,indexMuscleLmtDot);

        uniformModelData.lceN   = lsdynaMuscle.data(:,indexMuscleLce)...
                                    ./optimalFiberLength;

        uniformModelData.ltN    = (lsdynaMuscle.data(:,indexMuscleLmt) ...
                                  -lsdynaMuscle.data(:,indexMuscleLce))...
                                    ./tendonSlackLength;

        uniformModelData.alpha = zeros(size(uniformModelData.time));

        uniformModelData.lceNDot    = ...
            lsdynaMuscle.data(:,indexMuscleLceDot)./optimalFiberLength;

        uniformModelData.ltNDot     = (lsdynaMuscle.data(:,indexMuscleLmtDot) ...
                                      -lsdynaMuscle.data(:,indexMuscleLceDot))...
                                    ./tendonSlackLength;

        uniformModelData.alphaDot   = zeros(size(uniformModelData.time));

        uniformModelData.fceN = ...
            lsdynaMuscle.data(:,indexMuscleFce)./maxActiveIsometricForce;

        uniformModelData.fpeN = ...
            lsdynaMuscle.data(:,indexMuscleFpee)./maxActiveIsometricForce;

        uniformModelData.fseN = lsdynaMuscle.data(:,indexMuscleFsee)./maxActiveIsometricForce;

        uniformModelData.dseN = lsdynaMuscle.data(:,indexMuscleFsde)./maxActiveIsometricForce;


        uniformModelData.fmtN  = ...
            lsdynaMuscle.data(:,indexMuscleFmt)./maxActiveIsometricForce;

    case 'umat43'
        uniformModelData.time = lsdynaMuscle.data(:,lsdynaMuscle.indexTime);
        uniformModelData.exc  = lsdynaMuscle.data(:,lsdynaMuscle.indexExc);
        uniformModelData.act  = lsdynaMuscle.data(:,lsdynaMuscle.indexAct);
        
        uniformModelData.lp   = lsdynaMuscle.data(:,lsdynaMuscle.indexLp);
        uniformModelData.vp   = lsdynaMuscle.data(:,lsdynaMuscle.indexVp);


        uniformModelData.lceN       = lsdynaMuscle.data(:,lsdynaMuscle.indexLceN);
        uniformModelData.ltN        = lsdynaMuscle.data(:,lsdynaMuscle.indexLtN);
        uniformModelData.alpha      = lsdynaMuscle.data(:,lsdynaMuscle.indexAlpha);

        uniformModelData.lceNDot    = lsdynaMuscle.data(:,lsdynaMuscle.indexVceNN);
        uniformModelData.ltNDot     = lsdynaMuscle.data(:,lsdynaMuscle.indexVtN);
        uniformModelData.alphaDot   = lsdynaMuscle.data(:,lsdynaMuscle.indexAlphaDot);

        uniformModelData.fceN       = lsdynaMuscle.data(:,lsdynaMuscle.indexFceN);
        uniformModelData.fpeN       = lsdynaMuscle.data(:,lsdynaMuscle.indexFecmHN);
        uniformModelData.fseN       = lsdynaMuscle.data(:,lsdynaMuscle.indexFtfcnN);
        uniformModelData.dseN       = lsdynaMuscle.data(:,lsdynaMuscle.indexFtBetaN);        
        uniformModelData.fmtN       = lsdynaMuscle.data(:,lsdynaMuscle.indexFtN);

    otherwise
        assert(0,['modelName (',modelName,') is not yet coded'])

end