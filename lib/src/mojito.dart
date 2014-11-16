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

/// if provided the [perRequestLogProcessor] will be subscribed to log events
/// on the root logger during processing of each request. This allows
/// integration with external logging services on PAAS providers
Mojito init({ RouteCreator createRootRouter, bool logRequests: true,
            LogRecordProcessor perRequestLogProcessor }) =>
    new impl.MojitoImpl(createRootRouter, logRequests,
      perRequestLogProcessor: perRequestLogProcessor);

abstract class Mojito {
  Router get router;
  MojitoAuth get auth;
  MojitoSessionStorage get sessionStorage;
  MojitoMiddleware get middleware;
  MojitoContext get context;
  Handler get handler;

  void proxyPubServe({int port: 8080});

  void start({ int port: 9999 });
}


MojitoContext get context => impl.context;