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
import 'dart:async';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:http_exception/http_exception.dart';
import 'package:mojito/src/oauth_impl.dart';

class MojitoRouterBuilder extends r.ShelfRestRouterBuilder<MojitoRouterBuilder>
    implements Router {
  OAuthRouteBuilderImpl get oauth => new OAuthRouteBuilderImpl(this);

  MojitoRouterBuilder.internal(Function fallbackHandler, String name, path,
      r.RouterAdapter routerAdapter, routeable, Middleware middleware)
      : super(
            fallbackHandler, name, path, routerAdapter, routeable, middleware);

  MojitoRouterBuilder(
      {Function fallbackHandler,
      r.HandlerAdapter handlerAdapter,
      r.RouteableAdapter routeableAdapter,
      r.PathAdapter pathAdapter,
      Middleware middleware,
      path: '/',
      String name})
      : super.create(
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
      new MojitoRouterBuilder.internal(
          fallbackHandler, name, path, routerAdapter, routeable, middleware);

  @override
  void addOAuth1Provider(
      path,
      OAuth1Token consumerToken,
      OAuth1Provider oauthProvider,
      OAuth1RequestTokenSecretStore tokenStore,
      UriTemplate completionRedirectUrl,
      {requestTokenPath: '/requestToken',
      authTokenPath: '/authToken',
      String callbackUrl}) {
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
  void addOAuth2Provider(
      path,
      ClientIdFactory clientIdFactory,
      OAuth2AuthorizationServerFactory authorizationServerFactory,
      OAuth2CSRFStateStore stateStore,
      OAuth2TokenStore tokenStore,
      UriTemplate completionRedirectUrl,
      {userGrantPath: '/userGrant',
      authTokenPath: '/authToken',
      List<String> scopes: const [],
      String callbackUrl,
      SessionIdentifierExtractor sessionIdExtractor,
      bool storeTokens: true}) {
    final atp = authTokenPath.toString();

    final cb = callbackUrl != null
        ? callbackUrl
        : atp.startsWith('/') ? atp.substring(1) : atp;

    final _sessionIdExtractor = sessionIdExtractor != null
        ? sessionIdExtractor
        : _extractShelfAuthSessionId;

    final dancer = new OAuth2ProviderHandlers(
        clientIdFactory,
        authorizationServerFactory,
        Uri.parse(cb),
        stateStore,
        tokenStore,
        completionRedirectUrl,
        _sessionIdExtractor,
        scopes,
        storeTokens: storeTokens);

    addAll((Router r) => r
      ..get(userGrantPath, dancer.authorizationRequestHandler())
      ..get(authTokenPath, dancer.accessTokenRequestHandler()), path: path);
  }

  @override
  void addStaticAssetHandler(path,
      {String fileSystemPath: 'build/web',
      bool serveFilesOutsidePath: false,
      String defaultDocument,
      bool usePubServeInDev: true,
      String pubServeUrlString,
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
      .orElse(() => new Option(const String.fromEnvironment('DART_PUB_SERVE')))
      .orElse(() => new Some('http://localhost:8080'))
      .map(proxyHandler);
}

r.HandlerAdapter _createHandlerAdapter(r.HandlerAdapter ha) =>
    ha != null ? ha : handlerAdapter();

Future<String> _extractShelfAuthSessionId(Request request) async {
  final sessionId = getAuthenticatedContext(request)
      .expand((authContext) => authContext is SessionAuthenticatedContext
          ? new Some(authContext.sessionIdentifier)
          : const None())
      .getOrElse(() => _badRequest('no corresponding session identifier'));

  return new Future.value(sessionId);
}

void _badRequest(String msg) {
  throw new BadRequestException({'error': msg}, msg);
}
