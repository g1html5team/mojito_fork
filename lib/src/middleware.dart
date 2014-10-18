library mojito.middleware;

import 'package:shelf/shelf.dart';

abstract class MojitoMiddleware {

  /// builder for middleware to be applied all routes
  MiddlewareBuilder get global;

  /// builder for middleware that you choose where to include
  MiddlewareBuilder builder();
}


abstract class MiddlewareBuilder {
  MiddlewareBuilder addMiddleware(Middleware middleware);

  MiddlewareBuilder logRequests({void logger(String msg, bool isError)});


  Middleware build();
}