*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R   lceOpt 0.0428571
R   fceOpt 21.612138
R lceOptAT 0.0425376
R fceOptAT 21.451044
R lmtOptAT 0.0729888
R   penOpt 0.1221730
R  penOptD 7.0 
R    ltSlk 0.0304511
R       et 0.0458333
R   dFSEE0 14.300676
R dUSEEnll 0.0347222
R   duSEEl 0.0222222
R   vceMax 4.684921
R    LPEE0 1.034709
R     FPEE 1.194156
R    nuPEE 1.252480 
R    dWasc 0.5656740
R  nuCEasc 2.082109
R    dWdes 0.470961
R  nuCEdes 1.328409
R     Arel 0.1240458
R     Brel 0.5550417
R     Secc 0.7725022
R     Fecc 1.4391543
R    dtInt 0.00005
R    dtOut 0.010
RlceNScale 0.95
*PARAMETER_EXPRESSION
$#    name expression
R       kt &dFSEE0/(&duSEEl*&ltSlk)
*END

