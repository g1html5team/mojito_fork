// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.middleware.impl;

import 'package:shelf/shelf.dart' as s;
import 'middleware.dart';
import 'package:shelf/shelf.dart';

class MojitoMiddlewareImpl implements MojitoMiddleware {
  s.Middleware _middleware;
  MiddlewareBuilder _global;

  s.Middleware get middleware {
    if (_global != null) {
      return _middleware != null ? _middleware : _global.build();
    }

    return null;
  }

  MojitoMiddlewareImpl();

  /// builder for authenitcation middleware to be applied all routes
  MiddlewareBuilder get global {
    if (_global == null) {
      _global = new _GlobalMiddlewareBuilder(this);
    }
    return _global;
  }

  /// builder for authenitcation middleware that you choose where to include
  MiddlewareBuilder builder() => new MiddlewareBuilderImpl();
}

class MiddlewareBuilderImpl implements MiddlewareBuilder {
  s.Pipeline pipeline = const s.Pipeline();

  @override
  s.Middleware build() => pipeline.middleware;

  @override
  MiddlewareBuilder logRequests({void logger(String msg, bool isError)}) =>
      addMiddleware(s.logRequests(logger: logger));

  @override
  MiddlewareBuilder addMiddleware(s.Middleware middleware) {
    pipeline = pipeline.addMiddleware(middleware);
    return this;
  }

  @override
  MiddlewareBuilder cors({String domain: '*'}) =>
      addMiddleware(createMiddleware(responseHandler: (Response response) {
        final corsHeaders = {'access-control-allow-origin': domain};
        if (response.headers.containsKey('x-frame-options')) {
          final newHeaders = new Map.from(response.headers)
            ..remove('x-frame-options')
            ..addAll(corsHeaders);

          return new Response(response.statusCode,
              headers: newHeaders,
              body: response.read(),
              context: response.context,
              encoding: response.encoding);
        } else {
          return response.change(headers: corsHeaders);
        }
      }));
}

class _GlobalMiddlewareBuilder extends MiddlewareBuilderImpl {
  final MojitoMiddlewareImpl _ma;

  _GlobalMiddlewareBuilder(this._ma);

  @override
  s.Middleware build() {
    final m = super.build();
    _ma._middleware = m;
    return m;
  }
}

//class AssetHandler {
//  s.Middleware get middleware => _createStaticHandler;
//
//  s.Handler _createStaticHandler(s.Handler innerHandler) {
//    return (s.Request request) => _handle(request, innerHandler);
//  }
//
//  Future<s.Response> _handle(s.Request request, s.Handler innerHandler) {
//  }
//}
