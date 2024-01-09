function uniformModelData = createUniformMuscleModelData(...
        modelName, lsdynaMusout, lsdynaBinout,d3hspFileName,...
        optimalFiberLength, maxActiveIsometricForce, ...
        tendonSlackLength, pennationAngle, simulationTypeStr)
%%
% 
%
%   @param modelName   : the name of the model (e.g. umat41 or umat43
%   @param lsdynaMusout: the data stored in the model-specific text file
%   @param optimalFiberLength: the CE length at which the max. active force
%                               is developed
%   @param maxActiveIsometricForce: the maximum active isometric force
%   @param tendonSlackLength: the slack length of the tendon
%   @param pennationAngle: the pennation angle of the CE when it is
%                           developing its maximum isometric force.
%   @param simulationTypeStr: the string that defines the type of the
%   simulation. This is used to go into 'ReferenceCurves' and go load the
%   appropriate curves into the struct for later use in postprocessing
%   routines, particularly the specialized publication plotting routines.
%
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
                          'lceATN',[],...
                          'lceN',[],'ltN',[],'alpha',[],...
                          'lceNDot',[],'ltNDot',[],'alphaDot',[],...
                          'fceN',[],'fpeN',[],'fseN',[], 'dseN',[],...
                          'fmtN',[],...
                          'eloutTime',[],'eloutAxialBeamForceNorm',[],...
                          'name','',...
                          'nameLabel','',...
                          'authorship','',...
                          'authorshipShort','',...
                          'marker','');

