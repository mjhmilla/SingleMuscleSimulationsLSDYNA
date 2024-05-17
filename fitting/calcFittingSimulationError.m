function errDiff = calcFittingSimulationError(fittingInfo,...
                      matParams,uniformModelData,typeOfFitting)


errDiff = nan;

switch typeOfFitting
    case 0
        targetValue = matParams.lceNAT0;
        simValue    = interp1(uniformModelData.time,...
                           uniformModelData.lceATN,...
                           fittingInfo.timeAnalysis);
        errDiff = simValue-targetValue;
    case 1
        expValue = interp1(fittingInfo.expTime,fittingInfo.expForce,...
                           fittingInfo.timeAnalysis);
        simValue = interp1(uniformModelData.eloutTime,...
                           uniformModelData.eloutAxialBeamForceNorm.*uniformModelData.fmtOpt,...
                           fittingInfo.timeAnalysis);
        errDiff = simValue-expValue;        
    case 2
        npts =20;
        errDiff = zeros(npts,1);
    
        t0 =fittingInfo.timeAnalysis(1,1);
        t1 = fittingInfo.timeAnalysis(1,2);
        dt =(t1-t0)/(npts-1);
        timeVec = [t0:dt:t1]';
        for i=1:1:length(timeVec)
            expValue = interp1(fittingInfo.expTime,fittingInfo.expForce,...
                               timeVec(i,1));
            simValue = ...
                interp1(uniformModelData.eloutTime,...
                        uniformModelData.eloutAxialBeamForceNorm.*uniformModelData.fmtOpt,...
                        timeVec(i,1));
            errDiff(i,1) = simValue-expValue;        
        end
    case 3
        npts =20;
        errDiff = zeros(npts,1);
    
        t0 =fittingInfo.timeAnalysis(1,1);
        t1 = fittingInfo.timeAnalysis(1,2);
        dt =(t1-t0)/(npts-1);
        timeVec = [t0:dt:t1]';
        for i=1:1:length(timeVec)
            expValue = interp1(fittingInfo.expTime,fittingInfo.expForce,...
                               timeVec(i,1));
            simValue = ...
                interp1(uniformModelData.eloutTime,...
                        uniformModelData.eloutAxialBeamForceNorm.*uniformModelData.fmtOpt,...
                        timeVec(i,1));
            errDiff(i,1) = simValue-expValue;        
        end
    
end