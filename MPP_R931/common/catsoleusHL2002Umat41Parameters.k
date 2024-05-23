*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R   lceOpt 0.0489606
R   fceOpt 21.638090
R lceOptAT 0.0485957
R fceOptAT 21.476803
R lmtOptAT 0.0733083
R   penOpt 0.1221730
R  penOptD 7.0000000
R    ltSlk 0.0345285
R       et 0.0458333
R   dFSEE0 8.6176138
R dUSEEnll 0.0258751
R   duSEEl 0.0133751
R   vceMax 2.7357881
R    LPEE0 0.9984105
R     FPEE 2.0724162
R    nuPEE 1.3604527
R    dWasc 0.5428449
R  nuCEasc 2.0903464
R    dWdes 0.5852823
R  nuCEdes 1.1680242
R     Arel 0.1527184
R     Brel 0.4178053
R     Secc 20.103282
R     Fecc 1.3194355
R    dtInt 0.0000500
R    dtOut 0.0100000
R  tdnToCe 0.7052300
Rlp0HL2002 0.0817025
R lp0K1994 0.0837985
Rlp0HL1997 0.0738613
*PARAMETER_EXPRESSION
$#    name expression
R       kt &dFSEE0/(&duSEEl*&ltSlk)
*END
