+++
title = "Routing"
date = "2016-01-31T09:35:03+11:00"
description = "Routing"
weight = 30
type = "post"
+++

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

