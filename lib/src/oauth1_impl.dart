// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.auth.oauth1.impl;


import 'package:shelf/shelf.dart';
//import 'package:shelf_auth/shelf_auth.dart';
import 'package:oauth/oauth.dart';
import 'package:uri/uri.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import 'dart:math';
import 'dart:async';
import 'package:shelf_exception_response/exception.dart';
import 'oauth1.dart';

class OAuth1ProviderHandlersImpl implements OAuth1ProviderHandlers {
  final Token consumerToken;
  final String requestTokenUrl;
  final String authenticationUrl;
  final String accessTokenUrl;
  final String callbackUrl;
  final OAuth1RequestTokenSecretStore tokenStore;

  OAuth1ProviderHandlersImpl(String consumerKey, String consumerSecret,
      this.requestTokenUrl, this.accessTokenUrl,
      this.authenticationUrl, this.callbackUrl, this.tokenStore)
      : this.consumerToken = new Token(consumerKey, consumerSecret);

  Handler tokenRequestHandler() {
    return (Request request) => _authRedirect();
  }

  Handler accessTokenRequestHandler() => _fetchAccessToken;

  Future<Response> _authRedirect() {
    var requestTokenUri =
      (new UriBuilder.fromUri(Uri.parse(requestTokenUrl))
          ..queryParameters={'oauth_callback': callbackUrl})
      .build();

    print(requestTokenUri);

    final request = new http.Request("POST", requestTokenUri);
    final params = generateParameters(request, consumerToken, null, _nonce(),
      new DateTime.now().millisecondsSinceEpoch ~/ 1000);

    print(params);

    final fullUrl = (new UriBuilder.fromUri(requestTokenUri)..queryParameters.addAll(params)).build();
    print(fullUrl);

  //  final bbClient = new Client(consumerToken, client: new http.IOClient());

    final oauthProviderClient = new http.IOClient();

    return oauthProviderClient.post(fullUrl).then((http.Response response) {
      print(response.statusCode);
  //    print(response.headers['oauth_token_secret']);
      final body = response.body;
      final m = Uri.splitQueryString(body);
      print(response.body);
      final authToken = m['oauth_token'];
      final authTokenSecret = m['oauth_token_secret'];
      // TODO: gonna need to remember this (session state)!!! => memcache
      print(authToken);
      print(authTokenSecret);

      return tokenStore.storeSecret(authToken, authTokenSecret).then((_) {
        final authUri = (new UriBuilder.fromUri(
            Uri.parse(authenticationUrl))
          ..queryParameters = {
            'oauth_token' : authToken
        }).build();

        return new Response.seeOther(authUri);
      });
    }).whenComplete(() {
      print('done');
    });

  }

  Future<Response> _fetchAccessToken(Request req) {
    print('_fetchAccessToken: ${req.requestedUri}');

    final queryParams = req.url.queryParameters;
    final authVerifier = queryParams['oauth_verifier'];
    final authToken = queryParams['oauth_token'];

    return tokenStore.consumeSecret(authToken).then((secretOpt) {
      return secretOpt.map((secret) =>
          _requestAuthToken(authToken, secret, authVerifier)
      ).getOrElse(() {
        // token either expired or dodgy
        throw new UnauthorizedException({}, 'no matching token');
      });
    });

  }

  Future<Response> _requestAuthToken(String authToken, String secret, String authVerifier) {
    Token userToken = new Token(authToken, secret);

    print('authVerifier: $authVerifier; authToken: $authToken');

    var accessTokenUri =
      (new UriBuilder.fromUri(Uri.parse(accessTokenUrl))
          ..queryParameters={ 'oauth_verifier': authVerifier })
      .build();

    print(accessTokenUri);

    final request = new http.Request("POST", accessTokenUri);
    final params = generateParameters(request, consumerToken, userToken, _nonce(15),
      new DateTime.now().millisecondsSinceEpoch ~/ 1000);

    print(params);

    final fullUrl = (new UriBuilder.fromUri(accessTokenUri)
      ..queryParameters.addAll(params))
      .build();
    print(fullUrl);

          //  final bbClient = new Client(consumerToken, client: new http.IOClient());

    final oauthProviderClient = new http.IOClient();

    return oauthProviderClient.post(fullUrl).then((http.Response response) {
      print(response.statusCode);
          //    print(response.headers['oauth_token_secret']);
      final body = response.body;
      final m = Uri.splitQueryString(body);
      print(response.body);
      final authToken = m['oauth_token'];
      print(authToken);
      final authTokenSecret = m['oauth_token_secret'];
      print(authTokenSecret);

      return new Response.ok('ohYeah');

    });
  }

}


String _nonce([int size = 8]) {
  var r = new Random();
  final n = new List<int>.generate(size, (_) => r.nextInt(255), growable: false);
  String nonceStr = crypto.CryptoUtils.bytesToBase64(n, urlSafe: true);
  return nonceStr;
}
