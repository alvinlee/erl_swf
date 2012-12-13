-define(u(Num),Num/unsigned-little-integer).
-define(s(Num),Num/signed-little-integer).
-define(d64,64/signed-little-float).

-record(abc,{
          ver,
          const,
          method,
          meta,
          inst,
          class,
          script,
          method_body
         }).

-record(abc_const,{
          int,
          uint,
          double,
          string,
          ns,
          ns_set,
          mname
         }).

-record(abc_method,{
          return_type,
          param_type,
          name,
          flags,
          param_names
         }).

-record(abc_method_flag,{
          need_arg,
          need_act,
          need_rest,
          has_opt,
          set_dxns,
          has_param
         }).
