%%%-------------------------------------------------------------------
%%% File    : abc_lib.erl
%%% Author  : alvin <>
%%% Description : 
%%%
%%% Created : 20 Jun 2008 by alvin <>
%%%-------------------------------------------------------------------
-module(abc_lib).

-export([]).

-compile(export_all).

-include("code_map.hrl").
-include("abc_lib.hrl").

%%%-------------------------------------------------------------------
decode_abc(<<Minor:?u(16),Major:?u(16),Rest/binary>>) ->
    FunList = [fun decode_const/1,
               fun decode_method/1,
               fun decode_meta/1,
               fun decode_class/1,
               fun decode_script/1,
               fun decode_method_body/1
              ],

    {[Const|_Other],_CurRest} = 
        lists:mapfoldl(fun apply_bin/2,Rest,FunList),

    %% io:format("~P~n",[Const,100]),
    #abc{ver={Major,Minor},
         const=Const
        }.

%%%-------------------------------------------------------------------
decode_const(Bin) ->
    FunList = [fun decode_const_int/1,
               fun decode_const_uint/1,
               fun decode_const_double/1,
               fun decode_const_string/1,
               fun decode_const_ns/1,
               fun decode_const_ns_set/1,
               fun decode_const_mname/1
              ],

    lists:mapfoldl(fun apply_bin/2,Bin,FunList).

