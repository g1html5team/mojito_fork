library mojito;

import 'context.dart';
import 'package:shelf/shelf.dart';
import 'router.dart';
import 'auth.dart';
import 'mojito_impl.dart' as impl;
import 'middleware.dart';

typedef Router RouteCreator();

Mojito init({ RouteCreator createRootRouter, bool logRequests: true }) =>
    new impl.MojitoImpl(createRootRouter, logRequests);

abstract class Mojito {
  Router get router;
  MojitoAuth get auth;
  MojitoMiddleware get middleware;
  MojitoContext get context;
  Handler get handler;

  void proxyPubServe({int port: 8080});

  void start({ int port: 9999 });
}


MojitoContext get context => impl.context;