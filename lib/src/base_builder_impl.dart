// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.middleware.builder.impl;

import 'package:shelf/shelf.dart';

abstract class MiddlewareBuilder {
  Middleware build();
}

abstract class BaseBuilderImpl<T extends MiddlewareBuilder> {
  Middleware _middleware;
  T _global;

  Middleware get middleware {
    if (_global != null) {
      return _middleware != null ? _middleware : _global.build();
    }

    return null;
  }

  BaseBuilderImpl();

  /// builder for authentication middleware to be applied all routes
  T get global {
    if (_global == null) {
      _global = createGlobalBuilder();
    }
    return _global;
  }

  MiddlewareBuilder createGlobalBuilder();
}

class GlobalBuilder implements MiddlewareBuilder {
  final BaseBuilderImpl _ma;

  GlobalBuilder(this._ma);

  @override
  Middleware build() {
    final m = super.build();
    _ma._middleware = m;
    return m;
  }
}
