import 'package:get_it/get_it.dart';

import 'image_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (!getIt.isRegistered<ImageService>()) {
    getIt.registerSingleton<ImageService>(ImageService());
  }

  await getIt<ImageService>().initialize();
}

class Services {
  static ImageService get image => getIt<ImageService>();
}
