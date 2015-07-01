// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.auth.impl;

import 'package:shelf_auth/shelf_auth.dart';
import 'auth.dart';
import 'base_builder_impl.dart';

class MojitoAuthImpl extends BaseBuilderImpl implements MojitoAuth {
  /// builder for authentication middleware that you choose where to include
  AuthenticationBuilder builder() => new AuthenticationBuilder();

  @override
  MiddlewareBuilder createGlobalBuilder() => new _GlobalAuthBuilder(this);
}

class _GlobalAuthBuilder extends GlobalBuilder with AuthenticationBuilder {
  _GlobalAuthBuilder(MojitoAuthImpl ma) : super(ma);
}
