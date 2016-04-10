// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.context;

import 'package:mojito/src/mojito.dart';
import 'package:option/option.dart';
import 'package:shelf_auth/shelf_auth.dart';

abstract class MojitoContext<M extends Mojito> {
  Option<AuthenticatedContext> get auth;

  bool get isDevelopmentMode;

  M get app;
}
