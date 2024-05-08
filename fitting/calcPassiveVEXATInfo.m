function vexatInfo = calcPassiveVEXATInfo(lceAT,shiftPE,scalePE,umat43,...
                        fiberForceLengthCurve,...
                        tendonForceLengthNormCurve,...
                        addTendonStrain)



fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                        0,...
                                        umat43.lceOpt,...
                                        umat43.penOpt);
lce   = fibKin.fiberLength;
alpha = fibKin.pennationAngle;
lceN  = lce/umat43.lceOpt;

fpeN = scalePE * calcQuadraticBezierYFcnXDerivative(lceN-shiftPE,...
                                      fiberForceLengthCurve,0);

fpeNAT = fpeN*cos(alpha);

vexatInfo.lceAT   = lceAT;
vexatInfo.lce     = lce;
vexatInfo.lceN    = lceN;
vexatInfo.lceNAT  = lceN/umat43.lceOpt;
vexatInfo.fpeN    = fpeN;
vexatInfo.fpeNAT  = fpeNAT;
vexatInfo.penAng  = alpha;
vexatInfo.et      = 0;
vexatInfo.ftN     = 0;



if(addTendonStrain==1)
    %lceAT has been evaluated as
    % lceAT = lp - ltSlk
    % but the tendon is really elastic, and so there is some strain
    % lceAT = lp - (ltSlk + ltDelta)
    % where
    % fpeAT(lceAT)=ft(ltSlk+ltDelta)

    lp_m_ltSlk= lceAT;

    etBest = fpeNAT/umat43.fceOpt;
    etDelta = etBest;
    errBest = inf;

    for i=1:1:15
        for j=1:1:2
            switch j
                case 1
                    step=-etDelta;
                case 2
                    step=etDelta;
            end
            if(i==1)
                step=0;
            end
            et = etBest + step;
            lceAT = lp_m_ltSlk - et*umat43.ltSlk;
    
            fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                            0,...
                                            umat43.lceOpt,...
                                            umat43.penOpt);
            lce   = fibKin.fiberLength;
            alpha = fibKin.pennationAngle;
            lceN  = lce/umat43.lceOpt;
            
            fpeN = scalePE * calcQuadraticBezierYFcnXDerivative(lceN-shiftPE,...
                                                  fiberForceLengthCurve,0);
            
            fpeNAT = fpeN*cos(alpha);

            etN = et/umat43.et;
            ftN = calcQuadraticBezierYFcnXDerivative(etN,...
                        tendonForceLengthNormCurve,0);

            ferr = fpeNAT-ftN;
            
            if(abs(ferr) < abs(errBest))
                errBest=abs(ferr);
                etBest=et;

                vexatInfo.lceAT   = lceAT;
                vexatInfo.lce     = lce;
                vexatInfo.lceN    = lceN;
                vexatInfo.lceNAT  = lceN/umat43.lceOpt;
                vexatInfo.fpeN    = fpeN;
                vexatInfo.fpeNAT  = fpeNAT;
                vexatInfo.penAng  = alpha;
                vexatInfo.et      = et;
                vexatInfo.ftN     = ftN;
                break;
            end
        end
        etDelta=etDelta*0.5;
    end
end


