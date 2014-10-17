import 'package:mojito/mojito.dart' as mojito;
import 'package:shelf_auth/shelf_auth.dart';
import 'dart:async';
import 'package:option/option.dart';

main() {
  final app = mojito.init();

  app.auth.basic(_lookup, allowHttp: true);

  app.router..get('/', () {
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