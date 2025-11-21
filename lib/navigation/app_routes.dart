class AppRoutePaths {
  static const login = '/';
  static const home = '/home';
  static const profile = '/profile';

  static const giftForm = '/home/gifts/new';
  static const allGifts = '/home/all';
  static const purchasedGifts = '/home/purchased';
  static const plannedGifts = '/home/planned';
  static const giftDetailsPattern = '/home/gifts/:id';
  static const giftEditPattern = '/home/gifts/:id/edit';

  static String giftDetails(String id) => '/home/gifts/$id';
  static String giftEdit(String id) => '/home/gifts/$id/edit';
}

class AppRouteNames {
  static const login = 'login';
  static const home = 'home';
  static const profile = 'profile';
  static const giftForm = 'home-gift-form';
  static const allGifts = 'home-all';
  static const purchasedGifts = 'home-purchased';
  static const plannedGifts = 'home-planned';
  static const giftDetails = 'home-gift-details';
  static const giftEdit = 'home-gift-edit';
}
