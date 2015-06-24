// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.auth;

import 'package:shelf_auth/shelf_auth.dart';

abstract class MojitoAuth {
  /// builder for authenitcation middleware to be applied all routes
  AuthenticationBuilder get global;

  /// builder for authenitcation middleware that you choose where to include
  AuthenticationBuilder builder();
}
