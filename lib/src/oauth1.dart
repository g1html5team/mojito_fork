// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.auth.oauth1;


import 'package:shelf/shelf.dart';
import 'dart:async';
import 'package:option/option.dart';
import 'oauth1_impl.dart';

abstract class OAuth1RequestTokenSecretStore {
  Future storeSecret(String authToken, String secret);
  Future<Option<String>> consumeSecret(String authToken);
}

class InMemoryOAuth1RequestTokenSecretStore implements
    OAuth1RequestTokenSecretStore {
  final Map<String, String> tokenMap = {};

  @override
  Future storeSecret(String authToken, String secret) {
    tokenMap[authToken] = secret;
    return new Future.value();
  }

  @override
  Future<Option<String>> consumeSecret(String authToken) {
    return new Future.value(new Option(tokenMap.remove(authToken)));
  }

}

abstract class OAuth1ProviderHandlers {
  factory OAuth1ProviderHandlers(String consumerKey, String consumerSecret,
      String requestTokenUrl, String accessTokenUrl,
      String authenticationUrl, String callbackUrl,
      OAuth1RequestTokenSecretStore tokenStore) {

    return new OAuth1ProviderHandlersImpl(consumerKey, consumerSecret,
        requestTokenUrl, accessTokenUrl, authenticationUrl, callbackUrl,
        tokenStore);
  }


  Handler tokenRequestHandler();

  Handler accessTokenRequestHandler();
}
