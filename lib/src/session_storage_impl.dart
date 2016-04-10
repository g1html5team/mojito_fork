// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.session.impl;

import 'package:shelf/shelf.dart';
import 'package:shelf_auth_session/shelf_auth_session.dart';

import 'session_storage.dart';
//import 'package:shelf_auth/shelf_auth.dart';


class MojitoSessionStorageImpl implements MojitoSessionStorage {
  Middleware middleware;

  void add(SessionRepository repository) {
    middleware = sessionMiddleware(repository);
  }
}
