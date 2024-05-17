function errDiff = calcFittingSimulationError(fittingInfo,uniformModelData)


errDiff = nan;
if(length(fittingInfo.timeAnalysis)==1)
    expValue = interp1(fittingInfo.expTime,fittingInfo.expForce,...
                       fittingInfo.timeAnalysis);
    simValue = interp1(uniformModelData.eloutTime,...
                       uniformModelData.eloutAxialBeamForceNorm,...
                       fittingInfo.timeAnalysis);
    errDiff = simValue-expValue;
elseif(length(fittingInfo.timeAnalysis)==2)
    
    npts =10;
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

else
    assert(0,'Error: timeAnalysis must have 1 or two elements');
end