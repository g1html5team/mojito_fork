library mojito;

import 'context.dart';
import 'context_impl.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_exception_response/exception_response.dart';
import 'package:shelf_bind/shelf_bind.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:shelf_route/shelf_route.dart' as r;
import 'package:shelf_proxy/shelf_proxy.dart';
import '../mojito.dart';

class MojitoImpl implements Mojito {
  final r.Router router;
  Handler _pubServeHandler;
  final MojitoAuthImpl auth = new MojitoAuthImpl._internal();
  MojitoContext get context => _getContext();
  Handler get handler => _createHandler();



  MojitoImpl(RouteCreator createRootRouter)
      : router = createRootRouter != null ? createRootRouter() :
          r.router(handlerAdapter: handlerAdapter());

  void proxyPubServe({int port: 8080}) {
    _pubServeHandler = proxyHandler("http://localhost:$port");
  }


  void start({ int port: 9999 }) {
    io.serve(handler, 'localhost', port)
        .then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
    });
  }

  Handler _createHandler() {
    if (_pubServeHandler != null) {
      router.add('/', ['GET'], (Request r) => _pubServeHandler(r),
          exactMatch: false);
    }

    r.printRoutes(router);

    var pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(exceptionResponse());

    if (auth._global != null) {
      final authMiddleware = auth._middleware != null ?  auth._middleware :
          auth._global.build();

      pipeline = pipeline.addMiddleware(authMiddleware);
    }

    final handler = pipeline.addHandler(router.handler);

//    return _wrapHandler(handler);
    return handler;
  }

}

// just a trick as Mojito has a property called context which points to this one
MojitoContext _getContext() => context;

class _GlobalAuthBuilder extends AuthenticationBuilder {
  final MojitoAuthImpl _ma;

  _GlobalAuthBuilder(this._ma);

  @override
  Middleware build() {
    final m = super.build();
    _ma._middleware = m;
    return m;
  }
}

class MojitoAuthImpl implements MojitoAuth {
  Middleware _middleware;
  AuthenticationBuilder _global;

  MojitoAuthImpl._internal();

  /// builder for authenitcation middleware to be applied all routes
  AuthenticationBuilder get global {
    if (_global == null) {
      _global = new _GlobalAuthBuilder(this);
    }
    return _global;
  }

  /// builder for authenitcation middleware that you choose where to include
  AuthenticationBuilder builder() => new AuthenticationBuilder();
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

//Handler _wrapHandler(Handler handler) {
//  return (Request request) {
//    var response;
//
//    runZoned(() {
//      response = handler(request);
//    }, zoneValues: <Symbol, Object>{
//      _MOJITO_CONTEXT: contextFromRequest(request)
////    }, onError: (error, stack) {
////      print('!!!!!! $error\n$stack');
////      var context = appengine_internal.contextFromRequest(request);
////      if (context != null) {
////        try {
////          context.services.logging.error(
////              'Uncaught error in request handler: $error\n$stack');
////        } catch (e) {
////          print('Error while logging uncaught error: $e');
////        }
////      } else {
////        // TODO: We could log on the background ticket here.
////        print('Unable to log error, since response has already been sent.');
////      }
////      errorHandler('Uncaught error in request handler zone: $error', stack);
//
////      // In many cases errors happen during request processing or response
////      // preparation. In such cases we want to close the connection, since user
////      // code might not be able to.
////      try {
////        request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
////      } on StateError catch (_) {}
////      request.response.close().catchError((closeError, closeErrorStack) {
////        errorHandler('Forcefully closing response, due to error in request '
////                     'handler zone, resulted in an error: $closeError',
////                     closeErrorStack);
////      });
//    });
//
//    return response;
//  };
//}
//
//
//
