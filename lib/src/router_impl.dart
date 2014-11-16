// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.router.impl;

import 'package:shelf/shelf.dart';
import 'package:shelf_bind/shelf_bind.dart';
import 'package:shelf_route/extend.dart' as r;
import 'package:shelf_rest/shelf_rest.dart' as rest;
import 'router.dart';
import 'package:shelf_oauth/shelf_oauth.dart';
import 'package:uri/uri.dart';
import 'mojito.dart';
import 'dart:async';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:option/option.dart';

class RouterImpl extends r.RouterImpl<Router> implements Router {
  RouterImpl({Function fallbackHandler,
    r.HandlerAdapter handlerAdapter,
    r.RouteableAdapter routeableAdapter,
    r.PathAdapter pathAdapter: r.uriTemplatePattern,
    Middleware middleware, path: '/'})
      : super(fallbackHandler: fallbackHandler,
          handlerAdapter: _createHandlerAdapter(handlerAdapter),
          routeableAdapter: _createRouteableAdapter(routeableAdapter),
          pathAdapter: pathAdapter,
          path: path);

  void resource(resource, {path, Middleware middleware,
      r.HandlerAdapter handlerAdapter,
      bool validateParameters: true, bool validateReturn: false }) {

    final ra = this.routeableAdapter != null ? this.routeableAdapter
        : rest.routeableAdapter(validateParameters: validateParameters,
                                  validateReturn: validateReturn);
    addAll(resource,
        handlerAdapter: handlerAdapter,
        routeableAdapter: routeableAdapter,
        middleware: middleware,
        path: path);
  }

  @override
  RouterImpl createChild(r.HandlerAdapter handlerAdapter,
                         r.RouteableAdapter routeableAdapter,
                         r.PathAdapter pathAdapter, path,
                         Middleware middleware) =>
      new RouterImpl(fallbackHandler: fallbackHandler,
          handlerAdapter: handlerAdapter, routeableAdapter: routeableAdapter,
          pathAdapter: pathAdapter, path: path,
          middleware: middleware);


  @override
  void addOAuth1Provider(path,
                         OAuth1Token consumerToken,
                         OAuth1Provider oauthProvider,
                         OAuth1RequestTokenSecretStore tokenStore,
                         UriTemplate completionRedirectUrl,
                         { requestTokenPath: '/requestToken',
                           authTokenPath: '/authToken',
                           String callbackUrl }) {
    final atp = authTokenPath.toString();

    final cb = callbackUrl != null ? callbackUrl :
      atp.startsWith('/') ? atp.substring(1) : atp;

    final dancer = new OAuth1ProviderHandlers(consumerToken, oauthProvider,
        cb, tokenStore, completionRedirectUrl);

    addAll((Router r) => r
        ..get(requestTokenPath, dancer.tokenRequestHandler())
        ..get(authTokenPath, dancer.accessTokenRequestHandler()),
        path: path);
  }


  @override
  void addStaticAssetHandler(path, { String fileSystemPath: 'build/web',
    bool serveFilesOutsidePath: false, String defaultDocument,
    bool usePubServeInDev: true, String pubServeUrlString,
    Middleware middleware }) {

    final usePubServe = usePubServeInDev && context.isDevelopmentMode;

    final handler = _pubServeHandler(usePubServe, pubServeUrlString)
        .getOrElse(() =>
            createStaticHandler(fileSystemPath,
                serveFilesOutsidePath: serveFilesOutsidePath,
                defaultDocument: defaultDocument));

    add(path, ['GET'], (Request request) => handler(request),
        exactMatch: false, middleware: middleware);
  }

}


Option<Handler> _pubServeHandler(bool usePubServe,
    String providedPubServeUrlString) {
  if (!usePubServe) {
    return const None();
  }

  return new Option(providedPubServeUrlString)
    .orElse(new Option(const String.fromEnvironment('DART_PUB_SERVE')))
    .orElse(new Some('http://localhost:8080'))
    .map(proxyHandler);

}



r.HandlerAdapter _createHandlerAdapter(r.HandlerAdapter ha) =>
    ha != null ? ha : handlerAdapter();

r.RouteableAdapter _createRouteableAdapter(r.RouteableAdapter ra) =>
    ra != null ? ra : rest.routeableAdapter();

