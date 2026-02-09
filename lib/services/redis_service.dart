// ignore_for_file: avoid_print, strict_raw_type, unnecessary_lambdas

import 'package:redis/redis.dart';
import 'dart:convert';

/// Redis service
class RedisService {
  factory RedisService() => _instance;
  RedisService._internal();
  RedisConnection? _connection;
  Command? _command;
  bool _isConnected = false;

  static final RedisService _instance = RedisService._internal();

  /// Connect to Redis
  Future<void> connect({
    String host = 'localhost',
    int port = 6379,
    String? password,
  }) async {
    if (_isConnected) return;

    try {
      _connection = RedisConnection();
      _command = await _connection!.connect(host, port);

      if (password != null) {
        await _command!.send_object(['AUTH', password]);
      }

      _isConnected = true;
      print('Redis connected successfully');
    } catch (e) {
      print('Redis connection failed: $e');
      rethrow;
    }
  }

  /// Disconnect from Redis
  Future<void> disconnect() async {
    if (!_isConnected) return;

    _connection?.close();
    _isConnected = false;
    _command = null;
    _connection = null;
    print('Redis disconnected');
  }

  /// Check if connected
  bool get isConnected => _isConnected;

  // ==================== String Operations ====================

  /// Set a key-value pair
  Future<void> set(String key, String value) async {
    _ensureConnected();
    await _command!.send_object(['SET', key, value]);
  }

  /// Set a key-value pair with expiration (in seconds)
  Future<void> setWithExpiry(String key, String value, int seconds) async {
    _ensureConnected();
    await _command!.send_object(['SETEX', key, seconds.toString(), value]);
  }

