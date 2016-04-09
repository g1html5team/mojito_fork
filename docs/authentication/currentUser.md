+++
title = "Currently Authenticated User"
date = "2016-01-31T09:35:03+11:00"
description = "Currently Authenticated User"
weight = 52
type = "post"
+++


The currently authenticated user (if there is one) is available via the mojito context.

It is defined as an `Option` which will be `None` if there is no currently authenticated user and `Some` if there is.

For example, the following gets the logged in user's username, if there is one, or sets it to `'guest'` otherwise.

```
app.router..get('/hi', () {
  var username = context.auth.map((authContext) =>
      authContext.principal.name)
      .getOrElse(() => 'guest');

  return 'hello $username';
});
```
