// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.router.impl;

import 'package:shelf/shelf.dart';
import 'package:shelf_rest/extend.dart' as r;
import 'router.dart';
import 'mojito.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:option/option.dart';
import 'package:shelf_bind/shelf_bind.dart';
import 'package:mojito/src/oauth_impl.dart';

class MojitoRouterBuilder extends r.ShelfRestRouterBuilder<MojitoRouterBuilder>
    implements Router {
  OAuthRouteBuilderImpl get oauth => new OAuthRouteBuilderImpl(this);
  final IsDevMode _isDevMode;
  IsDevMode get isDevMode =>
      _isDevMode != null ? _isDevMode : () => context.isDevelopmentMode;

  MojitoRouterBuilder(Function fallbackHandler, String name, path,
      r.RouterAdapter routerAdapter, routeable, Middleware middleware,
      this._isDevMode)
      : super(
          fallbackHandler, name, path, routerAdapter, routeable, middleware);

  MojitoRouterBuilder.create({Function fallbackHandler,
      r.HandlerAdapter handlerAdapter, r.RouteableAdapter routeableAdapter,
      r.PathAdapter pathAdapter, Middleware middleware, path: '/', String name,
      IsDevMode isDevMode})
      : this._isDevMode = isDevMode,
        super.create(
            fallbackHandler: fallbackHandler,
            handlerAdapter: _createHandlerAdapter(handlerAdapter),
            routeableAdapter: routeableAdapter,
            pathAdapter: pathAdapter,
            middleware: middleware,
            path: path,
            name: name);

  @override
  MojitoRouterBuilder createChild(String name, path, routeable,
          r.RouterAdapter routerAdapter, Middleware middleware) =>
      new MojitoRouterBuilder(fallbackHandler, name, path, routerAdapter,
          routeable, middleware, isDevMode);

  @override
  void addStaticAssetHandler(path, {String fileSystemPath: 'build/web',
      bool serveFilesOutsidePath: false, String defaultDocument,
      bool usePubServeInDev: true, String pubServeUrlString,
      Middleware middleware}) {
    final usePubServe = usePubServeInDev && isDevMode();

    final handler = _pubServeHandler(usePubServe, pubServeUrlString).getOrElse(
        () => createStaticHandler(fileSystemPath,
            serveFilesOutsidePath: serveFilesOutsidePath,
            defaultDocument: defaultDocument));

    add(path, ['GET'], (Request request) => handler(request),
        exactMatch: false, middleware: middleware);
  }
}

Option<Handler> _pubServeHandler(
    bool usePubServe, String providedPubServeUrlString) {
  if (!usePubServe) {
    return const None();
  }

  return new Option(providedPubServeUrlString)
      .orElse(() => new Option(const String.fromEnvironment('DART_PUB_SERVE')))
      .orElse(() => new Some('http://localhost:8080'))
      .map(proxyHandler);
}

r.HandlerAdapter _createHandlerAdapter(r.HandlerAdapter ha) =>
    ha != null ? ha : handlerAdapter();
