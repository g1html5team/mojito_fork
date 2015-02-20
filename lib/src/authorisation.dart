// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.authorisation;

import 'package:shelf_auth/shelf_auth.dart';

abstract class MojitoAuthorisation {

  /// builder for authorisation middleware to be applied all routes
  AuthorisationBuilder get global;

  /// builder for authorisation middleware that you choose where to include
  AuthorisationBuilder builder();
}
