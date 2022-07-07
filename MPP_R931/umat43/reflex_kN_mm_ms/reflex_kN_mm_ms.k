$
$ Matthew Millard
$ 31/05/2022
$
*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R    dtout      10.0                                     
R rampLenE       9.0
R deltaLen       1.0
R   lceOpt   42.8571
R   fceOpt 0.0243646
R   penOpt 0.1221730
R  penOptD       7.0
R    ltSlk   30.4511
R       et  0.045833
R   vceMax    0.0045
$
*PARAMETER_EXPRESSION
$#    name expression
R rampLenS &rampLenE-&rampLen
RrampTime0 1000+(&rampLenE-&rampLen)/&rampVel 
RrampTimeD (&rampLen)/&rampVel
RrampTimeE (&rampLen+&deltaLen)/&rampVel
RrampTime1 &rampTime0+&rampTimeD
RrampTime2 &rampTime1+1000
RrampTime3 &rampTime2+&rampTimeE
R pathLenO &lceOpt*cos(&penOpt)+&ltSlk
R pathLenA &pathLenO+&rampLenS
R pathLenB &pathLenO+&rampLenE  
R pathLenC &pathLenO+&rampLenS-&deltaLen
R    timeE &rampTime3+1000
$
*TITLE
$#                                                                         title
Muskel
*CONTROL_TERMINATION
$#  endtim    endcyc     dtmin    endeng    endmas      
    &timeE         0       0.0       0.01.000000E8
*CONTROL_TIMESTEP
$#  dtinit    tssfac      isdo    tslimt     dt2ms      lctm     erode     ms1st
       1.0 0.8999999         0       0.0  -3.33e-3         9         0         0
$#  dt2msf   dt2mslc     imscl    unused    unused     rmscl     
       0.0         0         0                           0.0
$---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
$                                                                              $
$                             DATABASE (OUTPUT)                                $
$                                                                              $
$---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
*DATABASE_GLSTAT
$#      dt    binary      lcur     ioopt     
&dtout             0         0         1
*DATABASE_MATSUM
$#      dt    binary      lcur     ioopt     
&dtout             0         0         1
*DATABASE_NODOUT
$#      dt    binary      lcur     ioopt   option1   option2       
&dtout             3         0         1       0.0         0
*DATABASE_SPCFORC
$#      dt    binary      lcur     ioopt     
&dtout             0         0         1
*DATABASE_BINARY_D3PLOT
$#      dt      lcdt      beam     npltc    psetid      
    &dtout         0         0         0         0
$#   ioopt     
         0
*DATABASE_HISTORY_NODE
$#     id1       id2       id3       id4       id5       id6       id7       id8
         2         0         0         0         0         0         0         0
*PART
$#                                                                         title
Beam2
$#     pid     secid       mid     eosid      hgid      grav    adpopt      tmid
         2         1         1         0         0         0         0         0
*SECTION_BEAM
$#   secid    elform      shrf   qr/irid       cst     scoor       nsm   
         1         3       1.0         2         0       0.0       0.0
$#       a     rampt    stress      
       1.0       0.0       0.0
*DATABASE_HISTORY_BEAM
$#     id1       id2       id3       id4       id5       id6       id7       id8
         1         0         0         0         0         0         0         0       
*DATABASE_ELOUT
    &dtout         2
$#
*INCLUDE
catsoleus.k
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp     lcint
         3         0       1.0       1.0       0.0       0.0         0         0
$#                a1                  o1  
                 0.0                 0.0
              &timeE                 0.0
*ELEMENT_BEAM
$#   eid     pid      n1      n2      n3     rt1     rr1     rt2     rr2   local
       1       2       1       2       0       0       0       0       0       2
*BOUNDARY_PRESCRIBED_MOTION_NODE
$#  typeid       dof       vad      lcid        sf       vid     death     birth
         2         3         2         4       1.0
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         4         0       1.0       1.0       0.0       0.0
$#                a1                  o1
                 0.0          -&pathLenA
          &rampTime0          -&pathLenA
          &rampTime1          -&pathLenB
          &rampTime2          -&pathLenB
          &rampTime3          -&pathLenC
              &timeE          -&pathLenC
$
*NODE
$#   nid               x               y               z      tc      rc
       1             0.0             0.0             0.0       7       7
       2             0.0             0.0      -&pathLenA       7       7
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         9         0  1.000000  1.000000     0.000     0.000         0
$#                a1                  o1
            0.000000               0.300
          &rampTime0               0.050
          &rampTime3               0.050
              &timeE               0.300
$
*END
