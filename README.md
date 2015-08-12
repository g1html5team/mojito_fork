# A micro framework for modern web apps built from the ground up on the shelf framework

[![Build Status](https://drone.io/bitbucket.org/andersmholmgren/mojito/status.png)](https://drone.io/bitbucket.org/andersmholmgren/mojito/latest)
[![Pub Version](http://img.shields.io/pub/v/mojito.svg)](https://pub.dartlang.org/packages/mojito)

## Introduction


A micro framework for modern web apps built from the ground up on the [Shelf Framework](https://api.dartlang.org/apidocs/channels/be/dartdoc-viewer/shelf). 

Like its namesake, Mojito is mostly sugar and a blend of other ingredients.
Mojito is deliberately a very thin layer over several shelf packages and focuses
 on the overall experience of building an application. 

The focus of Mojito is on modern rich web apps that have a clean separation of 
ui from services. As such it doesn't bundle any server side templating packages 
although these can be easily added.  

The core architecture of Mojito is shelf itself. All components are existing pub 
packages that are built from the ground up as shelf components. This makes it 
super easy to take advantage of any new shelf based packages that come along in 
the future

## Usage

### Getting Started

To create a web server and start it on port 9999 type the following in a file and run it.

```
import 'package:mojito/mojito.dart';

main() {
  var app = init();
  app.start();
}
```

You should see output like

```
2015-06-28 13:03:27.123 [INFO] mojito: Serving at http://:::9999
```

This won't do anything interesting though as we haven't added any routes.

Lets fix that now

```
main() {
  var app = init();

  app.router.get('/hi', () => 'hi');

  app.start();
}
```

This time when you start it up you should also see something like

```
2015-06-28 13:06:31.957 [INFO] mojito: GET	->	/hi
```

Try it out with curl

```
 curl http://localhost:9999/hi
```

and you should see the expected response of 'hi'

## Development Mode

Mojito has a concept of a development mode that helps make for a quick dev loop. By default it will activate dev mode based on an environment variable `MOJITO_IS_DEV_MODE`. You can activate this in a shell prompt like

```
export MOJITO_IS_DEV_MODE=true
```

You can easily override how the dev mode is determined when you initialise mojito. For example

```
var app = init(isDevMode: () => true);
```

sets it to always on. Typically you don't want to do that though. 

If you run on appengine then the following can be used to set the dev mode.

```
var app = init(isDevMode: () => Platform.environment['GAE_PARTITION'] == 'dev');
```

## Routing

[Mojito][mojito] comes with a very feature rich router. You access the root router by calling `app.router`. It supports several styles for creating routes such as:

* route annotations
```
@Get('{accountId}')
Account find(String accountId) => new Account.build(accountId: accountId);
```
* using the fluent Router api
```
router.get('{accountId}', (String accountId) => new Account.build(accountId: accountId));
```
* in built support for CRUD style methods and so on

All styles support:

 - adding middleware at any point in the route hierarchy
 - automatic conversion to / from JSON and your Dart classes

To get a good overview of the options you have, read the blog post [Routing Options in Shelf][routing_blog].

The mojito router extends [shelf_rest][shelf_rest]'s router. As this is documented extensively in the [shelf_rest documentation][shelf_rest] I won't repeat it here.

Additionally, mojito provides routing methods for the following tasks.

### Static Asset Handling
Static assets such as html and css are a mainstay of most web applications.

In production these assets are served from the filesystem, but in development it is much more convenient to user `pub serve`. 

Mojito makes this very easy, by allowing you to set up a static asset handler that uses `pub serve` in development mode and the filesystem in production (see section on Development Mode for details on activation).

The following example sets that up a route for all requests starting with `/ui` that uses the default settings for `pub serve` (port 8080) and file system path (`build/web`).

```
app.router.addStaticAssetHandler('/ui');
```  

>**Pro Tip**
>
>Under the covers `addStaticAssetHandler` uses [shelf_static][shelf_static] and 
[shelf_proxy][shelf_proxy] to handle the static assets. 


### OAuth (1 and 2) Client

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

## Context

Mojito makes some things, such as the currently logged in user, available via a `context` property. To access simply import mojito. For example

```
import 'package:mojito/mojito.dart';

somefunction() {
  print(context.auth);
}
```

## Authentication

Mojito exposes helpers for setting up authentication via `app.auth`. If you want to apply it to all routes then use the `global` builder.

### Global Authentication
For example the following sets the application to use basic authentication, allowing access over http (a bad idea other than in development) and allows anonymous access. 

```
  app.auth.global
    .basic(_lookup)
    ..allowHttp=true
    ..allowAnonymousAccess=true;
```

*Note the `allowAnonymousAccess` is actually a form of authorisation (rather than authentication) and is simply a convenience. See the Authorisation section below for more options.*



### Currently Authenticated User

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

### Route Specific Authentication

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

## Authorisation
Mojito exposes helpers for setting up authorisation via `app.authorisation`. Similarly to authentication, if you want to apply it to all routes then use the `global` builder, otherwise use the `builder()`.

The following shows how to enforce that only authenticated users can access a particular route. This is useful, for example if you set up a global authenticator that allows anonymous access and you want to block anonymous access to some routes.
 
```
app.router.get('privates', () => 'this is only for the privileged few',
        middleware: app.authorisation.builder().authenticatedOnly().build())
```

> **Pro Tip**
> 
>* Mojito uses [shelf_auth][shelf_auth] for authorisation support. Consult the [shelf_auth docs][shelf_auth] for more details

## Other Middleware

Mojito exposes helpers for setting up other middleware via `app.middleware`. Similarly to authentication, if you want to apply it to all routes then use the `global` builder, otherwise use the `builder()`.


## Integrating with other Shelf Packages

It is also easy to use any [shelf][shelf] packages that are not bundled with [mojito][mojito].

[shelf][shelf] packages will expose a shelf `Handler`. 
All the main mojito router methods take a `handler` argument, so it is largely a matter
of plugging the handler from the shelf package you want to integrate, into the
router method you want to use.

If the package will support more than one http method or if it serves more than
a single set path then the `add` method should be used.

_Note: if you can also use the `@Add` annotation if you prefer_

### Example - integrating shelf_rpc


```

import 'package:mojito/mojito.dart';
import 'package:shelf_rpc/shelf_rpc.dart' as shelf_rpc;
import 'package:rpc/rpc.dart';

main() {

  var app = init();

  var apiServer = <create rpc apiServer somehow>;
  // create a shelf handler from the api
  var handler = shelf_rpc.createRpcHandler(apiServer);

  // create a route for the handler. 
  app.router
    ..add('rpc', null, handler, exactMatch: false);

  app.start();
}

```

Note `exactMatch: false` is needed as shelf_rpc serves many sub routes. Also
passing `null` as the value of the `methods` argument is used so that all
methods are passed to the api.

## Under the hood

Mojito bundles lots of existing shelf libraries and integrates them for easier use. These include:

 - [Shelf Route][shelf_route]
 - [Shelf Bind][shelf_bind]
 - [Shelf Rest][shelf_rest]
 - [Shelf Auth][shelf_auth]
 - [Shelf Auth Session][shelf_auth_session]
 - [Shelf OAuth][shelf_oauth]
 - [Shelf OAuth Memcache][shelf_oauth_memcache]
 - [Shelf Proxy][shelf_proxy]
 - [Shelf Static][shelf_static]
 - [Shelf Exception Handler][shelf_exception_handler]



[mojito]: https://pub.dartlang.org/packages/mojito
[shelf]: https://pub.dartlang.org/packages/shelf
[shelf_auth]: https://pub.dartlang.org/packages/shelf_auth
[shelf_auth_session]: https://pub.dartlang.org/packages/shelf_auth_session
[shelf_route]: https://pub.dartlang.org/packages/shelf_route
[shelf_static]: https://pub.dartlang.org/packages/shelf_static
[shelf_proxy]: https://pub.dartlang.org/packages/shelf_proxy
[shelf_bind]: https://pub.dartlang.org/packages/shelf_bind
[shelf_rest]: https://pub.dartlang.org/packages/shelf_rest
[shelf_oauth]: https://pub.dartlang.org/packages/shelf_oauth
[shelf_oauth_memcache]: https://pub.dartlang.org/packages/shelf_oauth_memcache
[shelf_exception_handler]: https://pub.dartlang.org/packages/shelf_exception_handler
[backlog.io]: http://backlog.io
[routing_blog]: http://blog.backlog.io/2015/06/completely-routed.html