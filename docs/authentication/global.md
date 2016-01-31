+++
title = "Global Authentication"
date = "2016-01-31T09:35:03+11:00"
description = "Global Authentication"
weight = 51
type = "post"
+++


For example the following sets the application to use basic authentication, allowing access over http (a bad idea other than in development) and allows anonymous access. 

```
  app.auth.global
    .basic(_lookup)
    ..allowHttp=true
    ..allowAnonymousAccess=true;
```

*Note the `allowAnonymousAccess` is actually a form of authorisation (rather than authentication) and is simply a convenience. See the Authorisation section below for more options.*


