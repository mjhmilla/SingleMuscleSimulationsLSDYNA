*KEYWORD
*MAT_USER_DEFINED_MATERIAL_MODELS                                            
$# Millard 2023 VEXAT Muscle                                                    
$#     mid        ro        mt       lmc       nhv    iortho  ibulkIdx     igIdx
         11.00000E-6        43        33      1000         0         3         4
$#   ivect     ifail    itherm    ihyper      ieos      lmca    unused    unused
         0         0         0         0         0         0                    
$#  stimId exDefault    tauAct  tauDeact fceOptIso    lceOpt alphaOptD useRgdTdn
         3        0.       10.       40.   &fceOpt   &lceOpt  &penOptD         0
$#   ltSlk     etIso       dtN  scalePEE lambdaECM  lPevkPtN lceHNLb1A   act1AHN
    &ltSlk       &et      55.6        1.      0.56       0.5       0.4       0.1
$#beta1AHN  beta1PHN kxOptIsoN dxOptIsoN   gainTrk    actTrk    vceMax   taudvst
     0.065       10.     47.8     0.354      0.001      0.05   &vceMax     1000.
$# dvsBeta    dtNumN   aniType   ctlType  ctlDelay  ctlThrsh ctlOnTime    output
     0.001       0.1         0         0       0.0       0.0       0.0         1
$#   dtout
        10
*END
