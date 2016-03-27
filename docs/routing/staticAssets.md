+++
title = "Static Assets"
date = "2016-01-31T09:35:03+11:00"
description = "Static Asset Handling"
weight = 31
type = "post"
+++

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

