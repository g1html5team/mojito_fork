// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.context.impl;

import 'package:mojito/src/mojito.dart';

import 'context.dart';
import 'preconditions.dart';

class MojitoContextImpl implements MojitoContext {
  @override
  final bool isDevelopmentMode;

  final Mojito app;

  MojitoContextImpl(this.isDevelopmentMode, this.app) {
    ensure(isDevelopmentMode, isNotNull);
  }
}
