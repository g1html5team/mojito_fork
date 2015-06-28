// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.oauth;

import 'package:shelf_oauth/shelf_oauth.dart';
import 'package:shelf_oauth_memcache/shelf_oauth_memcache.dart' as memcache;
import 'package:uri/uri.dart';

abstract class MojitoOAuth {
  OAuthStorage inMemoryStorage();

  OAuthStorage memcacheStorage(memcache.MemcacheProvider memcacheProvider,
      {Duration shortTermStorageExpiration: const Duration(minutes: 2),
      Duration sessionStorageExpiration: const Duration(hours: 1)});

  CommonAuthorizationServers get authorizationServers;
}

abstract class CommonAuthorizationServers {
  OAuth1Provider get bitBucketOAuth1;

  OAuth2AuthorizationServer get gitHubOAuth2;
}

abstract class OAuth2RouteBuilder {
  void addClient(ClientIdFactory clientIdFactory, OAuthStorage oauthStore,
      UriTemplate completionRedirectUrl,
      {userGrantPath: '/userGrant',
      authTokenPath: '/authToken',
      List<String> scopes: const [],
      SessionIdentifierExtractor sessionIdExtractor,
      // optional. Only if want absolute url
      String callbackUrl});
}

abstract class OAuthRouteBuilder {
  OAuth2RouteBuilder gitHub({path: 'github'});

  OAuth2RouteBuilder oauth2(
      path, OAuth2AuthorizationServerFactory authorizationServerFactory);

//  void addGitHubClient(
//      path,
//      ClientIdFactory clientIdFactory,
//      OAuth2CSRFStateStore stateStore,
//      OAuth2TokenStore tokenStore,
//      UriTemplate completionRedirectUrl,
//      {userGrantPath: '/userGrant',
//      authTokenPath: '/authToken',
//      List<String> scopes: const [],
//      SessionIdentifierExtractor sessionIdExtractor,
//      // optional. Only if want absolute url
//      String callbackUrl});

//  void addOAuth1Client(
//      path,
//      OAuth1Token consumerToken,
//      OAuth1Provider oauthProvider,
//      OAuth1RequestTokenSecretStore tokenStore,
//      UriTemplate completionRedirectUrl,
//      {requestTokenPath: '/requestToken',
//      authTokenPath: '/authToken',
//      // optional. Only if want absolute url
//      String callbackUrl});

  /// Creates routes to implement the 'client' part of the
  /// [OAuth 2 Authorization Code Flow](http://tools.ietf.org/html/rfc6749#section-4.1).
  ///
  /// Provide a [path] relative to the current router of where to
  /// mount the routes.
  ///
  /// You need to obtain a client id and secret from the authorization provider
  /// you want to authenticate against. In some cases the client id differs
  /// per request. If not then you can simply pass the value as
  /// `(_) => myFixedClientId`
  ///
  /// A [OAuth2AuthorizationServer] defines the details of the server the routes
  /// will be set up to authenticate against. In some cases this will also differ
  /// per request.
  ///
  /// Storage is required for the short lived tokens that guard against CSRF
  /// attacks and for the token
  ///
  ///
  /// By default a shelf_auth session identifier will be assumed. Pass in a
  /// value for [sessionIdExtractor] to override
//  void addOAuth2Client(
//      path,
//      ClientIdFactory clientIdFactory,
//      OAuth2AuthorizationServerFactory authorizationServerFactory,
//      OAuth2CSRFStateStore stateStore,
//      OAuth2TokenStore tokenStore,
//      UriTemplate completionRedirectUrl,
//      {userGrantPath: '/userGrant',
//      authTokenPath: '/authToken',
//      List<String> scopes: const [],
//      SessionIdentifierExtractor sessionIdExtractor,
//      // optional. Only if want absolute url
//      String callbackUrl});
}
