// Copyright (c) 2015, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:mojito/mojito.dart';
import 'package:option/option.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    print(r);
  });

  final app = init(isDevMode: () => true);

  app.auth.global
      .basic(_lookup)
      .jwtSession('moi', 'shh', (username) => _lookup(username, null))
        ..allowHttp = true
        ..allowAnonymousAccess = true;

  var randomAuthenticator = (app.auth
          .builder()
          .authenticator(new RandomNameAuthenticator())..allowHttp = true)
      .build();

  app.sessionStorage.add(new InMemorySessionRepository());

  app.router
    ..get('/hi', () {
      String username = context.auth
          .map((authContext) => authContext.principal.name)
          .getOrElse(() => 'guest');

      return 'hello $username';
    })
    // try me: curl 'http://localhost:9999/privates' -H 'Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='
    ..get('privates', () => 'this is only for the privileged few',
        middleware: app.authorisation.builder().authenticatedOnly().build())
    ..get('randomness', () {
      String username = context.auth
          .map((authContext) => authContext.principal.name)
          .getOrElse(() => 'guest');

      return 'who are you today $username';
    }, middleware: randomAuthenticator)
//    ..get('fooo{?name}', (String name) => {'foo': name},
//        middleware: randomAuthenticator)
//    ..post('fooo', (Map m) => m, middleware: randomAuthenticator)
    ..addStaticAssetHandler('/ui');

  app.start();
}

Future<Option<Principal>> _lookup(String username, String password) {
  return new Future.value(new Some(new Principal(username)));
}

class RandomNameAuthenticator extends Authenticator {
  static List<String> _names = ['wilma', 'fred', 'dino'];

  Future<Option<AuthenticatedContext<Principal>>> authenticate(
      Request request) async {
    var name = _names[new Random().nextInt(3)];
    return await new Some(new SessionAuthenticatedContext(
        new Principal(name),
        new Uuid().v4(),
        new DateTime.now(),
        new DateTime.now(),
        new DateTime.now().add(const Duration(days: 30))));
  }

  bool get readsBody => false;
}
