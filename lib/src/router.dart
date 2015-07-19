// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.router;

import 'package:shelf/shelf.dart';
import 'package:shelf_rest/shelf_rest.dart' as r;
import 'router_impl.dart';
import 'package:mojito/src/oauth.dart';
export 'package:shelf_oauth/shelf_oauth.dart'
    show OAuth1RequestTokenSecretStore, InMemoryOAuth1RequestTokenSecretStore;

/// this just exists due to lack of generic function support in Dart
typedef MojitoRouteableFunction(Router r);

/// A shelf_route router that adds some methods
abstract class Router implements r.Router<Router> {
  /// route builders for oauth clients
  OAuthRouteBuilder get oauth;

  /// Serves static assets.
  /// If not in `development` mode then assets are served from filesystem
  /// (via shelf_static) and will have cache support.
  /// If [usePubServeInDev] is true (the default) then in `development` mode
  /// the assets will be served by `pub serve` (via shelf_proxy).
  /// If [pubServeUrlString] is provided that will be used as the url for
  /// `pub serve`. Otherwise the environment variable `DART_PUB_SERVE` will be
  /// looked up and if present used. If neither is present then it will fall
  /// back to `http://localhost:8080`
  /// Note: if more than one route is set up to use [serveStaticAssets] then
  /// it only makes sense to use pub serve on one of them
  void addStaticAssetHandler(path, {String fileSystemPath: 'build/web',
      bool serveFilesOutsidePath: false, String defaultDocument,
      bool usePubServeInDev: true, String pubServeUrlString,
      Middleware middleware});
}

/// Creates a mojito router
Router router({r.HandlerAdapter handlerAdapter,
        r.RouteableAdapter routeableAdapter, r.PathAdapter pathAdapter,
        Function fallbackHandler, Middleware middleware}) =>
    new MojitoRouterBuilder.create(
        handlerAdapter: handlerAdapter,
        pathAdapter: pathAdapter,
        fallbackHandler: fallbackHandler,
        middleware: middleware);
