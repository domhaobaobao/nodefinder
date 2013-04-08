%% @doc nodefinder+ec2nodefinder service.
%% @end

-module (combonodefinder).
-export ([ discover/0 ]).
-behaviour (application).
-export ([ start/0, start/2, stop/0, stop/1 ]).

%-=====================================================================-
%-                                Public                               -
%-=====================================================================-

%% @spec discover () -> ok
%% @doc Initiate a discovery request.  Nodes will respond 
%% synchronously (on EC2) or asynchronously (not on EC2) 
%% and therefore should not necessarily be considered added to the 
%% erlang node list subsequent to this call returning.
%% @end

discover () ->
  case is_ec2_host () of
    true -> ec2nodefindersrv:discover ();
    false -> nodefindersrv:discover ()
  end.

%-=====================================================================-
%-                        application callbacks                        -
%-=====================================================================-

%% @hidden

start () ->
  crypto:start (),
  application:start (inets),
  application:start (combonodefinder).

%% @hidden

start (Type, Args) ->
  case is_ec2_host () of
    true -> start_ec2_mode(Type, Args);
    false -> nodefinder:start (Type, Args)
  end.

%% @hidden

start_ec2_mode(Type, Args) ->
  case application:get_env (combonodefinder, use_erlcloud) of
    true -> 
		ec2nodefinder:start (Type, Args);
	false -> 
		application:start (erlcloud), 
		ec2erlcloudnodefinder:start (Type, Args)
  end.

%% @hidden

stop () ->
  application:stop (combonodefinder).

%% @hidden

stop (State) ->
  case is_ec2_host () of
    true -> stop_ec2_mode (State);
    false -> nodefinder:stop (State)
  end.

%% @hidden

stop_ec2_mode(State) ->
  case application:get_env (combonodefinder, use_erlcloud) of
    true -> ec2nodefinder:stop (State);
	false -> ec2erlcloudnodefinder:stop (State)
  end.

%-=====================================================================-
%-                               Private                               -
%-=====================================================================-

is_ec2_host () ->
  Host = lists:last (string:tokens (atom_to_list (node ()), "@")),

  case lists:reverse (string:tokens (Host, ".")) of
    [ "com", "amazonaws" | _ ] -> true;
    _ -> false
  end.