switch modelName
    case 'umat41'
        indexMuscleTime         = lsdynaMusout.indexTime;
        indexMuscleExcitation   = lsdynaMusout.indexExcitation;
        indexMuscleActivation   = lsdynaMusout.indexActivation; 
        indexMuscleFmt          = lsdynaMusout.indexFmt;
        indexMuscleFce          = lsdynaMusout.indexFce;
        indexMuscleFpee         = lsdynaMusout.indexFpee;
        indexMuscleFsee         = lsdynaMusout.indexFsee;
        indexMuscleFsde         = lsdynaMusout.indexFsde;
        indexMuscleLmt          = lsdynaMusout.indexLmt;
        indexMuscleLce          = lsdynaMusout.indexLce;
        indexMuscleLceATN       = lsdynaMusout.indexLce; %umat41 has no pennation model
        indexMuscleLmtDot       = lsdynaMusout.indexLmtDot;
        indexMuscleLceDot       = lsdynaMusout.indexLceDot;

        uniformModelData.time   = lsdynaMusout.data(:,indexMuscleTime);
        uniformModelData.exc    = lsdynaMusout.data(:,indexMuscleExcitation);
        uniformModelData.act    = lsdynaMusout.data(:,indexMuscleActivation); 

        uniformModelData.lp = lsdynaMusout.data(:,indexMuscleLmt);

        uniformModelData.vp = lsdynaMusout.data(:,indexMuscleLmtDot);

        uniformModelData.lceN   = lsdynaMusout.data(:,indexMuscleLce)...
                                    ./optimalFiberLength;
        uniformModelData.lceATN = uniformModelData.lceN;

        uniformModelData.ltN    = (lsdynaMusout.data(:,indexMuscleLmt) ...
                                  -lsdynaMusout.data(:,indexMuscleLce))...
                                    ./tendonSlackLength;

        uniformModelData.alpha = zeros(size(uniformModelData.time));

        uniformModelData.lceNDot    = ...
            lsdynaMusout.data(:,indexMuscleLceDot)./optimalFiberLength;

        uniformModelData.ltNDot     = (lsdynaMusout.data(:,indexMuscleLmtDot) ...
                                      -lsdynaMusout.data(:,indexMuscleLceDot))...
                                    ./tendonSlackLength;

        uniformModelData.alphaDot   = zeros(size(uniformModelData.time));

        uniformModelData.fceN = ...
            lsdynaMusout.data(:,indexMuscleFce)./maxActiveIsometricForce;

        uniformModelData.fpeN = ...
            lsdynaMusout.data(:,indexMuscleFpee)./maxActiveIsometricForce;

        uniformModelData.fseN = lsdynaMusout.data(:,indexMuscleFsee)./maxActiveIsometricForce;

        uniformModelData.dseN = lsdynaMusout.data(:,indexMuscleFsde)./maxActiveIsometricForce;


        uniformModelData.fmtN  = ...
            lsdynaMusout.data(:,indexMuscleFmt)./maxActiveIsometricForce;


        uniformModelData.eloutTime           = lsdynaBinout.elout.beam.time';
        uniformModelData.eloutAxialBeamForceNorm = ...
          lsdynaBinout.elout.beam.axial ./ maxActiveIsometricForce;

        uniformModelData.name       = modelName;
        uniformModelData.nameLabel  = 'EHTMM';
        uniformModelData.authorship = 'Kleinbach et al. (2017)';
        uniformModelData.authorshipShort = 'Kleinbach (2017)';
        uniformModelData.mark = 's';
        
    case 'umat43'
        uniformModelData.time = lsdynaMusout.data(:,lsdynaMusout.indexTime);
        uniformModelData.exc  = lsdynaMusout.data(:,lsdynaMusout.indexExc);
        uniformModelData.act  = lsdynaMusout.data(:,lsdynaMusout.indexAct);
        
        uniformModelData.lp   = lsdynaMusout.data(:,lsdynaMusout.indexLp);
        uniformModelData.vp   = lsdynaMusout.data(:,lsdynaMusout.indexVp);


        uniformModelData.lceN       = lsdynaMusout.data(:,lsdynaMusout.indexLceN);
        uniformModelData.lceATN     = lsdynaMusout.data(:,lsdynaMusout.indexLceATN);
        uniformModelData.ltN        = lsdynaMusout.data(:,lsdynaMusout.indexLtN);
        uniformModelData.alpha      = lsdynaMusout.data(:,lsdynaMusout.indexAlpha);

        uniformModelData.lceNDot    = lsdynaMusout.data(:,lsdynaMusout.indexVceNN);
        uniformModelData.ltNDot     = lsdynaMusout.data(:,lsdynaMusout.indexVtN);
        uniformModelData.alphaDot   = lsdynaMusout.data(:,lsdynaMusout.indexAlphaDot);

        uniformModelData.fceN       = lsdynaMusout.data(:,lsdynaMusout.indexFceN);
        uniformModelData.fpeN       = lsdynaMusout.data(:,lsdynaMusout.indexFecmHN);
        uniformModelData.fseN       = lsdynaMusout.data(:,lsdynaMusout.indexFtN);
        uniformModelData.dseN       = lsdynaMusout.data(:,lsdynaMusout.indexFtBetaN);        
        uniformModelData.fmtN       = lsdynaMusout.data(:,lsdynaMusout.indexFtN);

        uniformModelData.eloutTime           = lsdynaBinout.elout.beam.time';
        uniformModelData.eloutAxialBeamForceNorm = ...
          lsdynaBinout.elout.beam.axial ./ maxActiveIsometricForce;

        uniformModelData.name               = modelName;
        uniformModelData.nameLabel          = 'VEXAT';
        uniformModelData.authorship         = 'Millard et al. (2023)';
        uniformModelData.authorshipShort    = 'Millard (2023)';
        uniformModelData.mark = 'o';


        

    case 'mat156'

        disp(' update mat156 createUniformMuscleModelData to somehow read u, a, fpe, dpe')
        uniformModelData.time = lsdynaBinout.elout.beam.time';
        uniformModelData.exc  = ones(size(uniformModelData.time)).*nan;
        uniformModelData.act  = ones(size(uniformModelData.time)).*nan;

        if(strcmp(simulationTypeStr,'eccentric'))
            stimTimeS = getParameterValueFromD3HSPFile(d3hspFileName,'STIMTIMES');
            stimTimeE = getParameterValueFromD3HSPFile(d3hspFileName,'STIMTIMEE');
            stimLow =  getParameterValueFromD3HSPFile(d3hspFileName,'STIMLOW');
            stimHigh =  getParameterValueFromD3HSPFile(d3hspFileName,'STIMHIGH');

            uniformModelData.act = ones(size(uniformModelData.time)).*stimLow;
            uniformModelData.act( uniformModelData.time >= stimTimeS ...
                                & uniformModelData.time <= stimTimeE) = stimHigh;
        end

        uniformModelData.lp     = -lsdynaBinout.nodout.z_coordinate;
        uniformModelData.vp     = -lsdynaBinout.nodout.z_velocity;
        
        uniformModelData.lceN   = uniformModelData.lp./optimalFiberLength;
        uniformModelData.lceATN = uniformModelData.lceN; 
        uniformModelData.ltN    = zeros(size(uniformModelData.time));
        uniformModelData.alpha  = zeros(size(uniformModelData.time));

        uniformModelData.lceNDot    = uniformModelData.vp./optimalFiberLength;
        uniformModelData.ltNDot     = zeros(size(uniformModelData.time));
        uniformModelData.alphaDot   = zeros(size(uniformModelData.time));

        uniformModelData.fceN       = lsdynaBinout.elout.beam.axial ./ maxActiveIsometricForce;
        uniformModelData.fpeN       = zeros(size(uniformModelData.time));
        uniformModelData.fseN       = zeros(size(uniformModelData.time));
        uniformModelData.dseN       = zeros(size(uniformModelData.time));        
        uniformModelData.fmtN       = uniformModelData.fceN;       

        uniformModelData.eloutTime           = lsdynaBinout.elout.beam.time';
        uniformModelData.eloutAxialBeamForceNorm = ...
          lsdynaBinout.elout.beam.axial ./ maxActiveIsometricForce;

        uniformModelData.name               = modelName;
        uniformModelData.nameLabel          = 'MAT156';
        uniformModelData.authorship         = 'Weiss (2016)';
        uniformModelData.authorshipShort    = 'Weiss (2016)';
        uniformModelData.mark = 'd';
        

    otherwise
        assert(0,['modelName (',modelName,') is not yet coded'])

end