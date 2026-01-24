
import 'package:dart_frog/dart_frog.dart';
import 'package:training_api/services/redis_service.dart';
Future<Response> onRequest(RequestContext context) async {
  final redis = context.read<RedisService>();

  try {
    // Test 1: Ping Redis
    final isConnected = await redis.ping();

    if (!isConnected) {
      return Response.json(
        statusCode: 503,
        body: {
          'status': 'unhealthy',
          'redis_connected': false,
          'message': 'Redis ping failed',
        },
      );
    }

    // Test 2: Set and Get String
    await redis.set('health_check', 'OK');
    final stringValue = await redis.get('health_check');

    // Test 3: Set and Get JSON
    await redis.setJson(
        'health_check_json',
        {
          'timestamp': DateTime.now().toIso8601String(),
          'service': 'dart_frog_api',
          'version': '1.0.0',
        },
        expirySeconds: 60,);

    final jsonValue = await redis.getJson('health_check_json');

    // Test 4: Counter operations
    await redis.set('health_counter', '0');
    final counter = await redis.incr('health_counter');

    // Test 5: List operations
    await redis.rpush('health_list', 'item1');
    await redis.rpush('health_list', 'item2');
    final listItems = await redis.lrange('health_list', 0, -1);

    // Test 6: Hash operations
    await redis.hset('health_hash', 'field1', 'value1');
    await redis.hset('health_hash', 'field2', 'value2');
    final hashValue = await redis.hget('health_hash', 'field1');

    // Test 7: TTL check
    await redis.setWithExpiry('temp_key', 'expires_soon', 10);
    final ttl = await redis.ttl('temp_key');

    // Clean up test data
    await redis.delete([
      'health_check',
      'health_check_json',
      'health_counter',
      'health_list',
      'health_hash',
      'temp_key',
    ]);

    return Response.json(body: {
      'status': 'healthy',
      'redis_connected': true,
      'tests': {
        'ping': isConnected,
        'string_operations': stringValue == 'OK',
        'json_operations': jsonValue != null,
        'counter_operations': counter > 0,
        'list_operations': listItems.length == 2,
        'hash_operations': hashValue == 'value1',
        'ttl_check': ttl > 0 && ttl <= 10,
      },
      'timestamp': DateTime.now().toIso8601String(),
    },);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'status': 'error',
        'redis_connected': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
