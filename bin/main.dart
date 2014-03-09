import 'dart:async';
import 'package:clean_sync/server.dart';
import 'package:clean_ajax/server.dart';
import 'package:clean_backend/clean_backend.dart';
import 'package:clean_router/common.dart';

import 'package:chatboard/validators.dart';

void main(List<String> args) {
  runZoned(() {
    MongoDatabase mongodb = new MongoDatabase('mongodb://127.0.0.1/test');
    Future.wait(mongodb.init).then((_) {
      publish('board1', (_) => new Future.value(mongodb.collection('board1')),
          beforeRequest: userChangeCheck);
      publish('board2', (_) => new Future.value(mongodb.collection('board2')),
          beforeRequest: userChangeCheck);
      Backend.bind('127.0.0.1', 8080, []).then((Backend backend) {
            //backend.addDefaultHttpHeader('Access-Control-Allow-Origin','*');

            /// AJAX Requests
            MultiRequestHandler multiRequestHandler = new MultiRequestHandler();
            multiRequestHandler.registerDefaultHandler(handleSyncRequest);
            backend.router.addRoute('resources', new Route('/resources/'));
            backend.addView('resources', multiRequestHandler.handleHttpRequest);

            backend.router.addRoute('static', new Route("/*"));
            backend.addStaticView('static', '../web/');
            print('Finished chatboard');
      });
    });
  });
}

userChangeCheck(documentAfter, args) {
  return new Future.sync((){
    print('Document to db:$documentAfter');
    if (!isTextValid(documentAfter['text'])) throw(new Exception('longer then 30'));
    if (!isNameValid(documentAfter['name'])) throw(new Exception('name invalid'));
  });
}
