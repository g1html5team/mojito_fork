// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.router;

import 'package:shelf/shelf.dart';
import 'package:shelf_route/shelf_route.dart' as r;
import 'router_impl.dart';

/// A shelf_route router that adds some methods
abstract class Router implements r.Router<Router> {

  /// add a shelf_rest REST resource
  void resource(resource, {path, Middleware middleware,
      r.HandlerAdapter handlerAdapter});
}

/// Creates a mojito router
Router router({ r.HandlerAdapter handlerAdapter: noopHandlerAdapter,
  r.PathAdapter pathAdapter: r.uriTemplatePattern, Function fallbackHandler,
  Middleware middleware}) =>
    new RouterImpl(handlerAdapter: handlerAdapter, pathAdapter: pathAdapter,
      fallbackHandler: fallbackHandler, middleware: middleware);
