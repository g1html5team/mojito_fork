library mojito;

import 'src/context.dart';
import 'src/context_impl.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:shelf_route/shelf_route.dart' as r;
import 'src/internal.dart';

typedef r.Router RouteCreator();

Mojito init({ RouteCreator createRootRouter }) =>
    new MojitoImpl(createRootRouter);

abstract class Mojito {
  r.Router get router;
  MojitoAuth get auth;
  MojitoContext get context;
  Handler get handler;

  void proxyPubServe({int port: 8080});

  void start({ int port: 9999 });
}


abstract class MojitoAuth {

  /// builder for authenitcation middleware to be applied all routes
  AuthenticationBuilder get global;

  /// builder for authenitcation middleware that you choose where to include
  AuthenticationBuilder builder();
}

final MojitoContext context = new MojitoContextImpl();

