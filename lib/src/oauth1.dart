// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.auth.oauth1;


import 'package:shelf/shelf.dart';
//import 'package:shelf_auth/shelf_auth.dart';
import 'package:oauth/oauth.dart';
import 'package:uri/uri.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import 'dart:math';
import 'dart:async';

String _dodgySessionHackAuthTokenSecret;

class OAuth1Dancer {
  final Token consumerToken;
  final String requestTokenUrl;
  final String authenticationUrl;
  final String accessTokenUrl;
  final String callbackUrl;

  OAuth1Dancer(String consumerKey, String consumerSecret,
      this.requestTokenUrl, this.accessTokenUrl,
      this.authenticationUrl, this.callbackUrl)
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
      _dodgySessionHackAuthTokenSecret = authTokenSecret;
      print(authToken);
      print(authTokenSecret);
      final authUri = (new UriBuilder.fromUri(
          Uri.parse(authenticationUrl))
        ..queryParameters = {
          'oauth_token' : authToken
      }).build();

      return new Response.seeOther(authUri);
    }).whenComplete(() {
      print('done');
    });

  }

  Future<Response> _fetchAccessToken(Request req) {
    print('_fetchAccessToken: ${req.requestedUri}');
//    oauth_verifier=2287965216&
//    oauth_token=YRpuxpCLYCJpXJyUE2&

    final queryParams = req.url.queryParameters;
    final authVerifier = queryParams['oauth_verifier'];
    final authToken = queryParams['oauth_token'];

    Token userToken = new Token(authToken, _dodgySessionHackAuthTokenSecret);

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
    }).whenComplete(() {
      print('done');
    });

  }

}


String _nonce([int size = 8]) {
  var r = new Random();
  final n = new List<int>.generate(size, (_) => r.nextInt(255), growable: false);
  String nonceStr = crypto.CryptoUtils.bytesToBase64(n, urlSafe: true);
  return nonceStr;
}
