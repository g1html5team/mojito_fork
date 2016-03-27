+++
title = "Route Specific Authentication"
date = "2016-01-31T09:35:03+11:00"
description = "Route Specific Authentication"
weight = 53
type = "post"
+++


To apply a particular authentication to only some routes use the auth `builder()` and add it using the named parameter `middleware` on the desired route.

```
  var randomAuthenticator = (app.auth
      .builder()
      .authenticator(new RandomNameAuthenticator())..allowHttp = true).build();

  app.router
    ..get(
        '/randomness',
        () {
          String username = context.auth
              .map((authContext) => authContext.principal.name)
              .getOrElse(() => 'guest');

          return 'who are you today $username';
        },
        middleware: randomAuthenticator);
```

Here the `'/randomness'` route has `middleware: randomAuthenticator` which applies that authenticator to the route. 

> **Pro Tips**
> 
>* If you add authentication middleware to a route defined with `router.addAll` then it will apply to all it's child routes.
>* See basic_example.dart in the examples folder to see how `RandomNameAuthenticator` is implemented
>* mojito uses [shelf_auth][shelf_auth] for authentication support. Consult the [shelf_auth docs][shelf_auth] for more details
