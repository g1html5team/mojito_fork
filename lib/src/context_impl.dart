library mojito.context.impl;

import 'package:shelf/shelf.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'context.dart';
import '../mojito.dart'; // TODO: fix hideous dependency loops
import 'package:option/option.dart';

class MojitoContextImpl implements MojitoContext {

  MojitoContextImpl() {}

  @override
  Option<AuthenticatedContext> get auth => _auth;

  Option<AuthenticatedContext> _auth = const None();
}

void setAuthContext(Option<AuthenticatedContext> authContext) {
  (context as MojitoContextImpl)._auth = authContext;
}
