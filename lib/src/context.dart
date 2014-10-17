library mojito.context;

import 'package:shelf/shelf.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'context_impl.dart';
import 'package:option/option.dart';

MojitoContext contextFromRequest(Request request) =>
    new MojitoContext();

abstract class MojitoContext {
  Option<AuthenticatedContext> get auth;

  factory MojitoContext() => new MojitoContextImpl();
}