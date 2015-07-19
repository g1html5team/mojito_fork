// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.oauth.impl;

import 'package:shelf_oauth/shelf_oauth.dart';
import 'package:shelf_oauth_memcache/shelf_oauth_memcache.dart' as omem;
import 'package:mojito/src/oauth.dart';
import 'package:uri/uri.dart';
import 'package:mojito/src/router.dart';
import 'package:shelf/shelf.dart';
import 'dart:async';
import 'package:http_exception/http_exception.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:option/option.dart';

class MojitoOAuthStorageImpl implements MojitoOAuthStorage {
  OAuthStorage inMemory() => new InMemoryOAuthStorage();

  OAuthStorage memcache(omem.MemcacheProvider memcacheProvider,
      {Duration shortTermStorageExpiration: const Duration(minutes: 2),
      Duration sessionStorageExpiration: const Duration(hours: 1)}) => omem
      .oauthStorage(memcacheProvider,
          shortTermStorageExpiration: shortTermStorageExpiration,
          sessionStorageExpiration: sessionStorageExpiration);
}

class OAuthRouteBuilderImpl implements OAuthRouteBuilder {
  final Router routerBuilder;
  final MojitoOAuthStorageImpl storage = new MojitoOAuthStorageImpl();

  OAuthRouteBuilderImpl(this.routerBuilder);

  @override
  OAuth2RouteBuilder gitHub({path}) => oauth2(
      'github', (_) => commonAuthorizationServers.gitHubOAuth2, path: path);

  @override
  OAuth2RouteBuilder bitBucket({path}) => oauth2(
      'bitbucket', (_) => commonAuthorizationServers.bitbucketOAuth2,
      path: path);

  @override
  OAuth1RouteBuilder bitBucketOAuth1({path: 'bitbucket'}) =>
      oauth1(path, (_) => commonAuthorizationServers.bitBucketOAuth1);

  @override
  OAuth2RouteBuilder google({path}) => oauth2(
      'google', (_) => commonAuthorizationServers.googleOAuth2, path: path);

  @override
  OAuth2RouteBuilder hipchat({path}) => oauth2(
      'hipchat', (_) => commonAuthorizationServers.hipchatOAuth2, path: path);

  @override
  OAuth2RouteBuilder oauth2(String providerName,
      OAuth2AuthorizationServerFactory authorizationServerFactory, {path}) {
    return new OAuth2RouteBuilderImpl(
        routerBuilder, authorizationServerFactory, path, providerName);
  }

  @override
  OAuth1RouteBuilder oauth1(
      path, OAuth1AuthorizationServerFactory authorizationServerFactory) {
    return new OAuth1RouteBuilderImpl(
        routerBuilder, authorizationServerFactory, path);
  }
}

class OAuth2RouteBuilderImpl implements OAuth2RouteBuilder {
  final Router routerBuilder;
  final OAuth2AuthorizationServerFactory authorizationServerFactory;
  final path;
  final String providerName;

  OAuth2RouteBuilderImpl(this.routerBuilder, this.authorizationServerFactory,
      this.path, this.providerName);

  @override
  Oauth2RouteNames addClient(ClientIdFactory clientIdFactory,
      OAuthStorage oauthStore, UriTemplate completionRedirectUrl,
      {userGrantPath: '/userGrant', authTokenPath: '/authToken',
      List<String> scopes: const [],
      SessionIdentifierExtractor sessionIdExtractor, String callbackUrl,
      bool storeTokens: true}) {
    final atp = authTokenPath.toString();

    final cb = callbackUrl != null
        ? callbackUrl
        : atp.startsWith('/') ? atp.substring(1) : atp;

    final _sessionIdExtractor = sessionIdExtractor != null
        ? sessionIdExtractor
        : _extractShelfAuthSessionId;

    final dancer = new OAuth2ProviderHandlers(clientIdFactory,
        authorizationServerFactory, Uri.parse(cb),
        oauthStore.oauth2CSRFStateStore, oauthStore.oauth2TokenStore,
        completionRedirectUrl, _sessionIdExtractor, scopes,
        storeTokens: storeTokens);

    final routeNames = new Oauth2RouteNames(
        OAuth2RouteBuilder.userGrantRouteName(providerName),
        OAuth2RouteBuilder.authTokenRouteName(providerName));

    routerBuilder.addAll((Router r) => r
      ..get(userGrantPath, dancer.authorizationRequestHandler(),
          name: routeNames.userGrantRoute)
      ..get(authTokenPath, dancer.accessTokenRequestHandler()),
        path: path != null ? path : providerName,
        name: routeNames.authTokenRoute);

    return routeNames;
  }
}

class OAuth1RouteBuilderImpl implements OAuth1RouteBuilder {
  final Router routerBuilder;
  // TODO: should be a factory
  final OAuth1AuthorizationServerFactory authorizationServerFactory;
  final path;

  OAuth1RouteBuilderImpl(
      this.routerBuilder, this.authorizationServerFactory, this.path);

  @override
  void addClient(OAuth1Token consumerToken,
      OAuth1RequestTokenSecretStore tokenStore,
      UriTemplate completionRedirectUrl, {requestTokenPath: '/requestToken',
      authTokenPath: '/authToken', String callbackUrl}) {
    final atp = authTokenPath.toString();

    final cb = callbackUrl != null
        ? callbackUrl
        : atp.startsWith('/') ? atp.substring(1) : atp;

    final dancer = new OAuth1ProviderHandlers(consumerToken,
        authorizationServerFactory, cb, tokenStore, completionRedirectUrl);

    routerBuilder.addAll((Router r) => r
      ..get(requestTokenPath, dancer.tokenRequestHandler())
      ..get(authTokenPath, dancer.accessTokenRequestHandler()), path: path);
  }
}

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
