%% @hidden

-module (ec2erlcloudnodefindersup).
-behaviour (supervisor).

-export ([ start_link/6, init/1 ]).

%-=====================================================================-
%-                                Public                               -
%-=====================================================================-

start_link (Group, PingTimeout, PrivateKey, Cert, Ec2Home, JavaHome) ->
  supervisor:start_link 
    (?MODULE, 
     [ Group, PingTimeout, PrivateKey, Cert, Ec2Home, JavaHome ]).

init ([ Group, PingTimeout, PrivateKey, Cert, Ec2Home, JavaHome ]) ->
  { ok,
    { { one_for_one, 3, 10 },
      [ { ec2erlcloudnodefindersrv,
          { ec2erlcloudnodefindersrv, 
            start_link,
            [ Group, PingTimeout, PrivateKey, Cert, Ec2Home, JavaHome ] },
          permanent,
          10000,
          worker,
          [ ec2erlcloudnodefindersrv ]
        }
      ]
    }
  }.
