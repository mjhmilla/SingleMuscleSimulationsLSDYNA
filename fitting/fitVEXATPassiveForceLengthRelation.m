function [umat43, keyPointsVEXATFpe, vexatCurves]= ...
            fitVEXATPassiveForceLengthRelation(expData,...
                    umat43,...
                    keyPointsHL1997, keyPointsHL2002,...
                    fiberForceLengthCurve,...
                    tendonForceLengthNormCurve,...
                    tendonForceLengthInverseNormCurve,...
                    vexatCurves,...
                    flag_plotVEXATPassiveForceLengthFitting)

assert(contains(expData,'HL1997')==0,'Error: Need to add HL1997 fpe fit');

errFcn = @(arg)calcVEXATPassiveForceLengthError(arg,umat43,...
                        keyPointsHL2002,fiberForceLengthCurve,...
                        tendonForceLengthInverseNormCurve);

x0 = [0;1];
options     = optimset('Display','off','TolF',1e-9);
[x1, resnorm,residual,exitflag]   = lsqnonlin(errFcn,x0,[],[],options);
%assert(exitflag==1 || exitflag==3);

shiftPE =x1(1,1);
scalePE =x1(2,1);

umat43.shiftPE=shiftPE;
umat43.scalePE=scalePE;

%Solve for the length at which fpe develops fiso along the tendon.
lceNBest = fiberForceLengthCurve.xEnd(1,2);
errBest = inf;
delta  = 2*(fiberForceLengthCurve.xEnd(1,2)...
            -fiberForceLengthCurve.xEnd(1,1));

for i=1:1:24
    for j=1:1:2
        stepLen =0;
        switch j
            case 1
                stepLen=-delta;
            case 2
                stepLen=delta;
        end
        if(i==1)
            stepLen=0;
        end
        
        lceNOne = lceNBest+stepLen;
        fpeN = scalePE * calcQuadraticBezierYFcnXDerivative(lceNOne-shiftPE,...
                                            fiberForceLengthCurve,0);
        
        fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                    lceNOne*umat43.lceOpt,...
                    0,...
                    umat43.lceOpt,...
                    umat43.penOpt);
        
        lceNOneAT=fibKin.fiberLengthAlongTendon/umat43.lceOpt;
        alpha = fibKin.pennationAngle;

        errFpe = fpeN*cos(alpha) - 1;

        if(abs(errFpe)<abs(errBest))
            errBest=errFpe;
            lceNBest = lceNOne;
            lceNBestAT = lceNOneAT;
            alphaBest=alpha;
            break;
        end        
    end
    delta=delta*0.5;
end

assert(abs(errBest)<1e-5);

fpeN= scalePE * calcQuadraticBezierYFcnXDerivative(lceNBest-shiftPE,...
                                            fiberForceLengthCurve,0);
kpeN= scalePE * calcQuadraticBezierYFcnXDerivative(lceNBest-shiftPE,...
                                            fiberForceLengthCurve,1);

etN = calcQuadraticBezierYFcnXDerivative(fpeN*cos(alphaBest),...
        tendonForceLengthInverseNormCurve,0);
et = etN*umat43.et;
lmtNAT = lceNBest*cos(alphaBest) + (et*umat43.ltSlk)/umat43.lceOpt;

ftN = calcQuadraticBezierYFcnXDerivative(etN,tendonForceLengthNormCurve,0);
ktN = calcQuadraticBezierYFcnXDerivative(etN,tendonForceLengthNormCurve,1)...
     *(1/umat43.et);
kt = ktN*(umat43.fceOpt/umat43.ltSlk);
kpeAT= kpeN*cos(alphaBest)*(umat43.fceOpt/umat43.lceOpt);
kmt = ((1/kt)+(1/kpeAT))^-1;
kmtN= kmt/(umat43.fceOpt/umat43.lceOpt);

