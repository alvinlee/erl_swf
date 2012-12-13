-define(UB(Num),Num/unsigned-big-integer).
-define(SB(Num),Num/signed-big-integer).

-define(UBL(Num),Num/unsigned-little-integer).
-define(SBL(Num),Num/signed-little-integer).

-define(UI8,?UBL(8)).
-define(UI16,?UBL(16)).
-define(UI32,?UBL(32)).

-define(SI8,?SBL(8)).
-define(SI16,?SBL(16)).
-define(SI32,?SBL(32)).

-define(RECT(NBits,Xmin,Xmax,Ymin,Ymax),
        NBits:?UB(5),
        Xmin:?SB(NBits),Xmax:?SB(NBits),
        Ymin:?SB(NBits),Ymax:?SB(NBits)).

-define(RECTPAD(NBits),(8-((5+4*NBits) rem 8))).

-record(swf_rect,{
          xmin,
          xmax,
          ymin,
          ymax
         }).

-record(swf_header,{
          sig,
          ver,
          len,
          size,
          rate, %% 8.8 fixed
          count
         }).
