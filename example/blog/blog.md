Completely Routed
================

This blog is a journey through some of the main routing options in [shelf][shelf]. It is intended as a useful resource to help developers choose how to implement their routes for a particular task. 

>## Routeception ##
>
> [backlog.io][backlog.io] uses [mojito][mojito] (and therefore [shelf_rest][shelf_rest], [shelf_route][shelf_route] and [shelf_bind][shelf_bind]) for routing. As such it provides a real world application that helps me drive how I evolve those packages.
>
>However, [backlog.io][backlog.io]  actually owes it's existence to these packages. That's because, as I was creating and evolving an increasing number of Dart packages, each of which lives in its own git repo with its own issue tracker, I ran into an issue (if you'll excuse the pun). There was no easy way for me to prioritise what I needed to work on at any point in time. 
>
>What I needed of course, was a way to create a backlog across these repos issues. To make things more interesting, some of the repos are in BitBucket and some in GitHub.
>
>And so I created [backlog.io][backlog.io]  to solve this exact use case. But, this post is about routing, so I'll leave it for another post to talk about [backlog.io][backlog.io]  itself.

## Simplicity, Usability, Flexibility, Extensibility and anything else that ends in ility

When I first created [shelf_route][shelf_route], I wanted to create a routing API that was:

 - easy to use
 - familiar
 - discoverable
 - a native shelf component
 - magic free
 - and extensible

By discoverable I mean that you can easily discover the features of the routing api, by leveraging Dart's awesome tooling for autocomplete and also that if you find the root of the route hierarchy you can easily navigate through the entire set of routes. 

Coming from the Java Spring world with lots of classpath scanning of routing components, I was disappointed at how difficult it could sometimes be to figure out what the routing hierarchy actually was.

As a native Shelf component, I wanted it to deal directly with shelf's classes like Request, Response, Handler and Middleware. This makes it very easy for people familiar with shelf, to pick up and be productive with immediately.

Also, the absence of magic (mirrors etc) means that it is pretty easy to debug and reason about.

The downside of course is that this comes at the cost of a fair bit of boilerplate. So whilst [shelf_route][shelf_route] was kept magic free, it was always designed to allow other packages to reduce boiler plate by adding some more magic.

## Just add Magic ##

Of course, reducing boilerplate is a good thing. That is essentially the goal of [shelf_rest][shelf_rest]. It introduces some annotations plus conventions and then uses mirrors to significantly reduce boilerplate.

But enough talk. Lets see how all this looks in code.

# Routing Options

In this section I'll walk through some of the different options you have for creating routes in shelf. To ground it in reality, I will base the discussion on a subset of the actual routes from [backlog.io][backlog.io] .

On start up [mojito][mojito] prints out the routes. This is what that looks like, for the subset of [backlog.io][backlog.io] routes I will talk about.

```
GET 	->	/ui
GET 	->	/api/v1/backlogs{?creator}
POST	->	/api/v1/backlogs
GET 	->	/api/v1/backlogs/{backlogId}
PUT 	->	/api/v1/backlogs/{backlogId}
GET 	->	/api/v1/backlogs/{backlogId}/issues
PUT 	->	/api/v1/backlogs/{backlogId}/issues/{issueHash}
POST	->	/api/v1/backlogs/{backlogId}/issues/bulk
GET 	->	/api/v1/users/oauth/github/requestToken
GET 	->	/api/v1/users/oauth/github/authToken
```

First up you will notice that the routes for the UI and API are separate. This makes it easy to apply different middleware to them. For example, the UI resources are all public (accessed anonymously) and highly cacheable, where as the API tends to be mostly private and often non cacheable (at least not in a shared cache).

> ### Shelf 101
> For anyone not familiar with [shelf][shelf], let me give a quick intro. To handle a request in [shelf][shelf] you need to create what is called (ironically) a `Handler`. A simple `Handler` looks like 
> ```
> var helloWorldHandler = (Request request) => new Response.ok('hello world');
> ```
> In other words, a `Handler` is a function that takes a `Request` and returns a `Response` (or a `Future<Response>`).

Before I launch into code, I want to make the point that, there is no right way to create your routes. Essentially you will trade off boilerplate for magic, so choose the approach you feel most comfortable with. 

Also don't feel like you need to use one approach for everything. Some tasks may lend themselves better to some approaches and other tasks to other approaches.

Often I start with one approach and evolve into others over time as the routes grow and the need to structure the code into separate units / files grows.

I will start from the least magic / most boilerplate options and finish up at the most magic / least boilerplate options.

## Option 1: The Manual Way

So the most straightforward, zero magic way is just to hand code the routing logic.

```
  var backlogHandler = (Request request) async {
    if (request.url.path.startsWith('/ui') && request.method == 'GET') {
      return staticHandler(request);
    } else if (request.url.path == '/api/v1/backlogs' &&
        request.method == 'GET') {
      var creator = request.requestedUri.queryParameters['creator'];
      var backlogs = await _searchBacklogs(creator);
      var resultJson = _createBacklogJson(backlogs);
      return new Response.ok(resultJson);
    } else if (request.url.path.startsWith('/api/v1/backlogs/') &&
        !request.url.path.contains('/issues') &&
        request.method == 'GET') {
      var backlogIdStr = request.url.path.substring('/api/v1/backlogs/'.length);
      var backlogId = int.parse(backlogIdStr);
      var backlog = await _fetchBacklog(backlogId);
      var resultJson = _createBacklogJson(backlog);
      return new Response.ok(resultJson);
    }

    /* .... */

    else {
      return new Response.notFound('oops');
    }
  };

```

For the UI routes we use [shelf_static][shelf_static]. 
*Note: [backlog.io][backlog.io] actually uses pub serve (via [shelf_proxy][shelf_proxy]) in dev mode and  [shelf_static][shelf_static] in production mode. This is an out of the box feature of [mojito][mojito] and will be covered later*

For the backlog search we look the backlogs up in the database, turn them into JSON and return the result.


## Option 2: Simple Flat Routing
We can improve on this a little by introducing [shelf_route][shelf_route] and implementing the routes in the most straightforward way. This reduces the need for manual checking of paths and methods, plus it will handle the path parameters like `backlogId` for us.

```
  var backlogHandler = router()
    ..add('/ui', ['GET'], staticHandler, exactMatch: false)
    ..get('/api/v1/backlogs{?creator}', (Request request) async {
      var creator = getPathParameter(request, 'creator');
      var backlogs = await _searchBacklogs(creator);
      var resultJson = _createBacklogJson(backlogs);
      return new Response.ok(resultJson);
    })
    ..get('/api/v1/backlogs/{backlogId}', (Request request) async {
      var backlogIdStr = getPathParameter(request, 'backlogId');
      var backlogId = int.parse(backlogIdStr);
      var backlog = await _fetchBacklog(backlogId);
      var resultJson = _createBacklogJson(backlog);
      return new Response.ok(resultJson);
    });
```

## Option 3: Hierarchical Routes

Since many of the routes start the same we can set the routes up hierarchically and make it a little more DRY. 
> Note, whilst the examples has so far not included any middleware, in the real app there is middleware and in general many routes have the same middleware applied. Setting them up hierarchically allows the middleware to be applied to all the child routes, making this much DRYer too.

```
  var backlogHandler = router()
    ..add('/ui', ['GET'], staticHandler, exactMatch: false)
    ..addAll(
        (Router r) => r
          ..get('{?creator}', (Request request) async {
            // ...
          })
          ..addAll(
              (Router r) => r
                ..get('', (Request request) async {
                  // ...
                })
                ..put(
                    '',
                    (Request request) async {
                  var backlogJson = await request.readAsString();
                  var backlog = new Backlog.fromJson(JSON.decode(backlogJson));
                  // ...
                }),
              path: '{backlogId}'),
        path: '/api/v1/backlogs');
```

*Here, I've omitted most of the handling for brevity. It is the same as the previous example.*

Now we use the `addAll` method which creates a child router. We use this twice.

This first child router has a path of `'/api/v1/backlogs'` which is applied to all its routes. This includes the second childRouter, which has a path of `{backlogId}`.

If you look at the last `put` method you can see that it is contained inside the second `addAll` which is inside the first `addAll`. It inherits the `'/api/v1/backlogs'` path of the first and `'{backlogId}'` from the second, so this makes up the expected

```
PUT 	->	/api/v1/backlogs/{backlogId}
```

## Option 4: Take a REST

So far the routing has all been provided by [shelf_route][shelf_route], which deliberately avoids using mirrors. This keeps magic to a minimum and makes it suitable for use in a browser, but there is only so much you can do to remove boilerplate.

Now it's time to spice things up with a little magic. This magic will be available to us simply by importing [shelf_rest][shelf_rest] rather than [shelf_route][shelf_route]. In other words

```
import 'package:shelf_rest/shelf_rest.dart';
```
instead of 
```
import 'package:shelf_route/shelf_route.dart';
```

Actually, the previous two options could also have been implemented by importing [shelf_rest][shelf_rest] rather than [shelf_route][shelf_route] as [shelf_rest][shelf_rest] is a drop in replacement for [shelf_route][shelf_route] that supports all its functionality and then adds in some boilerplate reducing magic.

First up, lets get rid of the extracting of path variables and parsing them into other types like ints. And while we are at it let's get rid of parsing the body into JSON and manually creating the Backlog object.

```
  var backlogHandler = router()
    ..add('/ui', ['GET'], staticHandler, exactMatch: false)
    ..addAll(
        (Router r) => r
          ..get('{?creator}', (String creator) async {
            // ...
          })
          ..addAll(
              (Router r) => r
                ..get('', (int backlogId) async {
                  // ...
                })
                ..put('',
                    (int backlogId, @RequestBody() Backlog backlog) async {
                  // ...
                }),
              path: '{backlogId}'),
        path: '/api/v1/backlogs');
```

At first it looks very similar, but if you look closely at the handler methods you will see that they no longer take `Request`. Instead the first one takes a `String creator`, the second an `int backlogId`.
The `put` also takes the `Backlog` object directly as we used the `@RequestBody` annotation to tell [shelf_rest][shelf_rest] to parse the body from JSON into a `Backlog` object.

## Option 5: Route Classes

As the number of routes grows, it can become quite unwieldy to keep them all in one big routing definition. There are many options here. You can simply split out sub routes into separate functions or you can take advantage of [Darts emulator functions](https://www.dartlang.org/articles/emulating-functions/) and put them in separate classes.

```
class BacklogResource {
  call(Router r) => r
    ..get('{?creator}', (String creator) async {
      // ...
    })
    ..addAll((Router r) => r
      ..get('', (String backlogId) async {
        // ...
      })
      ..put('', (String backlogId, @RequestBody() Backlog backlog) async {
        // ...
      }), path: '{backlogId}');
}

void main() {
  var backlogHandler = router()
    ..add('/ui', ['GET'], staticHandler, exactMatch: false)
    ..addAll(new BacklogResource(), path: '/api/v1/backlogs');
}

```

Here we put the bulk of the routes in the `BacklogResource` class with a `call` method that is the emulator function for our `Handler`.

## Option 5: Route Classes with Separate Methods

Rather than including the handler functions directly in the route definition, lets split them into separate methods. While we are at it, we will take advantage of another [shelf_rest][shelf_rest] feature that allows us to give the `call` method a more meaningful name, such as `createRoutes`.

```
class BacklogResource {
  createRoutes(Router r) {
    r
      ..get('{?creator}', searchBacklogs)
      ..addAll((Router r) => r
        ..get('', fetchBacklog)
        ..put('', updateBacklog), path: '{backlogId}');
  }

  Future<List<Backlog>> searchBacklogs(String creator) async {
    // ...
  }

  Future<Backlog> fetchBacklog(String backlogId) async {
    // ...
  }

  Future<Backlog> updateBacklog(
      String backlogId, @RequestBody() Backlog backlog) async {
    // ...
  }
}
```

This gives you another benefit. Since the methods have been defined to return objects like `Backlog`, [shelf_rest][shelf_rest] is going to do us another favour. It will automatically turn them into JSON and populate the `Response` object for us. Yes you can thank me later ;-)

## Option 6: Route Annotations

Instead of using the fluent API of the `Router` class we can put annotations on the handlers instead. These correspond directly to `Router` methods of the same name and have the same features.

```
class BacklogResource {
  @Get('{?creator}')
  Future<List<Backlog>> searchBacklogs(String creator) async {
    // ...
  }

  @Get('{backlogId}')
  Future<Backlog> findBacklog(String backlogId) async {
    // ...
  }

  @Put('{backlogId}')
  Future<Backlog> updateBacklog(
      String backlogId, @RequestBody() Backlog backlog) async {
    // ...
  }
  
  @AddAll(path: '{backlogId}/issues')
  IssueResource issues() => new IssueResource();
}

```

*Note: I snuck in the next child resource `issues` so you can see the use of the `@AddAll` annotation*

>Take a break. I don't know about you but that is already a lot to absorb so I'm gonna take 5 mins for a coffee. 
>
> So much option...

## Option 7: CRUD Time

A fair amount of your routes will end up following a standard pattern. These are the normal CRUD operations. These 4 backlog methods are typical

```
GET 	->	/api/v1/backlogs{?creator}
POST	->	/api/v1/backlogs
GET 	->	/api/v1/backlogs/{backlogId}
PUT 	->	/api/v1/backlogs/{backlogId}
```

You search for existing representations with a `GET` taking query parameters to search on (`creator` here); you `POST` to create a new instance; you fetch a single instance by doing a `GET` with the id of the instance as part of the path etc.

In the interest of DRYness and consistency, [shelf_rest][shelf_rest] has in built support for these CRUD methods.

```
@RestResource('backlogId')
class BacklogResource {
  Future<List<Backlog>> search(String creator) async {
    // ...
  }

  Future<Backlog> find(String backlogId) async {
    // ...
  }

  Future<Backlog> update(
      String backlogId, @RequestBody() Backlog backlog) async {
    // ...
  }

  @AddAll(path: 'issues')
  IssueResource issues() => new IssueResource();
}
```

To use this feature, you first add a `@RestResource` annotation to class which contains that pesky path variable (`backlogId`) that kept popping up in all the routes.
 
Next you either follow the standard naming convention for the methods (`search`, `create`, `find`, `update`, `delete`) or you use `@ResourceMethod` annotations to tell [shelf_rest][shelf_rest] which of the CRUD operations your method implements.

## Fancy Some HATEOAS

I won't go into this in detail here, as the blog is already crazy long, and I've likely lost most of you by now, but if you are a fan of [HATEOAS]() (I am and use it on [backlog.io][backlog.io]), then [shelf_rest][shelf_rest] comes with support to help you create your links.

```
  Future<BacklogResourceModel> update(String backlogId,
      @RequestBody() Backlog backlog, ResourceLinksFactory linksFactory) async { ... }
```

*Note: this is the real method signature for the update method*

Simply adding an argument of type `ResourceLinksFactory` will give you some methods to generate links for your resource.

## Time for a Drink - Grab a Mojito

Up until now we have covered just core routing, which isn't surprising as that is the purpose of the blog. However, firstly you don't end up with a running server with only routing and secondly you tend to want a whole bunch of other stuff like auth, static resource handling, logging and so on.

Shelf packages exist for many of these things and shelf makes it easy to glue all that together with your router. However, it doesn't hurt to get a little more out of the box. So you may as well chill and grab a [mojito][mojito]

[mojito][mojito] bundles [shelf_rest][shelf_rest], so all of the options covered above, you get out of the box with [mojito][mojito] too. But wait, there's more....

Sorry no steak knives on offer, but bear with me.

To start with, instead of importing [shelf_rest][shelf_rest], we import [mojito][mojito].

```
import 'package:mojito/mojito.dart';
```

Now we use a special method on [mojito][mojito]'s router called `addStaticAssetHandler` to handle the ui resources and then we start an actual web server with `app.start`

```
  var app = init();

  app.router
    ..addStaticAssetHandler('/ui')
    ..addAll(new BacklogResource(), path: '/api/v1/backlogs');
  
  app.start();
```

As alluded to earlier, `addStaticAssetHandler` will use `pub serve` in dev mode and serve from the filesystem in production mode.

## OAuth 1 & 2 handlers

One thing we didn't cover in the previous options, was how we handle the OAuth routes

```
GET 	->	/api/v1/users/oauth/github/requestToken
GET 	->	/api/v1/users/oauth/github/authToken
```

In [backlog.io][backlog.io] we handle these with [shelf_oauth][shelf_oauth] and [mojito][mojito] gives you this out of the box.

```
router..addOAuth2Provider(
                'github',
                _githubClientIdFactory,
                ....)
```

`addOAuth2Provider` takes quite a few arguments which I won't go into here. For this post it suffices to know that the above sets up the routes needed to do the OAuth 2 dance to authenticate with GitHub.

That's about enough for now. Let me know where you want more details and I'll consider follow up blogs.

## Mix and Match
One last note, pretty much all of the above options can be used at the same time. Mix it up as you wish. 

[mojito]: https://pub.dartlang.org/packages/mojito
[shelf]: https://pub.dartlang.org/packages/shelf
[shelf_route]: https://pub.dartlang.org/packages/shelf_route
[shelf_static]: https://pub.dartlang.org/packages/shelf_static
[shelf_proxy]: https://pub.dartlang.org/packages/shelf_proxy
[shelf_bind]: https://pub.dartlang.org/packages/shelf_bind
[shelf_rest]: https://pub.dartlang.org/packages/shelf_rest
[shelf_oauth]: https://pub.dartlang.org/packages/shelf_oauth
[backlog.io]: http://backlog.io
