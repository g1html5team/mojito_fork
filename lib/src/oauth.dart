// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.oauth;

import 'package:shelf_oauth/shelf_oauth.dart';
import 'package:shelf_oauth_memcache/shelf_oauth_memcache.dart' as omem;
import 'package:uri/uri.dart';

/// Route builder for oauth clients
abstract class OAuthRouteBuilder {
  MojitoOAuthStorage get storage;

  /// builder for oauth2 clients authenticating with github
  OAuth2RouteBuilder gitHub({path});

  /// builder for oauth2 clients authenticating with bitbucket
  OAuth2RouteBuilder bitBucket({path});

  /// builder for oauth1 clients authenticating with bitbucket
  OAuth1RouteBuilder bitBucketOAuth1({path});

  /// builder for oauth2 clients authenticating with google
  OAuth2RouteBuilder google({path});

  /// builder for oauth2 clients authenticating with hipchat
  OAuth2RouteBuilder hipchat({path});

  /// builder for other oauth2 clients
  OAuth2RouteBuilder oauth2(
      path, OAuth2AuthorizationServerFactory authorizationServerFactory);

  /// builder for other oauth1 clients
  ///
  /// Provide a [path] relative to the current router of where to
  /// mount the routes.
  ///
  ///
  OAuth1RouteBuilder oauth1(
      path, OAuth1AuthorizationServerFactory authorizationServerFactory);
}

/// Route builder for oauth2 clients
abstract class OAuth2RouteBuilder {
  /// Creates routes to implement the 'client' part of the
  /// [OAuth 2 Authorization Code Flow](http://tools.ietf.org/html/rfc6749#section-4.1).
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
  Oauth2RouteNames addClient(ClientIdFactory clientIdFactory,
      OAuthStorage oauthStore, UriTemplate completionRedirectUrl,
      {userGrantPath: '/userGrant', authTokenPath: '/authToken',
      List<String> scopes: const [],
      SessionIdentifierExtractor sessionIdExtractor,
      // optional. Only if want absolute url
      String callbackUrl, bool storeTokens: true});

  static String userGrantRouteName(String oauthProviderName) =>
      'oauthprovider.$oauthProviderName.userGrantRoute';

  static String authTokenRouteName(String oauthProviderName) =>
      'oauthprovider.$oauthProviderName.authTokenRoute';
}

/// Route builder for oauth1 clients
abstract class OAuth1RouteBuilder {
  void addClient(
//      path,
      OAuth1Token consumerToken,
//      OAuth1Provider oauthProvider,
      OAuth1RequestTokenSecretStore tokenStore,
      UriTemplate completionRedirectUrl, {requestTokenPath: '/requestToken',
      authTokenPath: '/authToken',
      // optional. Only if want absolute url
      String callbackUrl});
}

abstract class MojitoOAuthStorage {
  OAuthStorage inMemory();

  OAuthStorage memcache(omem.MemcacheProvider memcacheProvider,
      {Duration shortTermStorageExpiration: const Duration(minutes: 2),
      Duration sessionStorageExpiration: const Duration(hours: 1)});
}

class Oauth2RouteNames {
  final String userGrantRoute;
  final String authTokenRoute;

  Oauth2RouteNames(this.userGrantRoute, this.authTokenRoute);
}
