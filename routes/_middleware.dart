// ignore_for_file: avoid_print, inference_failure_on_untyped_parameter

import 'package:dart_frog/dart_frog.dart';
import 'package:training_api/services/redis_service.dart';

final _redisService = RedisService();
bool _initStarted = false;

Handler middleware(Handler handler) {
  // Start initialization only once
  if (!_initStarted) {
    _initStarted = true;
    _initializeRedis();
  }

  return handler.use(
    provider<RedisService>((context) => _redisService),
  );
}

void _initializeRedis() {
  print('=== Initializing Redis ===');

  _redisService
      .connect(
    host: 'localhost',
    port: 6379,
  )
      .then((_) {
    print('Redis connection established');
    return _redisService.ping();
  }).then((pingResult) {
    if (pingResult) {
      print('✓ Redis connected and healthy');
    } else {
      print('✗ Redis ping failed');
    }
  }).catchError((error, stackTrace) {
    print('✗ Failed to connect to Redis: $error');
    print('Stack trace: $stackTrace');
  });
}
