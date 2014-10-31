// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.router.impl;

import 'package:shelf/shelf.dart';
import 'package:shelf_route/extend.dart' as r;
import 'package:shelf_rest/shelf_rest.dart';
import 'router.dart';
import 'package:shelf_oauth/shelf_oauth.dart';

class RouterImpl extends r.RouterImpl<Router> implements Router {
  RouterImpl({Function fallbackHandler,
    r.HandlerAdapter handlerAdapter: noopHandlerAdapter,
    r.PathAdapter pathAdapter: r.uriTemplatePattern,
    Middleware middleware, path: '/'})
      : super(fallbackHandler: fallbackHandler,
          handlerAdapter: handlerAdapter,
          pathAdapter: pathAdapter,
          path: path);

  void resource(resource, {path, Middleware middleware,
      r.HandlerAdapter handlerAdapter,
      bool validateParameters: true, bool validateReturn: false }) {

    final routeable = resource is r.RouteableFunction ? resource
        : bindResource(resource, validateParameters: validateParameters,
                                  validateReturn: validateReturn);
    addAll(routeable, middleware: middleware, handlerAdapter: handlerAdapter,
        path: path);
  }

  @override
  RouterImpl createChild(r.HandlerAdapter ha, r.PathAdapter pa, path,
                             Middleware middleware) =>
      new RouterImpl(fallbackHandler: fallbackHandler,
          handlerAdapter: ha, pathAdapter: pa, path: path,
          middleware: middleware);


  @override
  void addOAuth1Provider(path,
                         Token consumerToken,
                         OAuth1Provider oauthProvider,
                         OAuth1RequestTokenSecretStore tokenStore,
                         { requestTokenPath: '/requestToken',
                           authTokenPath: '/authToken',
                           String callbackUrl }) {
    final atp = authTokenPath.toString();

    final cb = callbackUrl != null ? callbackUrl :
      atp.startsWith('/') ? atp.substring(1) : atp;

    final dancer = new OAuth1ProviderHandlers(consumerToken, oauthProvider,
        cb, tokenStore);

    addAll((Router r) => r
        ..get(requestTokenPath, dancer.tokenRequestHandler())
        ..get(authTokenPath, dancer.accessTokenRequestHandler()),
        path: path);
  }
}


Handler noopHandlerAdapter(Handler handler) => handler;
