%2024/3/19

%evaluate tendon change of length
%-----------------------------------------------------------

%Calculate tendon change of length
expDataFpe.dltUmat41 = zeros(size(expDataFpe.fmt));
expDataFpe.dltUmat43 = zeros(size(expDataFpe.fmt));

for i=1:1:length(expDataFpe.lmt)
    expDataFpe.dltUmat41(i,1) =...
        calcFseeInverseUmat41(expDataFpe.fmt(i,1),...
             umat41.ltSlk,umat41.dUSEEnll,umat41.duSEEl,umat41.dFSEE0);
    expDataFpe.dltUmat41(i,1) = expDataFpe.dltUmat41(i,1)-umat41.ltSlk;

    expDataFpe.dltUmat43(i,1)= ...
        calcQuadraticBezierYFcnXDerivative(expDataFpe.fmt(i,1)/umat43.fceOpt,...
          felineSoleusNormMuscleQuadraticCurves.tendonForceLengthInverseCurve,0);

    expDataFpe.dltUmat43(i,1)= (expDataFpe.dltUmat43(i,1)-1)*umat43.ltSlk;
end

expDataFpe.lceAT_umat41  = expDataFpe.lmt - expDataFpe.dltUmat41;
expDataFpe.lceNAT_umat41 = expDataFpe.lceAT_umat41./umat41.lceOptAT;

expDataFpe.lceAT_umat43 = expDataFpe.lmt - expDataFpe.dltUmat43;
expDataFpe.lceNAT_umat43 = expDataFpe.lceAT_umat43./umat43.lceOpt;

%-----------------------------------------------------------

expKeyPtsDataFpe.dltUmat41 = zeros(size(expKeyPtsDataFpe.fmt));
expKeyPtsDataFpe.dltUmat43 = zeros(size(expKeyPtsDataFpe.fmt));

for i=1:1:length(expKeyPtsDataFpe.lmt)
    expKeyPtsDataFpe.dltUmat41(i,1) =...
        calcFseeInverseUmat41(expKeyPtsDataFpe.fmt(i,1),...
             umat41.ltSlk,umat41.dUSEEnll,umat41.duSEEl,umat41.dFSEE0);
    expKeyPtsDataFpe.dltUmat41(i,1) = expKeyPtsDataFpe.dltUmat41(i,1)-umat41.ltSlk;

    expKeyPtsDataFpe.dltUmat43(i,1)= ...
        calcQuadraticBezierYFcnXDerivative(expKeyPtsDataFpe.fmt(i,1)/umat43.fceOpt,...
          felineSoleusNormMuscleQuadraticCurves.tendonForceLengthInverseCurve,0);

    expKeyPtsDataFpe.dltUmat43(i,1)= (expKeyPtsDataFpe.dltUmat43(i,1)-1)*umat43.ltSlk;
end

expKeyPtsDataFpe.lceAT_umat41  = expKeyPtsDataFpe.lmt - expKeyPtsDataFpe.dltUmat41;
expKeyPtsDataFpe.lceNAT_umat41 = expKeyPtsDataFpe.lceAT_umat41./umat41.lceOptAT;

expKeyPtsDataFpe.lceAT_umat43 = expKeyPtsDataFpe.lmt - expKeyPtsDataFpe.dltUmat43;
expKeyPtsDataFpe.lceNAT_umat43 = expKeyPtsDataFpe.lceAT_umat43./umat43.lceOpt;

%-----------------------------------------------------------
%
    if(flag_subMax == 0)
        cd(fullfile('..','isometric_max'));
        
        [binoutIsometric,status] = ...
            binoutreader('dynaOutputFile','binout0000',...
                            'ignoreUnknownDataError',true);
        timeSampleExcitation1 = getParameterValueFromD3HSPFile('d3hsp', 'TIMES1'); 
    
        switch lsdynaMuscleUniform.name
            case 'umat41'
                [musout,success] = ...
                    readUmat41MusoutData('musout.0000000002');  
            case 'umat43'
                [musout,success] = ...
                    readUmat43MusoutData('musout.0000000002');             
            case 'viva'
                musout=[];
            case 'mat156'
                musout=[];
            otherwise assert(0)
        end
    
        cd(currDir);    
    else
        cd(fullfile('..','isometric_sub_max'));
        [binoutIsometric,status] = ...
            binoutreader('dynaOutputFile','binout0000',...
                            'ignoreUnknownDataError',true);
        timeSampleExcitation1 = getParameterValueFromD3HSPFile('d3hsp', 'TIMES1');  
        switch lsdynaMuscleUniform.name
            case 'umat41'
                [musout,success] = ...
                    readUmat41MusoutData('musout.0000000002');  
            case 'umat43'
                [musout,success] = ...
                    readUmat43MusoutData('musout.0000000002');             
            case 'viva'
                musout=[];
            case 'mat156'
                musout=[];
            otherwise assert(0)
        end    
        cd(currDir);        
    end
    
    switch lsdynaMuscleUniform.name
        case 'umat41'
            lceNSample = musout.data(end,musout.indexLce)./optimalFiberLength; 
        case 'umat43'
            lceNSample = musout.data(end,musout.indexLceN);           
        case 'viva'
            lceNSample = -binoutIsometric.nodout.z_coordinate(idxActiveSample,1)...
                            /optimalFiberLength;
        case 'mat156'
            lceNSample = -binoutIsometric.nodout.z_coordinate(idxActiveSample,1)...
                            /optimalFiberLength;
            
        otherwise assert(0)
    end 

