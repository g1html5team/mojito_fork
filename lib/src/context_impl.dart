// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.context.impl;

import 'package:shelf_auth/shelf_auth.dart';
import 'context.dart';
import 'preconditions.dart';
import 'package:option/option.dart';

class MojitoContextImpl implements MojitoContext {
  @override
  final bool isDevelopmentMode;

  MojitoContextImpl(this.isDevelopmentMode) {
    ensure(isDevelopmentMode, isNotNull);
  }

  @override
  Option<AuthenticatedContext> get auth => authenticatedContext();
}
