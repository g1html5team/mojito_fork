library mojito;

import 'dart:async';
import 'src/context.dart';
import 'src/context_impl.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_exception_response/exception_response.dart';
import 'package:shelf_bind/shelf_bind.dart';
import 'package:shelf_auth/shelf_auth.dart' as sa;
import 'package:shelf_auth/src/principal/user_lookup.dart'; // TODO
import 'package:shelf_route/shelf_route.dart' as r;
import 'package:option/option.dart';
import 'package:shelf_proxy/shelf_proxy.dart';

Mojito init() => new Mojito();

class Mojito {
  r.Router _rootRouter;
  r.Router get router {
    if (_rootRouter == null) {
      _rootRouter = r.router(handlerAdapter: handlerAdapter());
    }

    return _rootRouter;
  }

  Handler _pubServeHandler;

  void proxyPubServe({int port: 8080}) {
    _pubServeHandler = proxyHandler("http://localhost:$port");
  }

  Handler get handler {
    r.printRoutes(router);

    var cascade = new Cascade()
      .add(router.handler);

    if (_pubServeHandler != null) {
      cascade = cascade.add(_pubServeHandler);
    }

    var pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(exceptionResponse());

    if (auth._middleware != null) {
      pipeline = pipeline.addMiddleware(auth._middleware);
    }

    final handler = pipeline.addHandler(cascade.handler);

    return _wrapHandler(handler);
  }


  final MojitoAuth auth = new MojitoAuth._internal();

  MojitoContext get context => _getContext();

  void start({ int port: 9999 }) {
    io.serve(handler, 'localhost', port)
        .then((server) {
      print('Proxying at http://${server.address.host}:${server.port}');
    });
  }


}

MojitoContext _getContext() => context;

class MojitoAuth {
  Middleware _middleware;

  MojitoAuth._internal();

  void basic(UserLookupByUsernamePassword userLookup,
             { bool allowHttp: false }) {
    _middleware = createBasic(userLookup, allowHttp: allowHttp);
  }

  Middleware createBasic(UserLookupByUsernamePassword userLookup,
                   { bool allowHttp: false }) {
    return createAuth([new sa.BasicAuthenticator(userLookup)],
        allowHttp: allowHttp);
  }


  void authenticate(Iterable<sa.Authenticator> authenticators,
                          { sa.SessionHandler sessionHandler,
                            bool allowHttp: false,
                            bool allowAnonymousAccess: true }) {

    _middleware = createAuth(authenticators, sessionHandler: sessionHandler,
        allowHttp: allowHttp, allowAnonymousAccess: allowAnonymousAccess);
  }

  Middleware createAuth(Iterable<sa.Authenticator> authenticators,
                          { sa.SessionHandler sessionHandler,
                            bool allowHttp: false,
                            bool allowAnonymousAccess: true }) {
    return sa.authenticate(authenticators.toList(growable: false),
        sessionHandler: sessionHandler, allowHttp: allowHttp,
        allowAnonymousAccess: allowAnonymousAccess);
  }
}



const Symbol _MOJITO_CONTEXT = #mojito_context;


final MojitoContext context = new MojitoContextImpl();

///**
// * Returns the [MojitoContext] of the current request.
// *
// * This getter can only be called inside a request handler which was passed to
// * [runAppEngine].
// */
//MojitoContext get context {
//  var context = Zone.current[_MOJITO_CONTEXT];
//  if (context == null) {
//    throw new StateError(
//        'Could not retrieve the request handler context. You are likely calling'
//        ' this method outside of the request handler zone.');
//  }
//  return context;
//}

Handler _wrapHandler(Handler handler) {
  return (Request request) {
    var response;

    runZoned(() {
      response = handler(request);
    }, zoneValues: <Symbol, Object>{
      _MOJITO_CONTEXT: contextFromRequest(request)
//    }, onError: (error, stack) {
//      print('!!!!!! $error\n$stack');
//      var context = appengine_internal.contextFromRequest(request);
//      if (context != null) {
//        try {
//          context.services.logging.error(
//              'Uncaught error in request handler: $error\n$stack');
//        } catch (e) {
//          print('Error while logging uncaught error: $e');
//        }
//      } else {
//        // TODO: We could log on the background ticket here.
//        print('Unable to log error, since response has already been sent.');
//      }
//      errorHandler('Uncaught error in request handler zone: $error', stack);

//      // In many cases errors happen during request processing or response
//      // preparation. In such cases we want to close the connection, since user
//      // code might not be able to.
//      try {
//        request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
//      } on StateError catch (_) {}
//      request.response.close().catchError((closeError, closeErrorStack) {
//        errorHandler('Forcefully closing response, due to error in request '
//                     'handler zone, resulted in an error: $closeError',
//                     closeErrorStack);
//      });
    });

    return response;
  };
}



