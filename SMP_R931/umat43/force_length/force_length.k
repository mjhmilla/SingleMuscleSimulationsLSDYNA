$
$ This is supplementary material for the publication:
$
$ C. Kleinbach, O. Martynenko, J. Promies, D.F.B. Haeufle, J. Fehr, S. Schmitt:
$ Implementation and Validation of the Extended Hill-type Muscle Model with
$ Robust Routing Capabilities in LS-DYNA for Active Human Body Models,
$ Biomedical Engineering Online, 2017.
$
$ If you use this material model for scientific purposes, please cite the original
$ research article.
$
*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R    dtout     0.001  
R   lceOpt     0.015
R    ltSlk     0.045
R  penOptD      15.0
R   fceOpt      30.0
R    timeE       3.5
*PARAMETER_EXPRESSION
$#    name expression
R  penOptR &penOptD*3.1415926/180.0
R    lceXT &lceOpt*sin(penOptR)  
R     lce0 &lceOpt*0.4
R     lce1 &lceOpt*1.7
R   lceAT0 sqrt((&lce0)*(&lce0)-lceXT*lceXT)
R   lceAT1 sqrt((&lce1)*(&lce1)-lceXT*lceXT)
R      lp0 &lceAT0 + &ltSlk
R      lp1 &lceAT1 + &ltSlk
*TITLE
$#                                                                         title
isometric Muscle contraction
*CONTROL_TERMINATION
$#  endtim    endcyc     dtmin    endeng    endmas      
    &timeE         0       0.0       0.01.000000E8
*CONTROL_TIMESTEP
$#  dtinit    tssfac      isdo    tslimt     dt2ms      lctm     erode     ms1st
       0.00.89999998         0       0.0       0.0         0         0         0
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
*DATABASE_RCFORC
$#      dt    binary      lcur     ioopt     
&dtout             3         0         1
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
*PART_AVERAGED
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
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp     lcint
         3         0       1.0       1.0       0.0       0.0         0         0
$#                a1                  o1  
                 0.0                 0.0
                0.09                 0.0
                0.10               &stim
                2.10               &stim
                2.11                 0.0
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
                 0.0               -&lp0
                 1.0               -&lp0
                 2.0               -&lp1
              &timeE               -&lp1
$
*NODE
$#   nid               x               y               z      tc      rc
       1             0.0             0.0             0.0       7       7
       2             0.0             0.0           -&lp0       7       7       
*INCLUDE
matpiglet.k
*END
