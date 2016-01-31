+++
title = "Authorisation"
date = "2016-01-31T09:35:03+11:00"
description = "Authorisation"
weight = 60
type = "post"
+++

Mojito exposes helpers for setting up authorisation via `app.authorisation`. Similarly to authentication, if you want to apply it to all routes then use the `global` builder, otherwise use the `builder()`.

The following shows how to enforce that only authenticated users can access a particular route. This is useful, for example if you set up a global authenticator that allows anonymous access and you want to block anonymous access to some routes.
 
```
app.router.get('privates', () => 'this is only for the privileged few',
        middleware: app.authorisation.builder().authenticatedOnly().build())
```

> **Pro Tip**
> 
>* Mojito uses [shelf_auth][shelf_auth] for authorisation support. Consult the [shelf_auth docs][shelf_auth] for more details
