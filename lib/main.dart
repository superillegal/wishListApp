import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'services/logger_service.dart';
import 'services/service_locator.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  await setupServiceLocator();

  Services.image.preloadImagePool().catchError((e) {
    LoggerService.warning('Предзагрузка изображений не удалась (возможно, нет интернета): $e');
  });

  runApp(const WishlistApp());
}
