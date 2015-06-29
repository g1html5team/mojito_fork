// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito;

import 'context.dart';
import 'package:shelf/shelf.dart';
import 'router.dart';
import 'auth.dart';
import 'authorisation.dart';
import 'mojito_impl.dart' as impl;
import 'middleware.dart';
import 'package:logging/logging.dart';
import 'package:mojito/src/session_storage.dart';
import 'package:mojito/src/oauth.dart';

typedef Router RouteCreator();

typedef bool IsDevMode();

const String MOJITO_IS_DEV_MODE_ENV_VARIABLE = 'MOJITO_IS_DEV_MODE';

/// By default the environment variable `MOJITO_IS_DEV_MODE` is used to
/// determine if the server is running in development mode. This can be
/// overridden by providing [isDevMode]. For example in appengine you can do
///
///     isDevMode: () => const String.fromEnvironment('GAE_PARTITION') == 'dev'
///
/// By default mojito will create a root [Logger]. If you want to control the
/// setup of the logger yourself then pass [createRootLogger]: false
Mojito init(
        {RouteCreator createRootRouter,
        bool logRequests: true,
        bool createRootLogger: true,
        IsDevMode isDevMode}) =>
    new impl.MojitoImpl(createRootRouter, logRequests, createRootLogger,
        isDevMode: isDevMode);

abstract class Mojito {
  Router get router;
  MojitoAuth get auth;
  MojitoAuthorisation get authorisation;
  MojitoSessionStorage get sessionStorage;
  MojitoMiddleware get middleware;
  MojitoContext get context;
  Handler get handler;

  void start({int port: 9999});
}

MojitoContext get context => impl.context;
