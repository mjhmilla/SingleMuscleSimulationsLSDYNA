function [umat43,vexatCurves,keyPointsVEXATFv]= ...
            fitVEXATForceVelocityRelation(...
                    umat43,...
                    keyPointsHL1997,...
                    umat43QuadraticCurves,...
                    vexatCurves,...
                    flag_plotVEXATForceVelocityFitting)


errFcn = @(arg)calcVEXATForceVelocityError(arg,...
                        umat43,...
                        keyPointsHL1997,...
                        umat43QuadraticCurves);

x0 = [1];
options     = optimset('Display','off','TolF',1e-9);
[x1, resnorm,residual,exitflag]   = lsqnonlin(errFcn,x0,[],[],options);

vceMax = x1(1,1)*umat43.vceMax;
umat43.vceMax = vceMax;


disp('fitVEXATForceVelocityRelation')
fprintf('\t\t%1.4f\t%s\n',...
        vceMax,'vceMax');

vceNNAT    = ([-1:0.01:1]') ;
fceNAT    = zeros(size(vceNNAT));


for i=1:1:length(vceNNAT)

    vceAT = vceNNAT(i,1).*(umat43.vceMax*umat43.lceOpt);
    fibKin = calcFixedWidthPennatedFiberKinematics(umat43.lceOpt,...
                                        vceAT,...
                                        umat43.lceOpt,...
                                        umat43.penOpt);
    lce   = fibKin.fiberLength;
    dlce  = fibKin.fiberVelocity;
    alpha = fibKin.pennationAngle;
    dalpha= fibKin.pennationAngularVelocity;

    vceNN = dlce/(umat43.vceMax*umat43.lceOpt);
    
    fvN = calcQuadraticBezierYFcnXDerivative(vceNN, ...
            umat43QuadraticCurves.fiberForceVelocityCurve,0);

    fvNAT = fvN*cos(alpha);

    fceNAT(i,1)=fvNAT;

end

vexatCurves.fv.vceNNAT   = vceNNAT;
vexatCurves.fv.fceNAT    = fceNAT;
vexatCurves.fv.rmse = sqrt(mean(residual.^2));

lceOpt      = umat43.lceOpt;
alphaOpt    = umat43.penOpt;
alphaDotOpt = -(vceMax/lceOpt)*tan(alphaOpt);
vceMaxAT    = vceMax*cos(alphaOpt)-lceOpt*sin(alphaOpt)*alphaDotOpt;

keyPointsVEXATFv.vceMax = vceMax;
keyPointsVEXATFv.vceMaxAT= vceMaxAT;

if(flag_plotVEXATForceVelocityFitting==1)    
    figVEXATFv = figure;
        plot(vceNNAT.*vceMax,fceNAT,'-k','DisplayName','VEXAT');
        hold on;
        plot(keyPointsHL1997.fv.v ./ keyPointsHL1997.lceOptAT,...
             keyPointsHL1997.fv.fmt ./ keyPointsHL1997.fv.fmtMid,'ok',...
             'DisplayName','HL1997');
        hold on;
        xlabel('Norm. Length ($$\ell/\ell^M_o$$');
        ylabel('Norm. Force ($$f/f^M_o$$');
        title('VEXAT fore-velocity relation fitting');        
end