  /// Get a value by key
  Future<String?> get(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['GET', key]);
    return result?.toString();
  }

  /// Delete one or more keys
  Future<void> delete(List<String> keys) async {
    _ensureConnected();
    if (keys.isEmpty) return;
    await _command!.send_object(['DEL', ...keys]);
  }

  /// Check if key exists
  Future<bool> exists(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['EXISTS', key]);
    return result == 1;
  }

  /// Set expiration on a key (in seconds)
  Future<void> expire(String key, int seconds) async {
    _ensureConnected();
    await _command!.send_object(['EXPIRE', key, seconds.toString()]);
  }

  /// Get time to live in seconds
  Future<int> ttl(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['TTL', key]);
    return (result is int) ? result : -1;
  }

  // ==================== JSON Operations ====================

  /// Set JSON data
  Future<void> setJson(
    String key,
    Map<String, dynamic> data, {
    int? expirySeconds,
  }) async {
    _ensureConnected();
    final jsonString = jsonEncode(data);

    if (expirySeconds != null) {
      await setWithExpiry(key, jsonString, expirySeconds);
    } else {
      await set(key, jsonString);
    }
  }

  /// Get JSON data
  Future<Map<String, dynamic>?> getJson(String key) async {
    _ensureConnected();
    final value = await get(key);

    if (value == null) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      print('Redis value at $key is not a Map');
      return null;
    } catch (e) {
      print('Error parsing JSON from Redis: $e');
      return null;
    }
  }

  /// Set JSON list
  Future<void> setJsonList(
    String key,
    List<Map<String, dynamic>> data, {
    int? expirySeconds,
  }) async {
    _ensureConnected();
    final jsonString = jsonEncode(data);

    if (expirySeconds != null) {
      await setWithExpiry(key, jsonString, expirySeconds);
    } else {
      await set(key, jsonString);
    }
  }

  /// Get JSON list
  Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    _ensureConnected();
    final value = await get(key);

    if (value == null) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      print('Redis value at $key is not a List');
      return null;
    } catch (e) {
      print('Error parsing JSON list from Redis: $e');
      return null;
    }
  }

  // ==================== Hash Operations ====================

  /// Set hash field
  Future<void> hset(String key, String field, String value) async {
    _ensureConnected();
    await _command!.send_object(['HSET', key, field, value]);
  }

  /// Get hash field
  Future<String?> hget(String key, String field) async {
    _ensureConnected();
    final result = await _command!.send_object(['HGET', key, field]);
    return result?.toString();
  }

  /// Get all hash fields and values
  Future<Map<String, String>> hgetAll(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['HGETALL', key]);

    if (result == null || result is! List) return {};

    final map = <String, String>{};
    for (var i = 0; i < result.length; i += 2) {
      if (i + 1 < result.length) {
        map[result[i].toString()] = result[i + 1].toString();
      }
    }
    return map;
  }

  /// Delete hash field
  Future<void> hdel(String key, List<String> fields) async {
    _ensureConnected();
    await _command!.send_object(['HDEL', key, ...fields]);
  }

  // ==================== List Operations ====================

  /// Push to list (left)
  Future<void> lpush(String key, String value) async {
    _ensureConnected();
    await _command!.send_object(['LPUSH', key, value]);
  }

  /// Push to list (right)
  Future<void> rpush(String key, String value) async {
    _ensureConnected();
    await _command!.send_object(['RPUSH', key, value]);
  }

  /// Pop from list (left)
  Future<String?> lpop(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['LPOP', key]);
    return result?.toString();
  }

  /// Pop from list (right)
  Future<String?> rpop(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['RPOP', key]);
    return result?.toString();
  }

  /// Get list range
  Future<List<String>> lrange(String key, int start, int stop) async {
    _ensureConnected();
    final result = await _command!
        .send_object(['LRANGE', key, start.toString(), stop.toString()]);

    if (result == null || result is! List) return [];
    return result.map((e) => e.toString()).toList();
  }

  /// Get list length
  Future<int> llen(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['LLEN', key]);
    return (result is int) ? result : 0;
  }

  // ==================== Set Operations ====================

  /// Add to set
  Future<void> sadd(String key, List<String> members) async {
    _ensureConnected();
    await _command!.send_object(['SADD', key, ...members]);
  }

  /// Get all set members
  Future<List<String>> smembers(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['SMEMBERS', key]);

    if (result == null || result is! List) return [];
    return result.map((e) => e.toString()).toList();
  }

  /// Check if member exists in set
  Future<bool> sismember(String key, String member) async {
    _ensureConnected();
    final result = await _command!.send_object(['SISMEMBER', key, member]);
    return result == 1;
  }

  /// Remove from set
  Future<void> srem(String key, List<String> members) async {
    _ensureConnected();
    await _command!.send_object(['SREM', key, ...members]);
  }

  // ==================== Counter Operations ====================

  /// Increment counter
  Future<int> incr(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['INCR', key]);
    return (result is int) ? result : 0;
  }

  /// Increment counter by amount
  Future<int> incrby(String key, int amount) async {
    _ensureConnected();
    final result =
        await _command!.send_object(['INCRBY', key, amount.toString()]);
    return (result is int) ? result : 0;
  }

  /// Decrement counter
  Future<int> decr(String key) async {
    _ensureConnected();
    final result = await _command!.send_object(['DECR', key]);
    return (result is int) ? result : 0;
  }

  /// Decrement counter by amount
  Future<int> decrby(String key, int amount) async {
    _ensureConnected();
    final result =
        await _command!.send_object(['DECRBY', key, amount.toString()]);
    return (result is int) ? result : 0;
  }

  // ==================== Pattern Operations ====================

  /// Get keys matching pattern
  Future<List<String>> keys(String pattern) async {
    _ensureConnected();
    final result = await _command!.send_object(['KEYS', pattern]);

    if (result == null || result is! List) return [];
    return result.map((e) => e.toString()).toList();
  }

  /// Delete keys matching pattern
  Future<void> deletePattern(String pattern) async {
    _ensureConnected();
    final matchingKeys = await keys(pattern);
    if (matchingKeys.isNotEmpty) {
      await delete(matchingKeys);
    }
  }

  // ==================== Cache Helpers ====================

  /// JSON cache get or compute
  Future<Map<String, dynamic>> cacheJsonOrCompute({
    required String key,
    required Future<Map<String, dynamic>> Function() compute,
    int expirySeconds = 300,
  }) async {
    final cached = await getJson(key);
    if (cached != null) return cached;

    final value = await compute();
    await setJson(key, value, expirySeconds: expirySeconds);
    return value;
  }

  /// JSON list cache get or compute
  Future<List<Map<String, dynamic>>> cacheJsonListOrCompute({
    required String key,
    required Future<List<Map<String, dynamic>>> Function() compute,
    int expirySeconds = 300,
  }) async {
    final cached = await getJsonList(key);
    if (cached != null) return cached;

    final value = await compute();
    await setJsonList(key, value, expirySeconds: expirySeconds);
    return value;
  }

  // ==================== Utility Methods ====================

  /// Ping Redis server
  Future<bool> ping() async {
    _ensureConnected();
    try {
      final result = await _command!.send_object(['PING']);
      return result == 'PONG';
    } catch (e) {
      return false;
    }
  }

  /// Get Redis info
  Future<String> info() async {
    _ensureConnected();
    final result = await _command!.send_object(['INFO']);
    return result?.toString() ?? '';
  }

  // ==================== Private Helpers ====================

  void _ensureConnected() {
    if (!_isConnected || _command == null) {
      throw Exception('Redis is not connected. Call connect() first.');
    }
  }

  /// Flush all data (use with caution!)
  Future<void> flushAll() async {
    _ensureConnected();
    await _command!.send_object(['FLUSHALL']);
  }

  /// Flush current database
  Future<void> flushDb() async {
    _ensureConnected();
    await _command!.send_object(['FLUSHDB']);
  }
}
