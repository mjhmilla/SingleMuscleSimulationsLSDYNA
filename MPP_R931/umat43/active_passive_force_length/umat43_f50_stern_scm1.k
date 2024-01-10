*MAT_USER_DEFINED_MATERIAL_MODELS                                               
$# Millard 2023 VEXAT Muscle                                                    
$#     mid        ro        mt       lmc       nhv    iortho  ibulkIdx     igIdx
   2008120  0.000001        43        35      1000         0        29        30
$#   ivect     ifail    itherm    ihyper      ieos      lmca    unused    unused
         0         1         0         0         0         0                    
$#  stimId exDefault    tauAct  tauDeact fceOptIso    lceOpt alphaOptD useRgdTdn
         0    &exLow       10.       40.    0.0349   123.228        0.         0
$#   ltSlk     etIso       dtN  scalePEE lambdaECM  lPevkPtN lceHNLb1A   act1AHN
   58.8957     0.068      55.6        1.      0.56       0.5       0.4       0.1
$#beta1AHN  beta1PHN kxOptIsoN dxOptIsoN   gainTrk    actTrk    vceMax   taudvst
  &betaAHN      250.      47.8     0.354     0.001      0.05      0.01     1000.
$# dvsBeta    dtNumN   aniType   ctlType  ctlDelay  ctlThrsh ctlOnTime    output
     0.001       0.1         0         3     &cDly     &cThr  &cOnTime         1
$#   dtout     IBULK        IG
        1.      0.13      0.13
*END
