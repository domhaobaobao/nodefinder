%% @hidden

-module (nodefindersup).
-behaviour (supervisor).

-export ([ start_link/3, start_link/4, init/1 ]).

%-=====================================================================-
%-                                Public                               -
%-=====================================================================-

start_link (Addr, Port, MulticastIntAddr) ->
  start_link (Addr, Port, 1, MulticastIntAddr).

start_link (Addr, Port, Ttl, MulticastIntAddr) ->
  supervisor:start_link (?MODULE, [ Addr, Port, Ttl, MulticastIntAddr]).

%-=====================================================================-
%-                         Supervisor callbacks                        -
%-=====================================================================-

init ([ Addr, Port, Ttl, MulticastIntAddr]) ->
  { ok,
    { { one_for_one, 3, 10 },
      [ { nodefindersrv,
          { nodefindersrv, start_link, [ Addr, Port, Ttl, MulticastIntAddr ] },
          permanent,
          1000,
          worker,
          [ nodefindersrv ]
        }
      ]
    }
  }.