keyPointsVEXATFpe.lceN   = lceNBest;
keyPointsVEXATFpe.lceNAT = lceNBest*cos(alphaBest);
keyPointsVEXATFpe.fceN   = fpeN;
keyPointsVEXATFpe.fceNAT = fpeN*cos(alphaBest);
keyPointsVEXATFpe.kceN   = kpeN;
keyPointsVEXATFpe.kceNAT = kpeN*cos(alphaBest);
keyPointsVEXATFpe.et = et;
keyPointsVEXATFpe.ftN = ftN;
keyPointsVEXATFpe.ktN = ktN;
keyPointsVEXATFpe.lmtNAT = lmtNAT;
keyPointsVEXATFpe.kmtN = kmtN;

disp('fitVEXATPassiveForceLengthRelation')
fprintf('\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n',...
        shiftPE,'shiftPE',scalePE,'scalePE');

lceN   = [0.8:0.01:1.4]';
fpeN   = zeros(size(lceN)); 
lceNAT = zeros(size(lceN));
fpeNAT = zeros(size(lceN));        
lmtNAT  = zeros(size(lceN));

lceOptAT    = umat43.lceOptAT;
lceOpt      = umat43.lceOpt;

for i=1:1:length(lceNAT)

    fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                lceN(i,1)*lceOpt,...
                0,...
                lceOpt,...
                umat43.penOpt);

    lceNAT(i,1) = fibKin.fiberLengthAlongTendon./lceOpt;
    alpha = fibKin.pennationAngle;

    fpeN(i,1) = scalePE * calcQuadraticBezierYFcnXDerivative(lceN(i,1)-shiftPE,...
                                            fiberForceLengthCurve,0);
    fpeNAT(i,1) = fpeN(i,1)*cos(alpha);    

    etN = calcQuadraticBezierYFcnXDerivative(fpeNAT(i,1),tendonForceLengthInverseNormCurve,0);
    et = etN*umat43.et;

    lmtNAT(i,1)=lceNAT(i,1) + (et*umat43.ltSlk)/umat43.lceOpt;

end

vexatCurves.fpe.lceN    = lceN;
vexatCurves.fpe.fpeN    = fpeN;
vexatCurves.fpe.lceNAT  = lceNAT;
vexatCurves.fpe.fpeNAT  = fpeNAT;
vexatCurves.fpe.lmtNAT   = lmtNAT;

if(flag_plotVEXATPassiveForceLengthFitting==1)    
    figVEXATFpe = figure;
        plot(lmtNAT,fpeNAT,'-k','DisplayName','VEXAT');
        hold on;
        switch expData
            case 'HL1997'
                plot(keyPointsHL1997.fpe.lceNAT,...
                     keyPointsHL1997.fpe.fceNAT,'ok',...
                     'DisplayName','HL1997');
                hold on;
                plot(keyPointsHL2002.fpe.lceNAT,...
                     keyPointsHL2002.fpe.fceNAT,'xk',...
                     'DisplayName','HL2002');
                hold on;                
            case 'HL2002'
                plot(keyPointsHL2002.fpe.lceNAT,...
                     keyPointsHL2002.fpe.fceNAT,'xk',...
                     'DisplayName','HL2002');
                hold on;                
        end
        plot(keyPointsVEXATFpe.lmtNAT,...
             keyPointsVEXATFpe.fceNAT,'.b','MarkerFaceColor',[0,0,1]);
        hold on;
        text(keyPointsVEXATFpe.lmtNAT+0.013,keyPointsVEXATFpe.fceNAT,...
             sprintf('%1.3f fceOpt/lceOpt',keyPointsVEXATFpe.kmtN),...
             'HorizontalAlignment','left');
        hold on;
        xlabel('Norm. Length ($$\ell/\ell^M_o$$');
        ylabel('Norm. Force ($$f/f^M_o$$');
        title('VEXAT Passive force-length relation fitting');        
end

