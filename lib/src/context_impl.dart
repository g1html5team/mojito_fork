library mojito.context.impl;

import 'package:shelf_auth/shelf_auth.dart';
import 'context.dart';
import 'package:option/option.dart';

class MojitoContextImpl implements MojitoContext {
  @override
  Option<AuthenticatedContext> get auth => authenticatedContext();
}

