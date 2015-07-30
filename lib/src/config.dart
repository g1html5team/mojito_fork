// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.config;

import 'package:config/config.dart';
import 'package:mojito/src/mojito.dart';
import 'package:quiver/core.dart';
import 'package:mojito/src/router.dart';

class MojitoConfig extends Config<MojitoConfig> {
  final MojitoServerConfig server;

  MojitoConfig({this.server});

  @override
  MojitoConfig merge(MojitoConfig other) {
    return new MojitoConfig(server: mergeChildConfigs(server, other.server));
  }
}

class MojitoServerConfig extends Config<MojitoServerConfig> {
  final RouteCreator createRootRouter;
  final bool logRequests;
  final bool createRootLogger;
  final int serverPort;

  MojitoServerConfig({RouteCreator createRootRouter, this.logRequests: true,
      this.createRootLogger: true, this.serverPort: 9999})
      : this.createRootRouter = firstNonNull(createRootRouter, router);

  @override
  MojitoServerConfig merge(MojitoServerConfig other) {
    return new MojitoServerConfig(
        createRootRouter: firstNonNull(
            other.createRootRouter, createRootRouter),
        logRequests: firstNonNull(other.logRequests, logRequests, true),
        createRootLogger: firstNonNull(
            other.createRootLogger, createRootLogger, true),
        serverPort: firstNonNull(other.serverPort, serverPort, 9999));
  }

  MojitoServerConfig change({RouteCreator createRootRouter}) {
    return new MojitoServerConfig(
        createRootRouter: firstNonNull(createRootRouter, this.createRootRouter),
        logRequests: logRequests,
        createRootLogger: createRootLogger,
        serverPort: serverPort);
  }
}
