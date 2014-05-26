// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test.domain.server;

import 'package:analysis_server/src/analysis_server.dart';
import 'package:analysis_server/src/domain_server.dart';
import 'package:analysis_server/src/protocol.dart';
import 'package:unittest/unittest.dart';

import 'mocks.dart';

main() {
  AnalysisServer server;
  ServerDomainHandler handler;

  setUp(() {
    var serverChannel = new MockServerChannel();
    server = new AnalysisServer(serverChannel);
    handler = new ServerDomainHandler(server);
  });

  group('ServerDomainHandler', () {
    test('getVersion', () {
      var request = new Request('0', ServerDomainHandler.GET_VERSION_METHOD);
      var response = handler.handleRequest(request);
      expect(response.toJson(), equals({
        Response.ID: '0',
        Response.RESULT: {
          ServerDomainHandler.VERSION_RESULT: '0.0.1'
        }
      }));
    });

    group('setSubscriptions', () {
      Request request;
      setUp(() {
        request = new Request('0', ServerDomainHandler.SET_SUBSCRIPTIONS_METHOD);
      });

      test('invalid service name', () {
        request.setParameter(
            ServerDomainHandler.SUBSCRIPTIONS_PARAMETER,
            ['noSuchService']);
        var response = handler.handleRequest(request);
        // TODO(scheglov) extract isResponseError(id) matcher
        expect(response.id, equals('0'));
        expect(response.error, isNotNull);
      });

      test('success', () {
        expect(server.serverServices, isEmpty);
        // send request
        request.setParameter(
            ServerDomainHandler.SUBSCRIPTIONS_PARAMETER,
            [ServerService.STATUS.name]);
        var response = handler.handleRequest(request);
        // TODO(scheglov) extract isResponseSuccess(id) matcher
        expect(response.id, equals('0'));
        expect(response.error, isNull);
        // set of services has been changed
        expect(server.serverServices, contains(ServerService.STATUS));
      });
    });

    test('shutdown', () {
      expect(server.running, isTrue);
      // send request
      var request = new Request('0', ServerDomainHandler.SHUTDOWN_METHOD);
      var response = handler.handleRequest(request);
      // TODO(scheglov) extract isResponseSuccess(id) matcher
      expect(response.toJson(), equals({
        Response.ID: '0'
      }));
      // server is down
      expect(server.running, isFalse);
    });
  });
}
