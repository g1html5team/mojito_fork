// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.impl;

import 'context.dart';
import 'context_impl.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_exception_handler/shelf_exception_handler.dart';
import 'package:shelf_route/shelf_route.dart' as r;
import 'mojito.dart';
import 'router.dart' as mr;
import 'auth_impl.dart';
import 'authorisation_impl.dart';
import 'package:mojito/src/middleware_impl.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:mojito/src/session_storage_impl.dart';
import 'dart:io';
import 'package:shelf_route/extend.dart';

final Logger _log = new Logger('mojito');

bool defaultIsDevMode() =>
    const bool.fromEnvironment(MOJITO_IS_DEV_MODE_ENV_VARIABLE);

class MojitoImpl implements Mojito {
  final mr.Router router;
  final MojitoAuthImpl auth = new MojitoAuthImpl();
  final MojitoAuthorisationImpl authorisation = new MojitoAuthorisationImpl();
  final MojitoSessionStorageImpl sessionStorage =
      new MojitoSessionStorageImpl();
  final MojitoMiddlewareImpl middleware = new MojitoMiddlewareImpl();

  MojitoContext get context => _getContext();
  Handler get handler => _createHandler();

  final bool _logRequests;

  MojitoImpl(
      RouteCreator createRootRouter, this._logRequests, bool createRootLogger,
      {IsDevMode isDevMode})
      : router = createRootRouter != null ? createRootRouter() : mr.router() {
    IsDevMode _isDevMode = isDevMode != null ? isDevMode : defaultIsDevMode;
    _context = new MojitoContextImpl(_isDevMode());

    if (createRootLogger) {
      Logger.root.onRecord.listen((LogRecord lr) {
        print('${lr.time} $lr');
      });
    }
  }

  Future start({int port: 9999}) {
    return io.serve(handler, InternetAddress.ANY_IP_V6, port).then((server) {
      _log.info('Serving at http://${server.address.host}:${server.port}');
    });
  }

//  Future start({ int port: 9999 }) async {
//    final server = await io.serve(handler, InternetAddress.ANY_IP_V6, port);
//    _log.info('Serving at http://${server.address.host}:${server.port}');
//    return null;
//  }

  Handler _createHandler() {
    r.printRoutes(router, printer: _log.info);

    var pipeline = const Pipeline();

    if (_logRequests) {
      pipeline = pipeline.addMiddleware(logRequests());
    }

    pipeline = pipeline.addMiddleware(exceptionHandler());
    pipeline = pipeline.addMiddleware(logExceptions());

    final authMiddleware = auth.middleware;

    if (authMiddleware != null) {
      pipeline = pipeline.addMiddleware(authMiddleware);

      // TODO: check auth middleware has session handler ???
      // TODO: error out if session set wo auth
      final sessMiddleware = sessionStorage.middleware;
      if (sessMiddleware != null) {
        pipeline = pipeline.addMiddleware(sessMiddleware);
      }
    }

    final authorisationMiddleware = authorisation.middleware;
    if (authorisationMiddleware != null) {
      pipeline = pipeline.addMiddleware(authorisationMiddleware);
    }

    final mw = middleware.middleware;
    if (mw != null) {
      pipeline = pipeline.addMiddleware(mw);
    }

    final handler = pipeline.addHandler(router.handler);

    return handler;
  }
}

// just a trick as Mojito has a property called context which points to this one
MojitoContext _getContext() => context;

const Symbol _MOJITO_CONTEXT = #mojito_context;

MojitoContextImpl _context;
//final MojitoContext context = new MojitoContextImpl();
MojitoContext get context {
  if (_context == null) {
    throw new StateError('you must call the init method first');
  }
  return _context;
}

Middleware logExceptions() {
  return (Handler handler) {
    return (Request request) {
      return new Future.sync(() => handler(request))
          .catchError((error, stackTrace) {
        _log.fine('exception response', error, stackTrace);

        throw error;
      });
    };
  };
}
