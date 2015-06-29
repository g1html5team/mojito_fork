import 'package:mojito/mojito.dart';
import 'dart:async';
import 'package:uri/uri.dart';
import 'package:option/option.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

main() {
  var app = init(isDevMode: () => true);
  Logger.root.level = Level.ALL;

  app.auth.global
//      .basic(_lookup)
      .authenticator(new TestAuthenticator())
      .jwtSession('moi', 'shh', (username) => _lookup(username, null))
        ..allowHttp = true
        ..allowAnonymousAccess = true;

  app.sessionStorage.add(new InMemorySessionRepository());

  final loginCompleteTemplate =
      new UriTemplate('/ui/loginComplete{?type,token,context}');

  app.router
    ..get('/ui/loginComplete{?type,token,context}',
        (String type, String token, String context) => "yippee")
    ..addAll((Router r) {
      final storage = r.oauth.storage.inMemory();

      r.oauth.gitHub().addClient(
          (_) => new ClientId('b809a75bb449d81e7234',
              'cad56a6f39361f31ba5b5ffa11f6722536004f08'),
          storage,
          loginCompleteTemplate);

      r.oauth.bitBucket().addClient(
          (_) => new ClientId(
              'v7hRrM2WRpQe2Nff86', 'pLfwBAa7aBESdzWusUGaNU2S5RH2RScD'),
          storage,
          loginCompleteTemplate);

      r.oauth.google().addClient(
          (_) => new ClientId(
              '986084708845-etbrd3jkeddhsc5119pfl16cbl502e7j.apps.googleusercontent.com',
              'e28hMJcnXM4_f_VGgRRIR9Pt'),
          storage,
          loginCompleteTemplate,
          scopes: ['email']);
    }, path: 'oauth');

  app.start();
}

Future<Option<Principal>> _lookup(String username, String password) {
  return new Future.value(new Some(new Principal(username)));
}

class TestAuthenticator extends Authenticator {
  Future<Option<AuthenticatedContext<Principal>>> authenticate(
      Request request) async {
    return await new Some(new SessionAuthenticatedContext(
        new Principal('fred'),
        new Uuid().v4(),
        new DateTime.now(),
        new DateTime.now(),
        new DateTime.now().add(const Duration(days: 30))));
  }

  bool get readsBody => false;
}
