// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.authorisation.impl;

import 'package:shelf_auth/shelf_auth.dart';
import 'authorisation.dart';
import 'base_builder_impl.dart';

class MojitoAuthorisationImpl extends BaseBuilderImpl
    implements MojitoAuthorisation {
  /// builder for authorisation middleware that you choose where to include
  AuthorisationBuilder builder() => new AuthorisationBuilder();

  @override
  MiddlewareBuilder createGlobalBuilder() => new _GlobalAuthBuilder(this);
}

class _GlobalAuthBuilder extends GlobalBuilder with AuthorisationBuilder {
  _GlobalAuthBuilder(MojitoAuthorisationImpl ma) : super(ma);
}
