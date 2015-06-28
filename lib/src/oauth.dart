// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.oauth;

import 'package:shelf_oauth/shelf_oauth.dart';
import 'package:shelf_oauth_memcache/shelf_oauth_memcache.dart' as memcache;

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
