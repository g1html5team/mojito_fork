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
import 'package:config/config.dart';
import 'package:mojito/src/config.dart';
import 'dart:io';

typedef Router RouteCreator();

typedef bool IsDevMode();

typedef String EnvironmentNameResolver();

EnvironmentNameResolver defaultEnvironmentNameResolver(IsDevMode isDevMode) {
  return () {
    return isDevMode()
        ? StandardEnvironmentNames.development
        : StandardEnvironmentNames.production;
  };
}

EnvironmentNameResolver environmentNameFromKey(String environmentKey,
    {bool defaultToDevelopment: true}) {
  return () {
    final lookupName = _rawFromEnvironment(environmentKey);
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

String _rawFromEnvironment(String key) {
  final String systemProperty = new String.fromEnvironment(key);
  if (systemProperty != null) {
    return systemProperty;
  }

  return Platform.environment[key];
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
Mojito init({RouteCreator createRootRouter, bool logRequests: true,
    bool createRootLogger: true, IsDevMode isDevMode,
    ConfigFactory configFactory}) => new impl.MojitoImpl(
    createRootRouter, logRequests, createRootLogger, isDevMode: isDevMode);

Mojito initWithConfig(ConfigFactory<MojitoConfig> configFactory,
        {EnvironmentNameResolver environmentNameResolver}) =>
    new impl.MojitoImpl.fromConfig(configFactory, environmentNameResolver);

abstract class Mojito<C extends MojitoConfig> {
  Router get router;
  C get config;
  MojitoAuth get auth;
  MojitoAuthorisation get authorisation;
  MojitoSessionStorage get sessionStorage;
  MojitoMiddleware get middleware;
  MojitoContext get context;
  Handler get handler;

  void start({int port: 9999});
}

MojitoContext get context => impl.context;
