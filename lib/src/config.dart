// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

library mojito.config;

import 'package:config/config.dart';
import 'package:mojito/src/mojito.dart';
import 'package:quiver/core.dart';

class MojitoConfig extends Config<MojitoConfig> {
  final RouteCreator createRootRouter;
  final bool logRequests;
  final bool createRootLogger;

  MojitoConfig(
      {this.createRootRouter, this.logRequests, this.createRootLogger});

  @override
  MojitoConfig merge(MojitoConfig other) {
    return new MojitoConfig(
        createRootRouter: firstNonNull(
            other.createRootRouter, createRootRouter),
        logRequests: firstNonNull(other.logRequests, logRequests, true),
        createRootLogger: firstNonNull(
            other.createRootLogger, createRootLogger, true));
  }
}
