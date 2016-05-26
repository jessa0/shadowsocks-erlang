%%%-------------------------------------------------------------------
%% @doc sserl public API
%% @end
%%%-------------------------------------------------------------------

-module(sserl_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    case sserl_sup:start_link() of
        {ok, Pid} ->
            start_listeners(),
            {ok, Pid};
        Error ->
            Error
    end.

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
start_listeners() ->
    {ok, App} = application:get_application(),
    Listeners = application:get_env(App, listeners, []),
    Listeners1 = Listeners ++ sserl_config:load_startup(),
    lists:map(fun(Args) ->
                      case sserl_listener_sup:start(Args) of
                          {ok, Pid} ->
                              error_logger:info_msg("~p start listener ~p ok (pid:~p)", [?MODULE, Args, Pid]),
                              ok;
                          Error ->
                              error_logger:error_msg("~p start listener ~p error:~p", [?MODULE, Args, Error]),
                              throw({error, Error})
                      end
              end, Listeners1),
    ok.