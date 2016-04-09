+++
title = "OAuth (1 and 2) Client"
date = "2016-01-31T09:35:03+11:00"
description = "OAuth (1 and 2) Client"
weight = 32
type = "post"
+++

The Mojito router provides methods to set up the routes required to implement the 'client' part of the [OAuth 2 Authorization Code Flow](http://tools.ietf.org/html/rfc6749#section-4.1) and similar routes for OAuth1

This allows developers to write web applications that interact with OAuth enabled services like:

 - google
 - github
 - bitbucket
 - hipchat
 - many many more

To simplify this even further, mojito supports several authorisation servers out of the box. The following example shows how to add a github client when deploying on Google Appengine using memcache to store the OAuth2 data.

```
final oauth = app.router.oauth;

oauth.gitHub().addClient(
    (_) => new ClientId('your clientId', 'your secret'),
    oauth.storage.memcache(() => context.services.memcache),
    new UriTemplate(
        'http://example.com/loginComplete{?type,token,context}'));
```

You access the route builders for oauth by calling `router.oauth`. From there you have access to out of the box oauth storage (such as memcache and in memory for development), plus customised route builders for common authorisation servers like `github, google and bitbucket` (PRs welcome for more servers).

For other (non out of the box) authorisation servers use the `oauth.oauth2(...)` or `oauth.oauth1(...)` methods.


When you start the above example you will see two routes created for the github flow

```
2015-06-29 08:44:51.503 [INFO] mojito: GET	->	/github/userGrant
2015-06-29 08:44:51.503 [INFO] mojito: GET	->	/github/authToken
```

The `userGrant` route is where you send the users browser to to initiate the flow. It will redirect to github for the user to grant access, upon which github will redirect the user back to the `authToken` route.

On successful completion of the auth flow, the users browser will be redirected back to the url you provided ('http://example.com/loginComplete' in this example) with the query params for `type, token and context` populated accordingly.

A good place to get started with oauth in mojito is to run `oauth.dart` in the [example folder of mojito](https://bitbucket.org/andersmholmgren/mojito/src).

This sets up routes for the out of the box integrations. You can then try it out by opening a browser to the `userGrant` urls such as 

```
http://localhost:9999/oauth/github/userGrant
```

>**Pro Tip**
>
>Mojito uses [shelf_oauth][shelf_oauth] to implement the oauth flows. 

