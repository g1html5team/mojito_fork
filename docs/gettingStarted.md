+++
title = "Getting Started"
date = "2016-01-31T09:35:03+11:00"
description = "Getting Started"
weight = 10
type = "post"
#class="post last"
+++

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