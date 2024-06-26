import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../domain/interfaces/either.dart';
import '../../domain/services/i_sentry_crashlytics_service.dart';
import '../drivers/i_sentry_crashlytics_driver.dart';

class SentryCrashlyticsService extends ISentryCrashlyticsService {
  SentryCrashlyticsService({
    required this.dnsKey,
    required this.sentryCrashlyticsDriver,
  });

  final String dnsKey;
  final ISentryCrashlyticsDriver sentryCrashlyticsDriver;

  @override
  Future<Either<Exception, Unit>> init({Map<String, dynamic>? params}) async {
    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = dnsKey;
          options.appHangTimeoutInterval = const Duration(seconds: 3);
          switch (params?['environment']) {
            case 'dev':
              options.tracesSampleRate = 1;
              options.environment =
                  '${params?['environment']}${kDebugMode ? '_debug' : ''}';
              break;
            case 'prod':
              options.tracesSampleRate = kDebugMode ? 1 : 0.2;
              options.environment =
                  '${params?['environment']}${kDebugMode ? '_debug' : ''}';
              break;
          }
        },
      );
      return Right(unit);
    } catch (exception, stackTrace) {
      return setError(exception: exception, stackTrace: stackTrace);
    }
  }

  @override
  Future<Either<Exception, Unit>> setError({
    required exception,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    return sentryCrashlyticsDriver.setError(
      exception: exception,
      stackTrace: stackTrace,
      fatal: fatal,
    );
  }

  @override
  Future<Either<Exception, Unit>> identify({
    required Map<String, dynamic> user,
  }) {
    return sentryCrashlyticsDriver.identify(user: user);
  }

  @override
  Future<Either<Exception, Unit>> unidentify() {
    return sentryCrashlyticsDriver.unidentify();
  }
}
