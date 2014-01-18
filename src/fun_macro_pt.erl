-module(fun_macro_pt).

-export([parse_transform/2]).

parse_transform(AST, _Options) ->
    lists:map(fun parse_transoform_function/1, AST).

parse_transoform_function({function, _, Name, Arity, _} = F) ->
    F1 = erl_syntax_lib:map(fun ({atom, L, '__$$FUNCTION_NAME_MACRO$$__'})  -> {atom, L, Name};     (N) -> erl_syntax:revert(N) end, F),
    F2 = erl_syntax_lib:map(fun ({atom, L, '__$$FUNCTION_ARITY_MACRO$$__'}) -> {integer, L, Arity}; (N) -> erl_syntax:revert(N) end, F1),
    F3 = apply_args_macro(F2),
    F3;
parse_transoform_function(F) -> F.

apply_args_macro({function, Line, Name, Arity, Clauses}) ->
    NewClauses = lists:map(fun apply_args_macro_clause/1, Clauses),
    {function, Line, Name, Arity, NewClauses}.

apply_args_macro_clause({clause, Line, Params, Guards, Body} = Clause) ->
    Num = erl_syntax_lib:fold(fun ({atom, _, '__$$FUNCTION_ARGS_MACRO$$__'}, N) -> N + 1; (_, N) -> N end, 0, {block, Line, Body}),
    case Num > 0 of
        true ->
            ParamNum = erlang:length(Params),
            ArgsVarNames = [arg_var(N) || N <- lists:seq(1, ParamNum)],
            NewParams = lists:map(fun ({P, AN}) -> {match, Line, {var, Line, AN}, P} end, lists:zip(Params, ArgsVarNames)),
            erl_syntax_lib:map(
                fun ({atom, L, '__$$FUNCTION_ARGS_MACRO$$__'}) ->
                        erl_syntax:revert(erl_syntax:list([{var, L, N} || N <- ArgsVarNames]));
                    (N) ->
                        erl_syntax:revert(N)
                end, {clause, Line, NewParams, Guards, Body});
        false ->
            Clause
    end.

arg_var(N) ->
   erlang:list_to_atom("__$$FUNCTION_ARGS_MACRO_VAR" ++ erlang:integer_to_list(N) ++ "$$__").

