Overview
--------

Useful macros, such as current function name, current function arguments, current function arity, etc.

Features
--------

Supported macros:

* ?FUNCTION - name of the current function, atom
* ?FUNCTION\_ARITY - arity of current function, non-negative integer
* ?ARGS - arguments of current function, list of terms

TODO
----

* ?FUNCTION\_STRING macro

Examples
--------

```erlang
-include_lib("funmacro/include/function_macros.hrl").

foo(O1, O2) ->
    io:format("Called: ~p/~p ~p", [?FUNCTION, ?FUNCTION_ARITY, ?ARGS]),
    ok.
```






