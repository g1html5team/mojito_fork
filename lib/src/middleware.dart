// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.middleware;

import 'package:shelf/shelf.dart';

import 'middleware_impl.dart';

abstract class MojitoMiddleware {
  /// builder for middleware to be applied all routes
  MiddlewareBuilder get global;

  /// builder for middleware that you choose where to include
  MiddlewareBuilder builder();
}

abstract class MiddlewareBuilder {
  factory MiddlewareBuilder() = MiddlewareBuilderImpl;

  MiddlewareBuilder addMiddleware(Middleware middleware);

  MiddlewareBuilder logRequests({void logger(String msg, bool isError)});

  MiddlewareBuilder cors({String domain: '*'});

  Middleware build();
}
