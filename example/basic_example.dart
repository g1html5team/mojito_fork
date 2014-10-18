import 'package:mojito/mojito.dart';
import 'dart:async';
import 'package:option/option.dart';

main() {
  final app = init();

  app.auth.global
    .basic(_lookup)
    ..allowHttp=true
    ..allowAnonymousAccess=true;

  app.proxyPubServe();

  app.router..get('/hi', () {
    String username = app.context.auth.map((authContext) =>
        authContext.principal.name)
        .getOrElse(() => 'guest');

    return 'hello $username';
  });

  app.start();

}

Future<Option<Principal>> _lookup(String username, String password) {
  return new Future.value(new Some(new Principal(username)));
}