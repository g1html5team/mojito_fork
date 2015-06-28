import 'package:shelf/shelf.dart';

import 'package:shelf_static/shelf_static.dart';

import 'package:shelf_rest/shelf_rest.dart';
import 'dart:async';

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

void simpleHierarchicalRouter() {
  var backlogHandler = router()
    ..add('/ui', ['GET'], staticHandler, exactMatch: false)
    ..addAll(
        (Router r) => r
          ..get('{?creator}', (String creator) async {
            // ...
          })
          ..addAll(
              (Router r) => r
                ..get('', (String backlogId) async {
                  // ...
                })
                ..put('',
                    (String backlogId, @RequestBody() Backlog backlog) async {
                  // ...
                }),
              path: '{backlogId}'),
        path: '/api/v1/backlogs');
}

_createBacklogJson(backlogs) {}

_searchBacklogs(String creator) {}

_fetchBacklog(int backlogId) {}

class Backlog {}

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

void emulatorClass() {
  var backlogHandler = router()
    ..add('/ui', ['GET'], staticHandler, exactMatch: false)
    ..addAll(new BacklogResource(), path: '/api/v1/backlogs');
}

class BacklogResource2 {
  call(Router r) {
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

class BacklogResource3 {
  @Get('{?creator}')
  Future<List<Backlog>> searchBacklogs(String creator) async {
    // ...
  }

  @Get('{backlogId}')
  Future<Backlog> fetchBacklog(String backlogId) async {
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

class IssueResource {}

@RestResource('backlogId')
class BacklogResource4 {
  Future<List<Backlog>> search(String creator) async {
    // ...
  }

  Future<Backlog> fetch(String backlogId) async {
    // ...
  }

  Future<Backlog> update(
      String backlogId, @RequestBody() Backlog backlog) async {
    // ...
  }

  @AddAll(path: '{backlogId}/issues')
  IssueResource issues() => new IssueResource();
}
