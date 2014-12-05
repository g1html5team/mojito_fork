// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.context;

import 'package:shelf_auth/shelf_auth.dart';
import 'package:option/option.dart';

//MojitoContext contextFromRequest(Request request) =>
//    new MojitoContextImpl();

abstract class MojitoContext {
  Option<AuthenticatedContext> get auth;
//  Option<Session> get session;

  bool get isDevelopmentMode;

//  factory MojitoContext() => new MojitoContextImpl();
}