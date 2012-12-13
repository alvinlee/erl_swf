%%%-------------------------------------------------------------------
%%% File    : swf_lib.erl
%%% Author  : alvin <>
%%% Description : 
%%%
%%% Created : 17 Jun 2008 by alvin <>
%%%-------------------------------------------------------------------
-module(swf_lib).

-export([]).

-compile(export_all).

-include("coder.hrl").
-include("swf.hrl").

%%%-------------------------------------------------------------------
?DefCodeMap(tag_type, 'End',                          0); 
?DefCodeMap(tag_type, 'ShowFrame',                    1); 
?DefCodeMap(tag_type, 'DefineShape',                  2); 
?DefCodeMap(tag_type, 'PlaceObject',                  4); 
?DefCodeMap(tag_type, 'RemoveObject',                 5); 
?DefCodeMap(tag_type, 'DefineBits',                   6); 
?DefCodeMap(tag_type, 'DefineButton',                 7); 
?DefCodeMap(tag_type, 'JPEGTables',                   8); 
?DefCodeMap(tag_type, 'SetBackgroundColor',           9); 
?DefCodeMap(tag_type, 'DefineFont',                   10); 
?DefCodeMap(tag_type, 'DefineText',                   11); 
?DefCodeMap(tag_type, 'DoAction',                     12); 
?DefCodeMap(tag_type, 'DefineFontInfo',               13); 
?DefCodeMap(tag_type, 'DefineSound',                  14); 
?DefCodeMap(tag_type, 'StartSound',                   15); 
?DefCodeMap(tag_type, 'DefineButtonSound',            17); 
?DefCodeMap(tag_type, 'SoundStreamHead',              18); 
?DefCodeMap(tag_type, 'SoundStreamBlock',             19); 
?DefCodeMap(tag_type, 'DefineBitsLossless',           20); 
?DefCodeMap(tag_type, 'DefineBitsJPEG2',              21); 
?DefCodeMap(tag_type, 'DefineShape2',                 22); 
?DefCodeMap(tag_type, 'DefineButtonCxform',           23); 
?DefCodeMap(tag_type, 'Protect',                      24); 
?DefCodeMap(tag_type, 'PlaceObject2',                 26); 
?DefCodeMap(tag_type, 'RemoveObject2',                28); 
?DefCodeMap(tag_type, 'DefineShape3',                 32); 
?DefCodeMap(tag_type, 'DefineText2',                  33); 
?DefCodeMap(tag_type, 'DefineButton2',                34); 
?DefCodeMap(tag_type, 'DefineBitsJPEG3',              35); 
?DefCodeMap(tag_type, 'DefineBitsLossless2',          36); 
?DefCodeMap(tag_type, 'DefineEditText',               37); 
?DefCodeMap(tag_type, 'DefineSprite',                 39); 
?DefCodeMap(tag_type, 'FrameLabel',                   43); 
?DefCodeMap(tag_type, 'SoundStreamHead2',             45); 
?DefCodeMap(tag_type, 'DefineMorphShape',             46); 
?DefCodeMap(tag_type, 'DefineFont2',                  48); 
?DefCodeMap(tag_type, 'ExportAssets',                 56); 
?DefCodeMap(tag_type, 'ImportAssets',                 57); 
?DefCodeMap(tag_type, 'EnableDebugger',               58); 
?DefCodeMap(tag_type, 'DoInitAction',                 59); 
?DefCodeMap(tag_type, 'DefineVideoStream',            60); 
?DefCodeMap(tag_type, 'VideoFrame',                   61); 
?DefCodeMap(tag_type, 'DefineFontInfo2',              62); 
?DefCodeMap(tag_type, 'EnableDebugger2',              64); 
?DefCodeMap(tag_type, 'ScriptLimits',                 65); 
?DefCodeMap(tag_type, 'SetTabIndex',                  66); 
?DefCodeMap(tag_type, 'FileAttributes',               69); 
?DefCodeMap(tag_type, 'PlaceObject3',                 70); 
?DefCodeMap(tag_type, 'ImportAssets2',                71); 
?DefCodeMap(tag_type, 'DefineFontAlignZones',         73); 
?DefCodeMap(tag_type, 'CSMTextSettings',              74); 
?DefCodeMap(tag_type, 'DefineFont3',                  75); 
?DefCodeMap(tag_type, 'SymbolClass',                  76); 
?DefCodeMap(tag_type, 'Metadata',                     77); 
?DefCodeMap(tag_type, 'DefineScalingGrid',            78); 
?DefCodeMap(tag_type, 'DoABC',                        82); 
?DefCodeMap(tag_type, 'DefineShape4',                 83); 
?DefCodeMap(tag_type, 'DefineMorphShape2',            84); 
?DefCodeMap(tag_type, 'DefineSceneAndFrameLabelData', 86); 
?DefCodeMap(tag_type, 'DefineBinaryData',             87); 
?DefCodeMap(tag_type, 'DefineFontName',               88); 
?DefCodeMap(tag_type, 'StartSound2',                  89);
?DefCodeMap(tag_type, Unknown, Unknown).

