import 'package:mojito/mojito.dart';
import 'dart:async';
import 'package:uri/uri.dart';

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

main() {
  var app = init(isDevMode: () => true);

  app.router.get('/hi', () => 'hi');

  final oauth = app.router.oauth;

  oauth.gitHub().addClient(
      (_) => new ClientId('your clientId', 'your secret'),
      oauth.storage.inMemory(),
      new UriTemplate(
          'http://example.com/loginComplete{?type,token,secret,context}'));

  // TODO: kinda weird to put path in the .oauth2 bit instead of .addClient
  // TODO: probably should remove oauth from Mojito class. Fits better in router
  oauth
      .oauth2('notGithub', (_) => commonAuthorizationServers.gitHubOAuth2)
      .addClient(
          (_) => new ClientId('your clientId', 'your secret'),
          oauth.storage.inMemory(),
          new UriTemplate(
              'http://example.com/loginComplete{?type,token,secret,context}'));

  app.start();
}

void moji() {
  var app = init();

  app.router
    ..addStaticAssetHandler('/ui')
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

void yeah() {
  var app = init();

  app.router
    ..addStaticAssetHandler('/ui')
    ..addAll(new BacklogResource(), path: '/api/v1/backlogs');

  app.start();
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
