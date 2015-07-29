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
import 'package:config/config.dart';
import 'package:mojito/src/config.dart';
import 'package:quiver/check.dart';

final Logger _log = new Logger('mojito');

bool defaultIsDevMode() =>
    const bool.fromEnvironment(MOJITO_IS_DEV_MODE_ENV_VARIABLE);

class MojitoImpl<C extends MojitoServerConfig> implements Mojito<C> {
  final mr.Router router;
  final MojitoAuthImpl auth = new MojitoAuthImpl();
  final MojitoAuthorisationImpl authorisation = new MojitoAuthorisationImpl();
  final MojitoSessionStorageImpl sessionStorage =
      new MojitoSessionStorageImpl();
  final MojitoMiddlewareImpl middleware = new MojitoMiddlewareImpl();
  MojitoContext get context => _getContext();
  Handler get handler => _createHandler();
  final C config;

  MojitoImpl(MojitoServerConfig config,
      EnvironmentNameResolver environmentNameResolver)
      : this.config = config,
        this.router = config.createRootRouter != null
            ? config.createRootRouter()
            : mr.router() {
    if (_context != null) {
      throw new ArgumentError('can only initialise mojito once');
    }

    // TODO: this is a mess
    checkNotNull(environmentNameResolver,
        message: 'environmentNameResolver is mandatory');

    bool _isDevMode =
        environmentNameResolver() == StandardEnvironmentNames.development;

    _context = new MojitoContextImpl(_isDevMode, this);

    if (config.createRootLogger) {
      Logger.root.onRecord.listen((LogRecord lr) {
        print('${lr.time} $lr');
      });
    }
  }

  static MojitoConfig resolveConfig(ConfigFactory<MojitoConfig> configFactory,
      EnvironmentNameResolver environmentNameResolver) {
    checkNotNull(configFactory, message: 'configFactory is mandatory');
    checkNotNull(environmentNameResolver,
        message: 'environmentNameResolver is mandatory');

    final String environmentName = environmentNameResolver();

    return configFactory.configFor(environmentName);
  }

  MojitoImpl.fromConfig(ConfigFactory<MojitoConfig> configFactory,
      EnvironmentNameResolver environmentNameResolver)
      : this(resolveConfig(configFactory, environmentNameResolver).server,
          environmentNameResolver);

  MojitoImpl.simple(
      RouteCreator createRootRouter, bool logRequests, bool createRootLogger,
      {IsDevMode isDevMode})
      : this(new MojitoServerConfig(
              createRootRouter: createRootRouter,
              logRequests: logRequests,
              createRootLogger: createRootLogger),
          defaultEnvironmentNameResolver(isDevMode));

  Future start({int port: 9999}) async {
    final HttpServer server =
        await HttpServer.bind(InternetAddress.ANY_IP_V6, port);
//    final headers = <String, String>{};
//    server.defaultResponseHeaders.forEach((k, v) {
//      headers[k] = v.join(',');
//    });
//    this._defaultResponseHeaders = headers;

    server.defaultResponseHeaders.remove('x-frame-options', 'SAMEORIGIN');
    io.serveRequests(server, handler);
    _log.info('Serving at http://${server.address.host}:${server.port}');

//    return io.serve(handler, InternetAddress.ANY_IP_V6, port).then((server) {
//      _log.info('Serving at http://${server.address.host}:${server.port}');
//    });
  }

//  Future start({ int port: 9999 }) async {
//    final server = await io.serve(handler, InternetAddress.ANY_IP_V6, port);
//    _log.info('Serving at http://${server.address.host}:${server.port}');
//    return null;
//  }

  Handler _createHandler() {
    r.printRoutes(router, printer: _log.info);

    var pipeline = const Pipeline();

    if (config.logRequests) {
      pipeline = pipeline.addMiddleware(logRequests());
    }

    pipeline = pipeline.addMiddleware(exceptionHandler());
    pipeline = pipeline.addMiddleware(logExceptions());
    pipeline = pipeline.addMiddleware(_xFrameOptionsMiddleware());

    final authMiddleware = auth.middleware;

    if (authMiddleware != null) {
      pipeline = pipeline.addMiddleware(authMiddleware);

      // TODO: check auth middleware has session handler ???
      // TODO: error out if session set wo auth
      final sessionMiddleware = sessionStorage.middleware;
      if (sessionMiddleware != null) {
        pipeline = pipeline.addMiddleware(sessionMiddleware);
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

/// dart:io http server sets 'x-frame-options': 'SAMEORIGIN' by default. As
/// there is no value you can set that to to turn it off that all the browsers
/// support, we remove it from the default headers and add it back here as
/// required.
Middleware _xFrameOptionsMiddleware() {
  return createMiddleware(responseHandler: (Response response) {
    if (
//    response.headers.containsKey('x-frame-options') ||
        response.headers.containsKey('access-control-allow-origin')) {
      return response;
    } else {
      return response.change(headers: {'x-frame-options': 'SAMEORIGIN'});
    }
  });
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
