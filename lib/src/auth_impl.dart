// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.auth.impl;

import 'package:shelf/shelf.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'auth.dart';
import 'package:oauth/oauth.dart' as oauth;
import 'package:uri/uri.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import 'dart:math';
import 'dart:async';


class MojitoAuthImpl implements MojitoAuth {
  Middleware _middleware;
  AuthenticationBuilder _global;

  Middleware get middleware {
    if (_global != null) {
      return _middleware != null ?  _middleware : _global.build();
    }

    return null;
  }

  MojitoAuthImpl();

  /// builder for authenitcation middleware to be applied all routes
  AuthenticationBuilder get global {
    if (_global == null) {
      _global = new _GlobalAuthBuilder(this);
    }
    return _global;
  }

  /// builder for authenitcation middleware that you choose where to include
  AuthenticationBuilder builder() => new AuthenticationBuilder();


  Handler oauth1TokenRequestHandler(String consumerKey, String consumerSecret,
                            String requestTokenUrl, String authenticationUrl,
                            String callbackUrl) {
    return (Request request) =>
        _authRedirect(consumerKey, consumerSecret, requestTokenUrl,
            authenticationUrl, callbackUrl);
  }

}


class _GlobalAuthBuilder extends AuthenticationBuilder {
  final MojitoAuthImpl _ma;

  _GlobalAuthBuilder(this._ma);

  @override
  Middleware build() {
    final m = super.build();
    _ma._middleware = m;
    return m;
  }
}



