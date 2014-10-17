library mojito.context;

import 'package:shelf_auth/shelf_auth.dart';
import 'package:option/option.dart';

//MojitoContext contextFromRequest(Request request) =>
//    new MojitoContextImpl();

abstract class MojitoContext {
  Option<AuthenticatedContext> get auth;

//  factory MojitoContext() => new MojitoContextImpl();
}