%%%-------------------------------------------------------------------
decode_file(Filename) ->
    {ok, Binary} = file:read_file(Filename),
    {Header,Rest} = decode(header,Binary),
    Tags = decode(tag,Rest),
    {Header,Tags}.

%% decode(<<Sig:3/binary,Ver:?UI8,Len:?UI32,Bin/binary>>) ->
%%     {next,fun decode_body/1}.

%%%-------------------------------------------------------------------
decode(rect,<<?RECT(NBits,Xmin,Xmax,Ymin,Ymax),Rest/bits>>) ->
    Rect = #swf_rect{xmin=Xmin/20,
                     xmax=Xmax/20,
                     ymin=Ymin/20,
                     ymax=Ymax/20},
    Pad = ?RECTPAD(NBits),
    <<_:Pad,RetRest/binary>> = Rest,
    {Rect,RetRest};

decode(string,Bin) ->
    Len = find_str_len(Bin,0),
    <<Str:Len/binary,0,Rest/binary>> = Bin,
    {Str,Rest};

decode(string_fix,Bin) ->
    Len = size(Bin)-1,
    <<StrBin:Len/binary,0>> = Bin,
    StrBin;

%%%-------------------------------------------------------------------
decode(header,<<Sig:3/binary,Ver:?UI8,Len:?UI32,Rest/binary>>) ->
    Raw = case Sig of
              <<"FWS">> -> Rest;
              <<"CWS">> -> zlib:uncompress(Rest)
          end,
    
    {Size,RectRest} = decode(rect,Raw),
    <<Rate:?UI16,Count:?UI16,RetRest/binary>> = RectRest,

    Header = #swf_header{sig=Sig,
                         ver=Ver,
                         len=Len,
                         size=Size,
                         rate=Rate/2#100000000,
                         count=Count},
    {Header,RetRest};

%%%-------------------------------------------------------------------
decode(tag,<<Tag:?UI16,Rest/binary>>) ->
    <<Type:?UB(10),Len:?UB(6)>> = <<Tag:?UB(16)>>,
    TypeName = ?decode(tag_type,Type),
    case Len of
        16#3F -> 
            <<ExtLen:?SI32,Record:ExtLen/binary,RetRest/binary>> = Rest,
            {{TypeName,Record},RetRest};
        _ ->
            <<Record:Len/binary,RetRest/binary>> = Rest,
            {{TypeName,Record},RetRest}
    end;

%% control record
decode(record,{'SetBackgroundColor',<<R:?UI8,G:?UI8,B:?UI8>>}) ->
    {'SetBackgroundColor',{R,G,B}};

decode(record,{'FrameLabel',Record}) ->
    {'FrameLabel',decode(string_fix,Record)};

decode(record,{'EnableDebugger2',<<_Reserved:?UI16,Passwd/binary>>}) ->
    {'EnableDebugger2',decode(string_fix,Passwd)};

decode(record,{'ScriptLimits',<<RecurDepth:?UI16,Timeout:?UI16>>}) ->
    {'ScriptLimits', RecurDepth, Timeout};

decode(record,{'FileAttributes',
               <<0:?UB(3),Meta:?UB(1),AS3:?UB(1),0:?UB(2),Net:?UB(1),_:?UB(24)>>}) ->
    {'FileAttributes', Meta, AS3, Net};

decode(record,{'SymbolClass',<<Num:?UI16,Rest/binary>>}) ->
    Symbols = split_tag_name(Rest,[]),
    Num = length(Symbols),
    {'SymbolClass',Symbols};

%% action record
decode(record,{'DoABC',<<Flags:?UI32,Rest/binary>>}) ->
    {Name,RawAbc} = decode(string,Rest),
    %% Abc = abc_lib:decode_abc(RawAbc),
    {'DoABC',Flags,Name,RawAbc};

%% unknown record
decode(record,{TypeName,_Record}) -> {TypeName};

decode(_Type,_Bin) ->
    conti.

%%%-------------------------------------------------------------------
find_str_len(<<0,_/binary>>,Len) -> Len;

find_str_len(<<_:1/binary,Rest/binary>>,Len) ->
    find_str_len(Rest,Len+1).

split_tag_name(<<Tag:?UI16,Rest/binary>>,Last) ->
    {Name,Next} = decode(string,Rest),
    split_tag_name(Next,[{Tag,Name}|Last]);

split_tag_name(_,Last) ->
    lists:reverse(Last).

test() ->
    Code = swf_lib:decode_file("/home/alvin/flash/swc/library.swf"),
    io:format("~p~n",[Code]).    

