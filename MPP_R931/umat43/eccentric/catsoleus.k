*KEYWORD
*MAT_USER_DEFINED_MATERIAL_MODELS
$ Millard 2022 Muscle
$#     mid        ro        mt       lmc       nhv    iortho     ibulk        ig
         1       1.0        43        32      1000         0         3         4
$#   ivect     ifail    itherm    ihyper      ieos      lmca    unused    unused
         0         0         0         0         0         0                    
$#  stimId exDefault    tauAct  tauDeact fceOptIso    lceOpt alphaOptD useRgdTdn
         3       0.0     0.040     0.080   &fceOpt   &lceOpt  &penOptD         0
$#   ltSlk     etIso       dtN  scalePEE lambdaECM  lPevkPtN lceHNLb1A   act1AHN
    &ltSlk     0.049    0.0556      1.00      0.66       0.5      0.40       0.1
$#beta1AHN  beta1PHN kxOptIsoN dxOptIsoN gainTrack  actTrack    vceMax   taudvst
      65.0      0.25      47.8     0.354    1000.0      0.05   &vceMax     0.001
$# dvsBeta    dtNumN   aniType  ctrlType ctrlDelay ctrlThrsh    output     dtout    
       1.0    0.0001         1         1     0.025     0.075         2     0.001   
*END
