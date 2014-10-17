library mojito;

import 'context.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_route/shelf_route.dart' as r;
import 'auth.dart';
import 'mojito_impl.dart' as impl;

typedef r.Router RouteCreator();

Mojito init({ RouteCreator createRootRouter }) =>
    new impl.MojitoImpl(createRootRouter);

abstract class Mojito {
  r.Router get router;
  MojitoAuth get auth;
  MojitoContext get context;
  Handler get handler;

  void proxyPubServe({int port: 8080});

  void start({ int port: 9999 });
}


MojitoContext get context => impl.context;