

import 'package:dart_frog/dart_frog.dart';
import 'package:training_api/middleware/redis_middleware.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(middlewareForRedis);
}
