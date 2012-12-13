%%%-------------------------------------------------------------------
%%% File    : swf_file.erl
%%% Author  : alvin <>
%%% Description : 
%%%
%%% Created : 31 Oct 2008 by alvin <>
%%%-------------------------------------------------------------------
-module(swf_file).

%% API
-export([]).

-include("coder.hrl").
-include("swf.hrl").

-record(?MODULE,{header,frag,z,cur,func,cookie}).

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

%%====================================================================
%% API
%%====================================================================
%% decode_file(Bin) ->
%%     Reader = reader:init(fun decode_header/1,8,[]),
%%     {Rets,_} = Reader:read(Bin).

%%--------------------------------------------------------------------
%% decode_header(<<Sig:3/binary,Ver:?UI8,Len:?UI32>>) ->
%%     Reader:return(fun decode_tag/1,2,[],{Sig,Ver,Len}).

%% %%--------------------------------------------------------------------
%% decode_tag(<<Type:?UB(10),16#3F:?UB(6),Bin/binary>>) ->
%%     reader:cont(fun() -> decode_tag(Type,Bin) end,4);

%% decode_tag(<<Type:?UB(10),Len:?UB(6),Bin/binary>>) ->
%%     decode_tag(Type,Len,Bin).

%% decode_tag(Type,<<Len:?SI32,Bin/binary>>) ->
%%     decode_tag(Type,Len,Bin).
    
%% decode_tag(Type,Len,Bin) ->
%%     Name = ?decode(tag_type,Type),
%%     reader:cont(fun() -> decode_type(Name,Bin) end,Len).

%% %%--------------------------------------------------------------------
%% %% decode_type(xxx,Bin) ->.


    

%% %%--------------------------------------------------------------------

%% %%====================================================================
%% %% Internal functions
%% %%====================================================================
