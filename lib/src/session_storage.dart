// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.session;

//import 'package:shelf_auth/shelf_auth.dart';
import 'package:shelf_auth_session/shelf_auth_session.dart';

abstract class MojitoSessionStorage {
  void add(SessionRepository repository);

//  void inMemory();

//  /// builder for authentication middleware to be applied all routes
//  AuthenticationBuilder get global;
//
//  /// builder for authentication middleware that you choose where to include
//  AuthenticationBuilder builder();

}
