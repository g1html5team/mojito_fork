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

[Mojito][mojito] comes with a very feature rich router. To get a good overview of the options you have, have a read of the blog post [Routing Options in Shelf][routing_blog].

The mojito router extends [shelf_rest][shelf_rest]'s router. As this is documented extensively in the [shelf_rest documentation][shelf_rest] I won't repeat it here.

Additionally, mojito provides the following routing methods.

### Static Asset Handling
Static assets such as html and css are a mainstay of most web applications.

In production these assets are served from the filesystem, but in development it is much more convenient to user `pub serve`. 

Mojito makes this very easy, by allowing you to set up a static asset handler that uses `pub serve` in development mode and the filesystem in production (see section on Development Mode for details on activation).

The following example sets that up a route for all requests starting with `/ui` that uses the default settings for `pub serve` (port 8080) and file system path (`build/web`).

```
app.router.addStaticAssetHandler('/ui');
```  

*Note: under the covers `addStaticAssetHandler` uses [shelf_static] and [shelf_proxy] to handle the static assets.*





Set up some global authentication. These will be applied to all routes. 
```
  app.auth.global
    .basic(_lookup)
    ..allowHttp=true
    ..allowAnonymousAccess=true;
```


Set up a route and get the authenticated users name from the context. *Note: Mojito makes the logged in user available in the current zone.*

```
app.router..get('/hi', () {
  var auth = app.context.auth;
  var username = auth.map((authContext) =>
      authContext.principal.name)
      .getOrElse(() => 'guest');

  return 'hello $username';
});
```

Start serving the app

```
app.start();
```

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

More doco to come...


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