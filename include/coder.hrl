-define(DefCode(Type,Cata,Src,Dst), code(Type,Cata,Src)->Dst).

-define(DefCodeMap(Cata,Atom,Code),
        ?DefCode(encode,Cata,Atom,Code);
        ?DefCode(decode,Cata,Code,Atom)
       ).

-define(encode(Cata,Atom),code(encode,Cata,Atom)).
-define(decode(Cata,Code),code(decode,Cata,Code)).
