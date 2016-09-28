// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito;

import 'dart:io';

import 'package:config/config.dart';
import 'package:logging/logging.dart';
import 'package:mojito/src/config.dart';
import 'package:mojito/src/session_storage.dart';
import 'package:quiver/check.dart';
import 'package:shelf/shelf.dart';

import 'context.dart';
import 'middleware.dart';
import 'mojito_impl.dart' as impl;
import 'router.dart';

typedef Router RouteCreator();

typedef bool IsDevMode();

typedef String EnvironmentNameResolver();

EnvironmentNameResolver defaultEnvironmentNameResolver(IsDevMode isDevMode) {
  checkNotNull(isDevMode);
  return () {
    return isDevMode()
        ? StandardEnvironmentNames.development
        : StandardEnvironmentNames.production;
  };
}

EnvironmentNameResolver environmentNameFromKey(String environmentKey,
    {bool defaultToDevelopment: true}) {
  return () {
    final lookupName = fromEnvironment(environmentKey);
    final name = lookupName != null
        ? lookupName
        : defaultToDevelopment ? StandardEnvironmentNames.development : null;

    if (name == null) {
      throw new StateError(
          'Unable to determine environment name from key: $environmentKey');
    }

    return name;
  };
}

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
    new impl.MojitoImpl.simple(
        createRootRouter: createRootRouter,
        logRequests: logRequests,
        createRootLogger: createRootLogger,
        isDevMode: isDevMode);

Mojito initWithConfig(ConfigFactory<MojitoConfig> configFactory,
        {EnvironmentNameResolver environmentNameResolver}) =>
    new impl.MojitoImpl.fromConfig(configFactory, environmentNameResolver);

abstract class Mojito<C extends MojitoConfig> {
  Router get router;
  C get config;
  MojitoSessionStorage get sessionStorage;
  MojitoMiddleware get middleware;
  MojitoContext get context;
  Handler get handler;

  /// Starts a [HttpServer] on the given [address] and [port].
  ///
  /// If [address] is omitted or `null`, [InternetAddress.ANY_IP_V6] will be
  /// used.
  void start({InternetAddress address, int port: 9999});
}

MojitoContext get context => impl.contextImpl;
