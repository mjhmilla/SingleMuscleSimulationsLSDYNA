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
*TITLE
$#                                                                         title
Muskel
*CONTROL_TERMINATION
$#  endtim    endcyc     dtmin    endeng    endmas      
       0.4         0       0.0       0.01.000000E8
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
*DATABASE_SPCFORC
$#      dt    binary      lcur     ioopt     
&dtout             0         0         1
*DATABASE_BINARY_D3PLOT
$#      dt      lcdt      beam     npltc    psetid      
     0.001         0         0         0         0
$#   ioopt     
         0
*DATABASE_HISTORY_NODE
$#     id1       id2       id3       id4       id5       id6       id7       id8
         2         0         0         0         0         0         0         0
*LOAD_BODY_Z
$#    lcid        sf    lciddr        xc        yc        zc       cid   
        42 9.8100004         0       0.0       0.0       0.0         0
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
     0.001         2
$#
*INCLUDE
matpiglet.k
$*RIGIDWALL_PLANAR_ID
$#      id                                                                 title
$         1rigidwall
$#    nsid    nsidex     boxid    offset     birth     death     rwksf     
$         0         0         0       0.0       0.01.00000E20       1.0
$#      xt        yt        zt        xh        yh        zh      fric      wvel
$       0.0       0.0   -0.0597       0.0       0.0       0.0       0.0       0.0
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp     lcint
         3         0       1.0       1.0       0.0       0.0         0         0
$#                a1                  o1  
                 0.0                 1.0
                 0.5                 1.0
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp     lcint
        42         0       1.0       1.0       0.0       0.0         0         0
$#                a1                  o1  
                 0.0                 1.0
        1.000000e+20                 1.0
*ELEMENT_BEAM
$#   eid     pid      n1      n2      n3     rt1     rr1     rt2     rr2   local
       1       2       1       2       0       0       0       0       0       2
*NODE
$#   nid               x               y               z      tc      rc  
       1             0.0             0.0             0.0       7       7
       2             0.0             0.0         -0.0597       0       0
*ELEMENT_MASS
$#   eid     nid            mass     pid   
       2       2          &loadm       0
*END
