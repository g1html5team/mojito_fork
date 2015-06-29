import 'package:shelf/shelf.dart';

import 'package:shelf_static/shelf_static.dart';

import 'package:shelf_route/shelf_route.dart';
import 'dart:convert';

var staticHandler = createStaticHandler('web/build');

/*
GET 	->	/ui
GET 	->	/api/v1/backlogs{?creator}
POST	->	/api/v1/backlogs
GET 	->	/api/v1/backlogs/{backlogId}
PUT 	->	/api/v1/backlogs/{backlogId}
GET 	->	/api/v1/backlogs/{backlogId}/issues
PUT 	->	/api/v1/backlogs/{backlogId}/issues/{issueHash}
POST	->	/api/v1/backlogs/{backlogId}/issues/bulk
GET 	->	/api/v1/users/oauth/bitbucket/requestToken
GET 	->	/api/v1/users/oauth/bitbucket/authToken
GET 	->	/api/v1/users/oauth/github/requestToken
GET 	->	/api/v1/users/oauth/github/authToken

 */

void manual() {
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
}

void simpleFlatRouter() {
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
}

void simpleHierarchicalRouter() {
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
}

_createBacklogJson(backlogs) {}

_searchBacklogs(String creator) {}

_fetchBacklog(int backlogId) {}

class Backlog {
  Backlog.fromJson(decode) {}
}
