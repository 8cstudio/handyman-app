import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/screens/customer/customer_home_screen.dart';
import 'package:my_bloc_app/presentation/screens/customer/service_detail_screen.dart';
import 'package:my_bloc_app/presentation/screens/customer/book_service_screen.dart';
import 'package:my_bloc_app/presentation/screens/customer/customer_profile_screen.dart';
import 'package:my_bloc_app/presentation/screens/customer/chat_screen.dart';

List<RouteBase> get customerRouteModule => [
      GoRoute(
        name: AppRoute.customerHome.name,
        path: AppRoute.customerHome.path,
        builder: (context, state) => CustomerHomeScreen(
          initialTabIndex: AppRoute.tabIndexFromQuery(
            state.uri.queryParameters['tab'],
            isCustomer: true,
          ),
        ),
      ),
      GoRoute(
        name: AppRoute.customerServices.name,
        path: AppRoute.customerServices.path,
        builder: (context, state) => CustomerServicesScreen(
          categoryId: state.uri.queryParameters['categoryId'],
          search: state.uri.queryParameters['search'],
        ),
      ),
      GoRoute(
        name: AppRoute.customerServiceDetail.name,
        path: AppRoute.customerServiceDetail.path,
        builder: (context, state) => ServiceDetailScreen(
          serviceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        name: AppRoute.customerBook.name,
        path: AppRoute.customerBook.path,
        builder: (context, state) => BookServiceScreen(
          serviceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        name: AppRoute.customerBookings.name,
        path: AppRoute.customerBookings.path,
        builder: (context, state) => const CustomerBookingsScreen(),
      ),
      GoRoute(
        name: AppRoute.customerProfile.name,
        path: AppRoute.customerProfile.path,
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        name: AppRoute.customerChat.name,
        path: AppRoute.customerChat.path,
        builder: (context, state) => ChatScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
      GoRoute(
        name: AppRoute.customerReview.name,
        path: AppRoute.customerReview.path,
        builder: (context, state) => ReviewScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
    ];
