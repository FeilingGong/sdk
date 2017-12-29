// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';
import 'package:async_helper/async_helper.dart';
import 'compiler_helper.dart';

const String TEST_ONE = r"""
foo(a) {
  int x = 0;
  for (int i = 0; i < 10; i++) {
    x += i;
  }
  return x;
}
""";

const String TEST_TWO = r"""
foo(a) {
  int x = 0;
  int i = 0;
  while (i < 10) {
    x += i;
    i++;
  }
  return x;
}
""";

const String TEST_THREE = r"""
foo(a) {
  int x = 0;
  for (int i = 0; i < 10; i++) {
    if (i == 5) continue;
    x += i;
  }
  return x;
}
""";

const String TEST_FOUR = r"""
foo(a) {
  int x = 0;
  int i = 0;
  while (i < 10) {
    i++;
    if (i == 5) continue;
    x += i;
  }
  return x;
}
""";

main() {
  runTests({bool useKernel}) async {
    await compile(TEST_ONE, entry: 'foo', useKernel: useKernel,
        check: (String generated) {
      Expect.isTrue(generated.contains(r'for ('));
    });
    await compile(TEST_TWO, entry: 'foo', useKernel: useKernel,
        check: (String generated) {
      Expect.isTrue(!generated.contains(r'break'));
    });
    await compile(TEST_THREE, entry: 'foo', useKernel: useKernel,
        check: (String generated) {
      Expect.isTrue(generated.contains(r'continue'));
    });
    await compile(TEST_FOUR, entry: 'foo', useKernel: useKernel,
        check: (String generated) {
      Expect.isTrue(generated.contains(r'continue'));
    });
  }

  asyncTest(() async {
    print('--test from ast---------------------------------------------------');
    await runTests(useKernel: false);
    print('--test from kernel------------------------------------------------');
    await runTests(useKernel: true);
  });
}
