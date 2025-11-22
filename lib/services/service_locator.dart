import 'package:get_it/get_it.dart';

import '../features/auth/services/auth_service.dart';
import '../features/gifts/data/gifts_repository.dart';
import '../features/profile/services/profile_service.dart';
import 'image_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (!getIt.isRegistered<ImageService>()) {
    getIt.registerSingleton<ImageService>(ImageService());
  }

  await getIt<ImageService>().initialize();

  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerLazySingleton<AuthService>(AuthService.new);
  }

  if (!getIt.isRegistered<GiftsRepository>()) {
    getIt.registerLazySingleton<GiftsRepository>(
      () => GiftsRepository(imageService: getIt<ImageService>()),
    );
  }

  if (!getIt.isRegistered<ProfileService>()) {
    getIt.registerLazySingleton<ProfileService>(
      () => ProfileService(giftsRepository: getIt<GiftsRepository>()),
    );
  }
}

class Services {
  static ImageService get image => getIt<ImageService>();
  static AuthService get auth => getIt<AuthService>();
  static GiftsRepository get gifts => getIt<GiftsRepository>();
  static ProfileService get profile => getIt<ProfileService>();
}
