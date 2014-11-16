// Copyright (c) 2014, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

import 'package:mojito/mojito.dart';
import 'dart:async';
import 'package:option/option.dart';
import 'package:logging/logging.dart';

main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    print(r);
  });

  final app = init(isDevMode: () => true);

  app.auth.global
    .basic(_lookup)
    .jwtSession('moi', 'shh', (username) => _lookup(username, null))
    ..allowHttp=true
    ..allowAnonymousAccess=true;

  app.sessionStorage.add(new InMemorySessionRepository());

  app.router..get('/hi', () {
    String username = app.context.auth.map((authContext) =>
        authContext.principal.name)
        .getOrElse(() => 'guest');

    return 'hello $username';
  })
  ..addStaticAssetHandler('/ui');

  app.start();

}

Future<Option<Principal>> _lookup(String username, String password) {
  return new Future.value(new Some(new Principal(username)));
}