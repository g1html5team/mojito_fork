// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.auth.oauth1;


import 'package:shelf/shelf.dart';
import 'dart:async';
import 'package:option/option.dart';
import 'oauth1_impl.dart';
import 'preconditions.dart';

abstract class OAuth1RequestTokenSecretStore {
  // TODO: need to include oauth provider as part of key as the authToken's
  // will not be guaranteed to be unique across providers. Although probably
  // low odds of getting duped tokens given the are short lived.
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

class OAuth1Provider {
  final Uri requestTokenUrl;
  final Uri accessTokenUrl;
  final Uri authenticationUrl;

  const OAuth1Provider(this.requestTokenUrl, this.accessTokenUrl,
      this.authenticationUrl);
}

// Duping from oauth lib to avoid exposing dependency????
class Token {
  /// The token (public) key
  final String key;
  /// The token secret
  final String secret;

  /// Constructs a new token
  Token(this.key, this.secret);
}


abstract class OAuth1ProviderHandlers {
  factory OAuth1ProviderHandlers(Token consumerToken,
      OAuth1Provider oauthProvider, String callbackUrl,
      OAuth1RequestTokenSecretStore tokenStore) {

    return new OAuth1ProviderHandlersImpl(consumerToken, oauthProvider,
        callbackUrl, tokenStore);
  }


  Handler tokenRequestHandler();

  Handler accessTokenRequestHandler();
}
