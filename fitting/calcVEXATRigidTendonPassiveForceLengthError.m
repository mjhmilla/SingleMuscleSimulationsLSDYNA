function errVec = calcVEXATRigidTendonPassiveForceLengthError(x,...
                scaleSoln,...               
                umat43RT,...
                umat43SarcomereParams,...
                umat43QuadraticCurves,...
                umat43QuadraticTitinCurves,...
                expActiveIsometricPts,...
                expPassiveIsometricPts,...
                pathLengthReference,...
                expFceOptAt,...
                flag_fittingHL1997)


lp0    = pathLengthReference*umat43RT.lceOptAT;

if(flag_fittingHL1997 == 0)
    shiftPEE = x(1,1)*scaleSoln.shiftPEE;
    scalePEE = x(2,1)*scaleSoln.scalePEE;
else
    shiftPEE = x(1,1)*scaleSoln.shiftPEE;
    scalePEE = umat43RT.scalePEE;    
end

flag_addPassivePoints=1;
flag_addActivePoints =0;
errVec = [];

if(flag_addActivePoints==1)
    errVec = [errVec; zeros(length(expActiveIsometricPts.l),1)];
end
if(flag_addPassivePoints==1)
    errVec = [errVec; zeros(length(expPassiveIsometricPts.l),1)];
end

%errVec = zeros(length(expActiveIsometricPts.l)...
%              +length(expPassiveIsometricPts.l), 1);

idx=1;

%A reduced set of parameters to evaluate the isometric equilbrium of 
%the model
umat43RTFitting=umat43RT;

umat43RTFitting.scalePEE=scalePEE;
umat43RTFitting.shiftPEE=shiftPEE;
umat43RTFitting.ltSlk=0;


%For every passive point and active point evaluate the isometric
%equilibrium at each path length and evaluate the difference in force
%between the experimental data and the model

if(flag_addPassivePoints==1)
    if(isempty(length(expPassiveIsometricPts.l))==0)
        for i=1:1:length(expPassiveIsometricPts.l)
            activation=0;
            pathLength = lp0 + expPassiveIsometricPts.l(i,1);
    
            useElasticTendon=0;
            modelState = calcVEXATIsometricState(...
                                activation,...
                                pathLength,...
                                pathLength,...
                                umat43RTFitting,...
                                umat43SarcomereParams,...
                                umat43QuadraticCurves,...
                                umat43QuadraticTitinCurves,...
                                useElasticTendon);          
    
            errVec(idx,1) = modelState.fceNAT ...
                          - expPassiveIsometricPts.fmt(i)./expFceOptAt; 
            idx=idx+1;
        end
    end
end

if(flag_addActivePoints==1)
    if(isempty(length(expActiveIsometricPts.l))==0)
        for i=1:1:length(expActiveIsometricPts.l)
            activation=1;
            pathLength = lp0 + expPassiveIsometricPts.l(i,1);
            %expActiveIsometricPts.lceNAT(i)*umat43RTFitting.lceOpt;
    
            useElasticTendon=0;
            modelState = calcVEXATIsometricState(...
                                activation,...
                                pathLength,...
                                pathLength,...
                                umat43RTFitting,...
                                umat43SarcomereParams,...
                                umat43QuadraticCurves,...
                                umat43QuadraticTitinCurves,...
                                useElasticTendon);          
    
            errVec(idx,1) = modelState.fceNAT ...
                          - expActiveIsometricPts.fmt(i)./expFceOptAt; 
            idx=idx+1;        
        end
    end
end

here=1;
