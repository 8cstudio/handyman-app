enum AppRoute {
  splash(path: '/', name: 'splash'),
  roleSelection(path: '/role-selection', name: 'roleSelection'),
  customerSignIn(path: '/customer/sign-in', name: 'customerSignIn'),
  customerSignUp(path: '/customer/sign-up', name: 'customerSignUp'),
  providerSignIn(path: '/provider/sign-in', name: 'providerSignIn'),
  forgotPassword(path: '/forgot-password', name: 'forgotPassword'),
  customerHome(path: '/customer/home', name: 'customerHome'),
  customerServices(path: '/customer/services', name: 'customerServices'),
  customerServiceDetail(path: '/customer/service/:id', name: 'customerServiceDetail'),
  customerBook(path: '/customer/book/:id', name: 'customerBook'),
  customerBookings(path: '/customer/bookings', name: 'customerBookings'),
  customerProfile(path: '/customer/profile', name: 'customerProfile'),
  customerChat(path: '/customer/chat/:bookingId', name: 'customerChat'),
  customerReview(path: '/customer/review/:bookingId', name: 'customerReview'),
  providerHome(path: '/provider/home', name: 'providerHome'),
  providerOnboarding(path: '/provider/onboarding', name: 'providerOnboarding'),
  providerPending(path: '/provider/pending', name: 'providerPending'),
  providerBookings(path: '/provider/bookings', name: 'providerBookings'),
  providerProfile(path: '/provider/profile', name: 'providerProfile'),
  providerChat(path: '/provider/chat/:bookingId', name: 'providerChat'),
  signIn(path: '/sign-in', name: 'signIn'),
  signUp(path: '/sign-up', name: 'signUp'),
  home(path: '/home', name: 'home'),
  profile(path: '/profile', name: 'profile');

  const AppRoute({required this.path, required this.name});

  final String path;
  final String name;

  static AppRoute? fromPath(String path) {
    for (final route in AppRoute.values) {
      if (route.path == path) return route;
      if (route.path.contains(':')) {
        final pattern = route.path.replaceAll(RegExp(r':\w+'), '[^/]+');
        if (RegExp('^$pattern\$').hasMatch(path)) return route;
      }
    }
    return null;
  }

  static const publicRoutes = {
    splash,
    roleSelection,
    customerSignIn,
    customerSignUp,
    providerSignIn,
    forgotPassword,
    signIn,
    signUp,
  };

  static const authRoutes = {
    customerSignIn,
    customerSignUp,
    providerSignIn,
    forgotPassword,
    signIn,
    signUp,
  };

  bool get isPublicRoute => publicRoutes.contains(this);
  bool get isAuthRoute => authRoutes.contains(this);

  static int tabIndexFromQuery(String? tab, {required bool isCustomer}) {
    if (isCustomer) {
      return switch (tab) {
        'orders' => 1,
        'chat' => 2,
        'profile' => 3,
        _ => 0,
      };
    }
    return switch (tab) {
      'orders' => 0,
      'chat' => 1,
      'profile' => 2,
      _ => 0,
    };
  }
}
