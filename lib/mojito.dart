library mojito;

import 'dart:async';
import 'src/context.dart';
import 'src/context_impl.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_exception_response/exception_response.dart';
import 'package:shelf_bind/shelf_bind.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:shelf_auth/src/principal/user_lookup.dart'; // TODO
import 'package:shelf_route/shelf_route.dart' as r;
import 'package:option/option.dart';

Mojito init() => new Mojito();

class Mojito {
  r.Router _rootRouter;

  r.Router get router {
    if (_rootRouter == null) {
      _rootRouter = r.router(handlerAdapter: handlerAdapter());
    }

    return _rootRouter;
  }

  void start({ int port: 9999 }) {
    io.serve(handler, 'localhost', port)
        .then((server) {
      print('Proxying at http://${server.address.host}:${server.port}');
    });
  }

  Handler get handler {
    r.printRoutes(router);

    var cascade = new Cascade()
      .add(router.handler);

//    if (proxyPubServe) {
//      cascade = cascade.add(pubServeHandler);
//    }
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
    return authenticate([new BasicAuthenticator(userLookup)],
        allowHttp: allowHttp);
  }


  Middleware authenticate(Iterable<Authenticator> authenticators,
                          { SessionHandler sessionHandler,
                            bool allowHttp: false,
                            bool allowAnonymousAccess: true }) {
    final authMiddleware = new AuthenticationMiddleware(authenticators.toList(growable: false),
        new Option(sessionHandler), allowHttp: allowHttp,
        allowAnonymousAccess: allowAnonymousAccess)
      .middleware;

    Option<AuthenticatedContext> previousAuthContext;

    final preMiddleware = createMiddleware(requestHandler: (Request r) {
      previousAuthContext = getAuthenticatedContext(r);
      return null;
    });

    final postMiddleware = createMiddleware(requestHandler: (Request r) {
      final postAuthContext = getAuthenticatedContext(r);
      if (postAuthContext != previousAuthContext) {
        setAuthContext(postAuthContext);
      }

      return null;
    });

    return const Pipeline()
        .addMiddleware(preMiddleware)
        .addMiddleware(authMiddleware)
        .addMiddleware(postMiddleware)
        .middleware;
  }


}



const Symbol _MOJITO_CONTEXT = #mojito_context;


/**
 * Returns the [MojitoContext] of the current request.
 *
 * This getter can only be called inside a request handler which was passed to
 * [runAppEngine].
 */
MojitoContext get context {
  var context = Zone.current[_MOJITO_CONTEXT];
  if (context == null) {
    throw new StateError(
        'Could not retrieve the request handler context. You are likely calling'
        ' this method outside of the request handler zone.');
  }
  return context;
}

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



