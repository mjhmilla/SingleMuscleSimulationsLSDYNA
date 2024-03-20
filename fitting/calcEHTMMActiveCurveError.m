function errVec = calcEHTMMActiveCurveError(arg,umat41,expDataFal,...
                    umat43,umat43QuadraticBezierCurves, ...
                    errorScaling)

dWdes   = arg(1,1);
nuCEdes = arg(2,1);

errVec = zeros(size(expDataFal.lmt));

flag_fitToData=0;
flag_fitToUmat43=1;
for i=1:1:length(expDataFal.lmt)


    lmt = expDataFal.lmt(i,1);
    fmt = expDataFal.fmt(i,1);

    lsee = calcFseeInverseUmat41(fmt,...
             umat41.ltSlk,umat41.dUSEEnll,umat41.duSEEl,umat41.dFSEE0);  

    lceAT = lmt-(lsee-umat41.ltSlk);
    falNAT = calcFisomUmat41(lceAT,umat41.lceOptAT,dWdes,nuCEdes,umat41.dWasc,umat41.nuCEasc);

    %The parameters that fit nicely here produce values that
    %exceed the corresponding values in the LS-DYNA simulation.
    %There is some difference between the matlab implementation that I'm
    %using and the LS-DYNA implementation
    if(flag_fitToData==1)
        fpeAT= calcFpeeUmat41( lceAT,...
                            umat41.lceOptAT,...
                            umat41.dWdes,...
                            umat41.fceOptAT,...
                            umat41.FPEE,...
                            umat41.LPEE0,...
                            umat41.nuPEE);
    
        errVec(i,1) = (falNAT*umat41.fceOptAT+fpeAT) - expDataFal.fmt(i,1);
    end

    %Umat43's active curve does a nice job in the LS-DYNA simulation, so
    %I'm going to instead fit Umat41's curve to Umat43.
    if(flag_fitToUmat43==1)
        fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,0,...
                    umat43.lceOpt,umat43.penOpt);
        lce = fibKin.fiberLength;
        alpha=fibKin.pennationAngle;

        falN43 = calcQuadraticBezierYFcnXDerivative(lce/umat43.lceOpt,...
                        umat43QuadraticBezierCurves.activeForceLengthCurve,...
                        0);
        errVec(i,1)= falNAT - falN43*cos(alpha);
    end

end

errVec = errVec./errorScaling;