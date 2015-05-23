// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.router.impl;

import 'package:shelf/shelf.dart';
import 'package:shelf_rest/extend.dart' as r;
import 'router.dart';
import 'package:shelf_oauth/shelf_oauth.dart';
import 'package:uri/uri.dart';
import 'mojito.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:option/option.dart';
import 'package:shelf_bind/shelf_bind.dart';

class MojitoRouter extends r.ShelfRestRouterBuilder<Router> implements Router {
  MojitoRouter.internal(Function fallbackHandler, String name, path,
      r.RouterAdapter routerAdapter, routeable)
      : super(fallbackHandler, name, path, routerAdapter, routeable);

  MojitoRouter({Function fallbackHandler, r.HandlerAdapter handlerAdapter,
      r.RouteableAdapter routeableAdapter,
      r.PathAdapter pathAdapter: r.uriTemplatePattern, Middleware middleware,
      path: '/', String name})
      : super.create(
          fallbackHandler: fallbackHandler,
          handlerAdapter: _createHandlerAdapter(handlerAdapter),
          routeableAdapter: routeableAdapter,
          pathAdapter: pathAdapter,
          middleware: middleware,
          path: path,
          name: name);

  @override
  MojitoRouter createChild(
          String name, path, routeable, r.RouterAdapter routerAdapter) =>
      new MojitoRouter.internal(
          fallbackHandler, name, path, routerAdapter, routeable);

  @override
  void addOAuth1Provider(path, OAuth1Token consumerToken,
      OAuth1Provider oauthProvider, OAuth1RequestTokenSecretStore tokenStore,
      UriTemplate completionRedirectUrl, {requestTokenPath: '/requestToken',
      authTokenPath: '/authToken', String callbackUrl}) {
    final atp = authTokenPath.toString();

    final cb = callbackUrl != null
        ? callbackUrl
        : atp.startsWith('/') ? atp.substring(1) : atp;

    final dancer = new OAuth1ProviderHandlers(
        consumerToken, oauthProvider, cb, tokenStore, completionRedirectUrl);

    addAll((Router r) => r
      ..get(requestTokenPath, dancer.tokenRequestHandler())
      ..get(authTokenPath, dancer.accessTokenRequestHandler()), path: path);
  }

  @override
  void addOAuth2Provider(path, ClientIdFactory clientIdFactory,
      OAuth2ProviderFactory oauthProviderFactory,
      OAuth2CSRFStateStore stateStore, OAuth2TokenStore tokenStore,
      UriTemplate completionRedirectUrl,
      SessionIdentifierExtractor sessionIdExtractor, List<String> scopes,
      {userGrantPath: '/userGrant', authTokenPath: '/authToken',
      String callbackUrl, bool storeTokens: true}) {
    final atp = authTokenPath.toString();

    final cb = callbackUrl != null
        ? callbackUrl
        : atp.startsWith('/') ? atp.substring(1) : atp;

    final dancer = new OAuth2ProviderHandlers(clientIdFactory,
        oauthProviderFactory, Uri.parse(cb), stateStore, tokenStore,
        completionRedirectUrl, sessionIdExtractor, scopes,
        storeTokens: storeTokens);

    addAll((Router r) => r
      ..get(userGrantPath, dancer.authorizationRequestHandler())
      ..get(authTokenPath, dancer.accessTokenRequestHandler()), path: path);
  }

  @override
  void addStaticAssetHandler(path, {String fileSystemPath: 'build/web',
      bool serveFilesOutsidePath: false, String defaultDocument,
      bool usePubServeInDev: true, String pubServeUrlString,
      Middleware middleware}) {
    final usePubServe = usePubServeInDev && context.isDevelopmentMode;

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
      .orElse(new Option(const String.fromEnvironment('DART_PUB_SERVE')))
      .orElse(new Some('http://localhost:8080'))
      .map(proxyHandler);
}

r.HandlerAdapter _createHandlerAdapter(r.HandlerAdapter ha) =>
    ha != null ? ha : handlerAdapter();
