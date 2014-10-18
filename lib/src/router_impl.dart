// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.router.impl;

import 'package:shelf/shelf.dart';
import 'package:shelf_route/extend.dart' as r;
import 'package:shelf_rest/shelf_rest.dart';
import 'router.dart';

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

    addAll(bindResource(resource, validateParameters: validateParameters,
                        validateReturn: validateReturn),
                        middleware: middleware,
                        handlerAdapter: handlerAdapter,
                        path: path);
  }

  @override
  RouterImpl createChild(r.HandlerAdapter ha, r.PathAdapter pa, path,
                             Middleware middleware) =>
      new RouterImpl(fallbackHandler: fallbackHandler,
          handlerAdapter: ha, pathAdapter: pa, path: path,
          middleware: middleware);
}


Handler noopHandlerAdapter(Handler handler) => handler;
