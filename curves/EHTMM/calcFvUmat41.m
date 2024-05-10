function fv = calcFvUmat41(vce,lce,lceOpt,Fmax,Fisom,q,Arel0,Brel0,Fecc,Secc)

LArel   = 1; 
if(lce > lceOpt)
    LArel=Fisom;
end
LBrel   = 1;

QArel   = 0.25*(1+3*q);
QBrel   = (1/7)*(3+4*q);

ArelVal = Arel0*LArel*QArel;
BrelVal = Brel0*LBrel*QBrel;


if(vce <= 0)
    %Concentric equations function as published in Haeufle et al. 2014
    fv= Fmax*( (q*Fisom+ArelVal)/(1-(vce/(BrelVal*lceOpt)) ) - ArelVal);
else
    %The eccentric equations do not function as published in Haeufle et al. 2014
    %Deriving the expressions from Bobbert et tal.
    
    %As vce -> inf fce -> Fecc*fmax. Taking the limits of the eccentric
    %hyperbola 
    %
    % vce = lceOpt*( c1 / ( (fce*q/fmax) + c2)    + c3)
    % fce = - (c2*fmax*vce - (c1+c2*c3)*fmax*lceOpt)
    %        /(q*vce - c3*lceOpt*q)
    %
    %  vce->infty
    %
    %  fce -> c2*fmax / q
    %
    % at q = 1
    c2 = -Fecc;
    
    %At vce = 0, the value of dfdv of the eccentric curve is equal to the
    %derivative of the concentric curve scaled by Secc. Using this we can solve
    %for c1
    fce = Fmax*Fisom*q;
    dvdf = ((ArelVal+1)*BrelVal*lceOpt) / ( Fmax*( (fce/Fmax) + ArelVal)^2);
    
    vceVal  = 0;
    dfdv = (ArelVal+1)*Fmax / (BrelVal * lceOpt * (1-(vceVal/(BrelVal*lceOpt)))^2 );
    
    assert(abs(dvdf-(1/dfdv))<1e-6);
    
    dvdfEcc = dvdf*(1/Secc);
    
    fce=Fmax;
    q=1;
    c1 = (-dvdfEcc*Fmax*(fce*q/Fmax +c2)^2) / (lceOpt*q);
    
    % Finally, at vce=0 and fce=Fmax, fecc = fconc
    
    c3 = -c1/(1+c2);    

    fv = -(c2*Fmax*1*vce + (-c2*c3-c1)*Fmax*lceOpt*q) / (vce - c3*lceOpt);
end

