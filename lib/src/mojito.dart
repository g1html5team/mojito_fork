// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito;

import 'context.dart';
import 'package:shelf/shelf.dart';
import 'router.dart';
import 'auth.dart';
import 'mojito_impl.dart' as impl;
import 'middleware.dart';
import 'package:logging/logging.dart';
import 'package:mojito/src/session_storage.dart';

typedef LogRecordProcessor(LogRecord logRecord);


typedef Router RouteCreator();

typedef bool IsDevMode();

const String MOJITO_IS_DEV_MODE_ENV_VARIABLE = 'MOJITO_IS_DEV_MODE';


/// if provided the [perRequestLogProcessor] will be subscribed to log events
/// on the root logger during processing of each request. This allows
/// integration with external logging services on PAAS providers.
///
/// By default the environment variable `MOJITO_IS_DEV_MODE` is used to
/// determine if the server is running in development mode. This can be
/// overriden by providing [isDevMode]. For example in appengine you can do
///
///     isDevMode: () => const String.fromEnvironment('GAE_PARTITION') == 'dev'
///
Mojito init({ RouteCreator createRootRouter, bool logRequests: true,
            LogRecordProcessor perRequestLogProcessor,
            IsDevMode isDevMode }) =>
    new impl.MojitoImpl(createRootRouter, logRequests,
      perRequestLogProcessor: perRequestLogProcessor,
      isDevMode: isDevMode);

abstract class Mojito {
  Router get router;
  MojitoAuth get auth;
  MojitoSessionStorage get sessionStorage;
  MojitoMiddleware get middleware;
  MojitoContext get context;
  Handler get handler;

  void start({ int port: 9999 });
}


MojitoContext get context => impl.context;