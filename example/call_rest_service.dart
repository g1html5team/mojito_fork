// Copyright (c) 2015, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

import 'package:mojito/mojito.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

main() {
  final app = init(isDevMode: () => true);

  app.router
    ..get('weather', () async {
      final nomeAKUrl = 'https://query.yahooapis.com/v1/public/yql?'
          'q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20'
          '(select%20woeid%20from%20geo.places(1)%20'
          'where%20text%3D%22nome%2C%20ak%22)'
          '&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';

      final greenlandUrl = 'https://query.yahooapis.com/v1/public/yql?'
          'q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20'
          '(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22'
          'greenland%22)&format=json&'
          'env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';

      final nomeFuture = http.get(nomeAKUrl);
      final greenlandFuture = http.get(greenlandUrl);

      final result = await Future.wait([nomeFuture, greenlandFuture]);
      final bodies =
          result.map((http.Response r) => JSON.decode(r.body)).toList();
      print(bodies);
      return {"nome": bodies[0], "greenland": bodies[1]};
    });

  app.start();
}
