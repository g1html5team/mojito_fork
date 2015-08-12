// Copyright (c) 2015, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

import 'package:mojito/mojito.dart';
import 'package:shelf_proxy/shelf_proxy.dart';

main() {
  final app = init(isDevMode: () => true);

  app.router
    ..add('ui', null, proxyHandler('http://ui.example.com'), exactMatch: false)
    ..add('api', null, proxyHandler('http://api.example.com'),
        exactMatch: false);

  app.start();
}
