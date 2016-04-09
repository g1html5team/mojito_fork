+++
title = "Integrating with other Shelf Packages"
date = "2016-01-31T09:35:03+11:00"
description = "Integrating with other Shelf Packages"
weight = 80
type = "post"
+++


It is also easy to use any [shelf][shelf] packages that are not bundled with [mojito][mojito].

[shelf][shelf] packages will expose a shelf `Handler`. 
All the main mojito router methods take a `handler` argument, so it is largely a matter
of plugging the handler from the shelf package you want to integrate, into the
router method you want to use.

If the package will support more than one http method or if it serves more than
a single set path then the `add` method should be used.

_Note: if you can also use the `@Add` annotation if you prefer_

