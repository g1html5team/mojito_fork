+++
title = "Context"
date = "2016-01-31T09:35:03+11:00"
description = "Context"
weight = 40
type = "post"
+++

Mojito makes some things, such as the currently logged in user, available via a `context` property. To access simply import mojito. For example

```
import 'package:mojito/mojito.dart';

somefunction() {
  print(context.auth);
}
```
