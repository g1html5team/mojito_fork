// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.impl;

import 'context.dart';
import 'context_impl.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_exception_response/exception_response.dart';
import 'package:shelf_bind/shelf_bind.dart';
import 'package:shelf_route/shelf_route.dart' as r;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'mojito.dart';
import 'router.dart';
import 'router_impl.dart';
import 'auth_impl.dart';
import 'package:mojito/src/middleware_impl.dart';

class MojitoImpl implements Mojito {
  final Router router;
  Handler _pubServeHandler;
  final MojitoAuthImpl auth = new MojitoAuthImpl();
  final MojitoMiddlewareImpl middleware = new MojitoMiddlewareImpl();

  MojitoContext get context => _getContext();
  Handler get handler => _createHandler();

  final bool _logRequests;


  MojitoImpl(RouteCreator createRootRouter, this._logRequests)
      : router = createRootRouter != null ? createRootRouter() :
          new RouterImpl(handlerAdapter: handlerAdapter());

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

    var pipeline = const Pipeline();
    if (_logRequests) {
      pipeline = pipeline.addMiddleware(logRequests());
    }

    pipeline = pipeline.addMiddleware(exceptionResponse());

    final authMiddleware = auth.middleware;

    if (authMiddleware != null) {
      pipeline = pipeline.addMiddleware(authMiddleware);
    }

    final mw = middleware.middleware;
    if (mw != null) {
      pipeline = pipeline.addMiddleware(mw);
    }

    final handler = pipeline.addHandler(router.handler);

//    return _wrapHandler(handler);
    return handler;
  }

}

// just a trick as Mojito has a property called context which points to this one
MojitoContext _getContext() => context;

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
