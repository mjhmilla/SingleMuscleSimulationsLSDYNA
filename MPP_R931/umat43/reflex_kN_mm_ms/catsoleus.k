$
$ SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
$
$ SPDX-License-Identifier: MIT
$
$
*KEYWORD
*MAT_USER_DEFINED_MATERIAL_MODELS
$ Millard 2022 Muscle
$#     mid        ro        mt       lmc       nhv    iortho     ibulk        ig
         11.00000E-6        43        33      1000         0         3         4
$#   ivect     ifail    itherm    ihyper      ieos      lmca    unused    unused
         0         0         0         0         0         0                    
$#  stimId exDefault    tauAct  tauDeact fceOptIso    lceOpt alphaOptD useRgdTdn
         3       0.0       10.       40.   &fceOpt   &lceOpt  &penOptD         0
$#   ltSlk     etIso       dtN  scalePEE lambdaECM  lPevkPtN lceHNLb1A   act1AHN
    &ltSlk     0.049      55.6      0.76      0.56       0.5       0.5       0.1
$#beta1AHN  beta1PHN kxOptIsoN dxOptIsoN gainTrack  actTrack    vceMax   taudvst
   45000.0       250      47.8     0.354     0.001      0.05   &vceMax     1000.
$# dvsBeta    dtNumN   aniType   ctlType  ctlDelay  ctlThrsh ctlOnTime    output    
     0.001 0.0000001         1         3       25.     0.075       100         1
$#   dtout     
        1.
*END
