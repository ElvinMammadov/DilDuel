import 'package:flutter_dic/core/di/dependency_injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt sl = GetIt.instance;

@injectableInit
Future<void> configureDependencies({String env = Environment.dev}) async {
  sl.init(environment: env);
}
