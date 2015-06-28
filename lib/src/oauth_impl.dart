// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.oauth.impl;

import 'package:shelf_oauth/shelf_oauth.dart';
import 'package:shelf_oauth_memcache/shelf_oauth_memcache.dart' as memcache;
import 'package:mojito/src/oauth.dart';

class MojitoOAuthImpl implements MojitoOAuth {
  OAuthStorage inMemoryStorage() => new InMemoryOAuthStorage();

  OAuthStorage memcacheStorage(memcache.MemcacheProvider memcacheProvider,
          {Duration shortTermStorageExpiration: const Duration(minutes: 2),
          Duration sessionStorageExpiration: const Duration(hours: 1)}) =>
      memcache.oauthStorage(memcacheProvider,
          shortTermStorageExpiration: shortTermStorageExpiration,
          sessionStorageExpiration: sessionStorageExpiration);

  final CommonAuthorizationServers authorizationServers =
      new CommonAuthorizationServersImpl();
}

class CommonAuthorizationServersImpl implements CommonAuthorizationServers {
  static const _bitBucketOAuth1UrlBase = 'https://bitbucket.org/api/1.0/oauth';

  OAuth1Provider get bitBucketOAuth1 => new OAuth1Provider(
      Uri.parse('$_bitBucketOAuth1UrlBase/request_token'),
      Uri.parse('$_bitBucketOAuth1UrlBase/access_token'),
      Uri.parse('$_bitBucketOAuth1UrlBase/authenticate'));

  static const _githubOAuthUrlBase = 'https://github.com/login/oauth';

  OAuth2AuthorizationServer get gitHubOAuth2 =>
      new OAuth2AuthorizationServer.std(
          Uri.parse('$_githubOAuthUrlBase/authorize'),
          Uri.parse('$_githubOAuthUrlBase/access_token'));
}
