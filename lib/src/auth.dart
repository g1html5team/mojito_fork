library mojito.auth;

import 'package:shelf_auth/shelf_auth.dart';

abstract class MojitoAuth {

  /// builder for authenitcation middleware to be applied all routes
  AuthenticationBuilder get global;

  /// builder for authenitcation middleware that you choose where to include
  AuthenticationBuilder builder();
}


