// Copyright (c) 2015, The Mojito project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by
// a BSD 2-Clause License that can be found in the LICENSE file.

import 'package:mojito/mojito.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';

const String nomeAKUrl = 'https://query.yahooapis.com/v1/public/yql?'
    'q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20'
    '(select%20woeid%20from%20geo.places(1)%20'
    'where%20text%3D%22nome%2C%20ak%22)'
    '&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';

const String greenlandUrl = 'https://query.yahooapis.com/v1/public/yql?'
    'q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20'
    '(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22'
    'greenland%22)&format=json&'
    'env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';

Logger _log = new Logger('example');

main() {
  final app = init(isDevMode: () => true);

  app.router
    ..get('weather', () async {
      final nomeFuture = http.get(nomeAKUrl);
      final greenlandFuture = http.get(greenlandUrl);

      final result = await Future.wait([nomeFuture, greenlandFuture]);
      final bodies =
          result.map((http.Response r) => JSON.decode(r.body)).toList();
      return {"nome": bodies[0], "greenland": bodies[1]};
    })
    ..get('streamed', () {
      final sc = new StreamController();
      final nomeFuture = http.get(nomeAKUrl).then((r) {
        _log.info('nome');

        return sc.add(r.body);
      });
      final greenlandFuture = http.get(greenlandUrl).then((r) async {
        _log.info('greenland');
        await new Future.delayed(const Duration(seconds: 10));
        _log.info('after greenland');
        return sc.add(r.body);
      });

      _log.info('wait');

      Future.wait([nomeFuture, greenlandFuture]).then((_) {
        _log.info('close');
        return sc.close();
      });

      _log.info('return');

      final os = sc.stream
//              .map((r) => r.body)
//              .transform(JSON.encoder)
          .transform(UTF8.encoder);

      return new Response.ok(os, context: {"shelf.io.buffer_output": false});
    })
    ..get('users', getUsersHandler);

  app.start();
}

Response getUsersHandler(Request request) {
  Stream<List<int>> counterStream = timedCounter(const Duration(seconds: 1), 15)
      .map((int x) => 'hello $x\n')
      .transform(UTF8.encoder);

  print(request.headers);
  return new Response.ok(counterStream,
      context: {"shelf.io.buffer_output": false});
}

Stream<int> timedCounter(Duration interval, [int maxCount]) {
  StreamController<int> controller = new StreamController<int>();
  int counter = 0;
  void tick(Timer timer) {
    counter++;
    controller.add(counter); // Ask stream to send counter values as event.
    if (maxCount != null && counter >= maxCount) {
      timer.cancel();
      controller.close(); // Ask stream to shut down and tell listeners.
    }
  }
  new Timer.periodic(interval, tick); // BAD: Starts before it has subscribers.
  return controller.stream;
}
