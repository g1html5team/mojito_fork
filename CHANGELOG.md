## 0.6.0

* added cors
* support for config


## 0.5.0

* includes [shelf_bind][shelf_bind] 0.9.0 which has many significant and some **BREAKING**
changes. Consult the change logs for [shelf_bind][shelf_bind]

## 0.4.0

* Significantly improved Readme, dartdocs and examples
* Revamped oauth client support
  * removed addOAuth2Provider and addOAuth1Provider from router
  * added oauth property to router providing access to new builders
  * out of the box support for creating oauth clients for:
    * github
    * bitbucket
    * google
* Removed perRequestLogProcessor as wasn't viable
* create a root Logger by default

## 0.3.0

* Now extends the new `shelf_rest` `router` and inherits its shiny new features

## 0.2.0

* upgraded version of shelf_oauth. Breaking if you relied on accessType in oauth2
being 'offline'

## 0.1.7

* upgraded version of shelf_auth

## 0.1.6

* upgraded version of shelf_auth

## 0.1.5

* upgraded version of shelf_oauth

## 0.1.4

* upgraded version of shelf_oauth

## 0.1.3

* upgraded version of shelf_auth for exclusion support in authorisers

## 0.1.2

* upgraded version of shelf_auth

## 0.1.1

* added authorisation middleware

## 0.1.0+1

* fixed bug where middleware was not passed to super ctr in router

## 0.1.0

* added oauth2 support

## 0.0.3

* support for same pub serve vs static trick that appengine uses

## 0.0.2

* oauth support

## 0.0.1

* First version 


[mojito]: https://pub.dartlang.org/packages/mojito
[shelf]: https://pub.dartlang.org/packages/shelf
[shelf_auth]: https://pub.dartlang.org/packages/shelf_auth
[shelf_auth_session]: https://pub.dartlang.org/packages/shelf_auth_session
[shelf_route]: https://pub.dartlang.org/packages/shelf_route
[shelf_static]: https://pub.dartlang.org/packages/shelf_static
[shelf_proxy]: https://pub.dartlang.org/packages/shelf_proxy
[shelf_bind]: https://pub.dartlang.org/packages/shelf_bind
[shelf_rest]: https://pub.dartlang.org/packages/shelf_rest
[shelf_oauth]: https://pub.dartlang.org/packages/shelf_oauth
[shelf_oauth_memcache]: https://pub.dartlang.org/packages/shelf_oauth_memcache
[shelf_exception_handler]: https://pub.dartlang.org/packages/shelf_exception_handler
[backlog.io]: http://backlog.io
[routing_blog]: http://blog.backlog.io/2015/06/completely-routed.html