+++
title = "Example - integrating shelf_rpc"
date = "2016-01-31T09:35:03+11:00"
description = "Example - integrating shelf_rpc"
weight = 81
type = "post"
+++


```

import 'package:mojito/mojito.dart';
import 'package:shelf_rpc/shelf_rpc.dart' as shelf_rpc;
import 'package:rpc/rpc.dart';

main() {

  var app = init();

  var apiServer = <create rpc apiServer somehow>;
  // create a shelf handler from the api
  var handler = shelf_rpc.createRpcHandler(apiServer);

  // create a route for the handler. 
  app.router
    ..add('rpc', null, handler, exactMatch: false);

  app.start();
}

```

Note `exactMatch: false` is needed as shelf_rpc serves many sub routes. Also
passing `null` as the value of the `methods` argument is used so that all
methods are passed to the api.
