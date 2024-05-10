function [umat43, keyPointsVEXATFpe, vexatCurves]= ...
            fitVEXATPassiveForceLengthRelation(expData,...
                    umat43,...
                    keyPointsHL1997, keyPointsHL2002,...
                    fiberForceLengthCurve,...
                    fiberForceLengthInverseCurve,...
                    vexatCurves,...
                    flag_plotVEXATPassiveForceLengthFitting)


fitMode=1;
errFcn = @(arg)calcVEXATPassiveForceLengthError(arg,umat43,...
                        keyPointsHL2002,...
                        keyPointsHL1997,...
                        fiberForceLengthCurve,...
                        fitMode);

x0 = [0;1];
options     = optimset('Display','off','TolF',1e-9);
[x1, resnorm,residual,exitflag]   = lsqnonlin(errFcn,x0,[],[],options);
%assert(exitflag==1 || exitflag==3);



shiftPE =x1(1,1);
scalePE =x1(2,1);

umat43.shiftPE=shiftPE;
umat43.scalePE=scalePE;

%HL1997 contains too few points to fit an entire fpe curve. Instead
%I'm just going to shift the fitted HL2002 curve until it intersects
%with the only significant data point.
if(contains(expData,'HL1997'))

    fitMode=2;
    errFcn2 = @(arg)calcVEXATPassiveForceLengthError(arg,umat43,...
                            keyPointsHL2002,...
                            keyPointsHL1997,...
                            fiberForceLengthCurve,...
                            fitMode);
    
    x0 = [shiftPE];
    options     = optimset('Display','off','TolF',1e-9);
    [x1, resnorm,residual,exitflag]   = lsqnonlin(errFcn2,x0,[],[],options); 

    shiftPE=x1(1,1);
    umat43.shiftPE=shiftPE;
end

disp('fitVEXATPassiveForceLengthRelation')
fprintf('\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n',...
        shiftPE,'shiftPE',scalePE,'scalePE');

lceN    = [0.7:0.01:1.4]';
fpeN    = zeros(size(lceN)); 
lceNAT  = zeros(size(lceN));
fpeNAT  = zeros(size(lceN));   
kpeNAT  = zeros(size(lceN));

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
    kpeN(i,1) = scalePE * calcQuadraticBezierYFcnXDerivative(lceN(i,1)-shiftPE,...
                                            fiberForceLengthCurve,1);
    fpeNAT(i,1) = fpeN(i,1)*cos(alpha);   
    kpeNAT(i,1) = kpeN(i,1)*cos(alpha);   

end

vexatCurves.fpe.lceNAT  = lceNAT;
vexatCurves.fpe.fceNAT  = fpeNAT;
vexatCurves.fpe.kceNAT  = kpeNAT; 
vexatCurves.fpe.rmse = sqrt(mean(residual.^2));

lceNATOne = interp1(fpeNAT(10:end),lceNAT(10:end),1);
kceNATOne = interp1(lceNAT(10:end),kpeNAT(10:end),lceNATOne);

keyPointsVEXATFpe.lceNAT=lceNATOne;
keyPointsVEXATFpe.fceNAT=1;
keyPointsVEXATFpe.kceNAT=kceNATOne;


if(flag_plotVEXATPassiveForceLengthFitting==1)    
    figVEXATFpe = figure;
        plot(lceNAT,fpeNAT,'-k','DisplayName','VEXAT');
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
        plot(keyPointsVEXATFpe.lceNAT,...
             keyPointsVEXATFpe.fceNAT,'.b','MarkerFaceColor',[0,0,1]);
        hold on;
        text(keyPointsVEXATFpe.lceNAT+0.013,keyPointsVEXATFpe.fceNAT,...
             sprintf('%1.3f fceOpt/lceOpt',keyPointsVEXATFpe.kceNAT),...
             'HorizontalAlignment','left');
        hold on;
        xlabel('Norm. Length ($$\ell/\ell^M_o$$');
        ylabel('Norm. Force ($$f/f^M_o$$');
        title('VEXAT Passive force-length relation fitting');        
end

