*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R   lceOpt 0.0453506
R   fceOpt 21.712433
R lceOptAT 0.0450126
R fceOptAT 21.550592
R lmtOptAT 0.0784566
R   penOpt 0.1221730
R  penOptD 7.0000000
R    ltSlk 0.0319737
R       et 0.0458333
R   dFSEE0 8.6472220
R dUSEEnll 0.0258751
R   duSEEl 0.0133751
R   vceMax 2.8855565
R    LPEE0 0.9905346
R     FPEE 2.7017685
R    nuPEE 1.5393675
R    dWasc 0.6367632
R  nuCEasc 1.6153874
R    dWdes 0.5891361
R  nuCEdes 1.1737874
R     Arel 0.1394472
R     Brel 0.4023828
R     Secc 11.294890
R     Fecc 1.2715590
R    dtInt 0.0000500
R    dtOut 0.0100000
R  tdnToCe 0.7050328
RlpAHL2002 0.0769762
RlpBHL2002 0.0750464
Rlp0HL2002 0.0760113
R lp0K1994 0.0776096
*PARAMETER_EXPRESSION
$#    name expression
R       kt &dFSEE0/(&duSEEl*&ltSlk)
*END