decode_const_int(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    loop(Count-1,fun decode_s32/1,Rest,[]).

decode_const_uint(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    loop(Count-1,fun decode_u32/1,Rest,[]).

decode_const_double(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    loop(Count-1,fun decode_d64/1,Rest,[]).

decode_const_string(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    loop(Count-1,fun decode_string/1,Rest,[]).

decode_const_ns(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    loop(Count-1,fun decode_ns/1,Rest,[]).

decode_const_ns_set(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    loop(Count-1,fun decode_ns_set/1,Rest,[]).

decode_const_mname(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    loop(Count-1,fun decode_mname/1,Rest,[]).

%%%-------------------------------------------------------------------
decode_method(Bin) -> 
    {Count,Rest} = decode_u30(Bin),
    loop(Count-1,fun decode_method_info/1,Rest,[]).

decode_method_info(Bin) -> 
    %% {ParamCount,R1} = decode_u30(Bin),
    %% {ReturnType,R2} = decode_u30(R1),
    %% {ParamType,R3} = loop(ParamCount,fun decode_u30/1,R2,[]),
    %% {Name,R4} = decode_u30(R3),
    %% {Flag,R5} = decode_method_flag(R4),
    %% {Opt,R6} = if Flag#method_flag.has_opt =:= 1 ->
    %%                    decode_option_info(R5);
    %%               true -> {{},R5} end,
    
    {}.
    
%% decode_method_flag(Bin) ->
%%     <<HP:1,SD:1,_:2,HO:1,NR:1,NAct:1,_:NArg,Rest/binary>> = Bin,
    
%%     Flag = #method_flag{need_arg=NArg,
%%                         need_act=NAct,
%%                         need_rest=NR,
%%                         has_opt=NO,
%%                         set_dxns=SD,
%%                         has_param=HP
%%                        },
%%     {Flag,Rest}.

decode_option_info(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    loop(Count-1,fun decode_option_detail/1,Rest,[]).
    
decode_option_detail(Bin) -> {}.
    
%%%-------------------------------------------------------------------
decode_meta(Bin) -> {{},Bin}.

%%%-------------------------------------------------------------------
decode_class(Bin) -> {{},Bin}.

%%%-------------------------------------------------------------------
decode_script(Bin) -> {{},Bin}.

%%%-------------------------------------------------------------------
decode_method_body(Bin) -> {{},Bin}.

%%%-------------------------------------------------------------------
decode_u30(Bin) ->
    decode_vint(Bin,30,0,false,[]).

decode_u32(Bin) ->
    decode_vint(Bin,32,0,false,[]).

decode_s32(Bin) ->
    decode_vint(Bin,32,0,true,[]).

decode_d64(<<Val:?d64,Rest/binary>>) ->
    {Val,Rest};
decode_d64(<<Val:64/integer,Rest/binary>>) ->
    Ret = case <<Val:?u(64)>> of
              <<1:1,2047:11,0:52>> -> 'Infinity';
              <<0:1,2047:11,0:52>> -> '-Infinity';
              <<_:1,2047:11,_:52>> -> 'NaN'
          end,
    {Ret,Rest}.

decode_string(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    <<Str:Count/binary,CurRest/binary>> = Rest,
    {Str,CurRest}.

decode_ns(<<Kind:?u(8),Rest/binary>>) ->
    {Name,CurRest} = decode_u30(Rest),
    {{?decode(ns_kind,Kind),Name},CurRest}.

decode_ns_set(Bin) ->
    {Count,Rest} = decode_u30(Bin),
    loop(Count,fun decode_u30/1,Rest,[]).

decode_mname(<<KindCode:?u(8),Rest/binary>>) ->
    Kind = ?decode(mname_kind,KindCode),
    {Data,CurRest} = decode_mname(Kind,Rest),
    {{Kind,Data},CurRest}.

decode_mname('QName',Bin) ->
    FunList = [fun decode_u30/1,
               fun decode_u30/1],
    
    {[Ns,Name],Rest} = lists:mapfoldl(fun apply_bin/2,Bin,FunList),
    {{Ns,Name},Rest};
decode_mname('QNameA',Bin) ->
    decode_mname('QName',Bin);

decode_mname('RTQName',Bin) ->
    decode_u30(Bin);
decode_mname('RTQNameA',Bin) ->
    decode_mname('RTQName',Bin);

decode_mname('RTQNameL',Bin) ->
    {{},Bin};
decode_mname('RTQNameLA',Bin) ->
    decode_mname('RTQNameL',Bin);

decode_mname('Multiname',Bin) ->
    FunList = [fun decode_u30/1,
               fun decode_u30/1],
    
    {[Name,NsSet],Rest} = lists:mapfoldl(fun apply_bin/2,Bin,FunList),
    {{Name,NsSet},Rest};
decode_mname('MultinameA',Bin) ->
    decode_mname('Multiname',Bin);

decode_mname('MultinameL',Bin) ->
    decode_u30(Bin);
decode_mname('MultinameLA',Bin) ->
    decode_u30(Bin).

decode_list(Bin,CountFun,ItemFun) ->
    {Count,Rest} = CountFun(Bin),
    loop(Count-1,ItemFun,Rest,[]).

%%%-------------------------------------------------------------------
decode_vint(<<1:1,Bit:7/bits,Rest/binary>>,Size,Acc,Signed,Bits) when Size > Acc ->
    decode_vint(Rest,Size,Acc+7,Signed,[Bit|Bits]);

decode_vint(<<0:1,Bit:7/bits,Rest/binary>>,Size,Acc,Signed,Bits) when Size > Acc ->
    CurBin = combine_bits([Bit|Bits]),
    CurAcc = Acc + 7,
    {CurSize,PadSize} = if Size > CurAcc -> {CurAcc,0};
                           true -> {Size,CurAcc-Size} end,

    Ret = if Signed -> <<_Pad:PadSize,Val:CurSize/signed>> = CurBin,Val;
             true ->  <<_Pad:PadSize,Val:CurSize/unsigned>> = CurBin,Val end,

    %% trace_vint([Bit|Bits],Size,CurAcc,CurSize,Signed,Ret),
          
    {Ret,Rest}.

combine_bits(Bits) -> lists:foldl(fun combine_bit/2,<<>>,Bits).
combine_bit(Bit,Acc) -> <<Acc/bits,Bit/bits>>.
    
%% trace_vint(Bits,Size,Acc,CurSize,Signed,Ret) ->
%%     io:format("~-26w",[{Size,Acc,CurSize,Signed,Ret}]),

%%     ShowBits = fun(Bit) ->
%%                        <<Val:7>> = Bit,
%%                        io:format(" |~9w~7.2.0B",[Bit,Val]) 
%%                end,

%%     lists:map(ShowBits,Bits),
    
%%     io:format("~n",[]).

%%%-------------------------------------------------------------------
loop(Count,Fun,Rest,Acc) when Count > 0->
    {Ret,CurRest} = Fun(Rest),
    loop(Count-1,Fun,CurRest,[Ret|Acc]);

loop(_Count,_Fun,Rest,Acc) -> 
    {lists:reverse(Acc),Rest}.

apply_bin(Fun,Bin) -> Fun(Bin).

%%%-------------------------------------------------------------------
?DefCodeMap(ns_kind, 'Namespace',          16#08);
?DefCodeMap(ns_kind, 'PackageNamespace',   16#16);
?DefCodeMap(ns_kind, 'PackageInternalNs',  16#17);
?DefCodeMap(ns_kind, 'ProtectedNamespace', 16#18);
?DefCodeMap(ns_kind, 'ExplicitNamespace',  16#19);
?DefCodeMap(ns_kind, 'StaticProtectedNs',  16#1A);
?DefCodeMap(ns_kind, 'PrivateNs',          16#05);

?DefCodeMap(mname_kind, 'QName',       16#07);
?DefCodeMap(mname_kind, 'QNameA',      16#0D);
?DefCodeMap(mname_kind, 'RTQName',     16#0F);
?DefCodeMap(mname_kind, 'RTQNameA',    16#10);
?DefCodeMap(mname_kind, 'RTQNameL',    16#11);
?DefCodeMap(mname_kind, 'RTQNameLA',   16#12);
?DefCodeMap(mname_kind, 'Multiname',   16#09);
?DefCodeMap(mname_kind, 'MultinameA',  16#0E);
?DefCodeMap(mname_kind, 'MultinameL',  16#1B);
?DefCodeMap(mname_kind, 'MultinameLA', 16#1C);

?DefCodeMap(_, Unknown, Unknown).
