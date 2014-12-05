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

Import and initialise
```
 import 'package:mojito/mojito.dart';
 
 final app = mojito.init();
```  

Set up some global authentication. These will be applied to all routes. 
```
  app.auth.global
    .basic(_lookup)
    ..allowHttp=true
    ..allowAnonymousAccess=true;
```

Set up a route for the ui that will proxy to pub serve in dev and serve from the filesystem in prod.

```
app.router..addStaticAssetHandler('/ui');
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

 - [Shelf Route](https://pub.dartlang.org/packages/shelf_route)
 - [Shelf Bind](https://pub.dartlang.org/packages/shelf_bind)
 - [Shelf Rest](https://pub.dartlang.org/packages/shelf_rest)
 - [Shelf Auth](https://pub.dartlang.org/packages/shelf_auth)
 - [Shelf Auth Session](https://pub.dartlang.org/packages/shelf_auth_session)
 - [Shelf OAuth](https://pub.dartlang.org/packages/shelf_oauth)
 - [Shelf OAuth Memcache](https://pub.dartlang.org/packages/shelf_oauth_memcache)
 - [Shelf Proxy](https://pub.dartlang.org/packages/shelf_proxy)
 - [Shelf Static](https://pub.dartlang.org/packages/shelf_static)
 - [Shelf Exception Response](https://pub.dartlang.org/packages/shelf_exception_response)

More doco to come...