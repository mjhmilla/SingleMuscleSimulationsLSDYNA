$
$ Matthew Millard
$ 26/01/2022
$
*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R    dtout 0.003
R dtsignal 0.003                                   
R     lopt 0.0428571
R     fiso 21.506061
R alphaRad 0.1221730
R alphaDeg 7.0  
R    ltslk 0.0304511
R       et  0.045833
R   points    2048.0
*PARAMETER_EXPRESSION
$#    name expression
R     freq 1/&dtsignal
R   lCEopt &lopt*cos(&alphaRad)
R     Fmax &fiso*cos(&alphaRad)
R       kt 30.0*&fiso/&ltslk
R   fceNom (&Fmax)*&stim
R   lceNom &lCEopt
R  fceNomN &fceNom/&Fmax
R  lceNomN &lceNom/&lCEopt
R pathLenO &lceNom+&fceNom/&kt+&ltslk
R pathLenN &pathLenO
R    timeE &points/&freq
*TITLE
$#                                                                         title
Muskel
*CONTROL_TERMINATION
$#  endtim    endcyc     dtmin    endeng    endmas      
    &timeE         0       0.0       0.01.000000E8
*CONTROL_TIMESTEP
$#  dtinit    tssfac      isdo    tslimt     dt2ms      lctm     erode     ms1st
       0.00.89999998         0       0.0       0.0         5         0         0
$#  dt2msf   dt2mslc     imscl    unused    unused     rmscl     
       0.0         0         0                           0.0
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp     lcint
         5         0       1.0       1.0       0.0       0.0         0         0
$#                a1                  o1  
                 0.0              0.0001
              &timeE              0.0001       
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
                 0.0               &stim
              &timeE               &stim
*ELEMENT_BEAM
$#   eid     pid      n1      n2      n3     rt1     rr1     rt2     rr2   local
       1       2       1       2       0       0       0       0       0       2
*BOUNDARY_PRESCRIBED_MOTION_NODE
$#  typeid       dof       vad      lcid        sf       vid     death     birth
         2         3         2         4       1.0
*NODE
$#   nid               x               y               z      tc      rc
       1             0.0             0.0      -&pathLenN       7       7
       2             0.0             0.0             0.0       7       7
*END
