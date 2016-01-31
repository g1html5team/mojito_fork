+++
title = "Development Mode"
date = "2016-01-31T09:35:03+11:00"
description = "Development Mode"
weight = 20
type = "post"
+++

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
