import 'dart:async';

import 'package:test/test.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

class CountersFixture {
  CachedCounters _counters;

  CountersFixture(CachedCounters counters) {
    _counters = counters;
  }

  void testSimpleCounters() async {
    _counters.last('Test.LastValue', 123);
    _counters.last('Test.LastValue', 123456);

    var counter = _counters.get('Test.LastValue', CounterType.LastValue);
    expect(counter, isNotNull);
    expect(counter.last, isNotNull);
    expect(counter.last, 123456); //, 3

    _counters.incrementOne('Test.Increment');
    _counters.increment('Test.Increment', 3);

    counter = _counters.get('Test.Increment', CounterType.Increment);
    expect(counter, isNotNull);
    expect(counter.count, 4);

    _counters.timestampNow('Test.Timestamp');
    _counters.timestampNow('Test.Timestamp');

    counter = _counters.get('Test.Timestamp', CounterType.Timestamp);
    expect(counter, isNotNull);
    expect(counter.time, isNotNull);

    _counters.stats('Test.Statistics', 1);
    _counters.stats('Test.Statistics', 2);
    _counters.stats('Test.Statistics', 3);

    counter = _counters.get('Test.Statistics', CounterType.Statistics);
    expect(counter, isNotNull);
    expect(counter.average, 2); //, 3

    _counters.dump();

    await Future.delayed(Duration(milliseconds: 1000));
  }

  void testMeasureElapsedTime() async {
    var timer = _counters.beginTiming('Test.Elapsed');

    await Future.delayed(Duration(milliseconds: 100), () {
      timer.endTiming();

      var counter = _counters.get('Test.Elapsed', CounterType.Interval);
      expect(counter.last > 50, isTrue);
      expect(counter.last < 5000, isTrue);

      _counters.dump();
    });

    await Future.delayed(Duration(milliseconds: 1000));
  }
}
