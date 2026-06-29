import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/screens/provider/provider_home_screen.dart';
import 'package:my_bloc_app/presentation/screens/provider/provider_onboarding_screen.dart';
import 'package:my_bloc_app/presentation/screens/customer/chat_screen.dart';
import 'package:my_bloc_app/presentation/common/profile_tab_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/presentation/blocs/handyman/handyman_cubit.dart';

List<RouteBase> get providerRouteModule => [
      GoRoute(
        name: AppRoute.providerHome.name,
        path: AppRoute.providerHome.path,
        builder: (context, state) => ProviderHomeScreen(
          initialTabIndex: AppRoute.tabIndexFromQuery(
            state.uri.queryParameters['tab'],
            isCustomer: false,
          ),
        ),
      ),
      GoRoute(
        name: AppRoute.providerOnboarding.name,
        path: AppRoute.providerOnboarding.path,
        builder: (context, state) => const ProviderOnboardingScreen(),
      ),
      GoRoute(
        name: AppRoute.providerPending.name,
        path: AppRoute.providerPending.path,
        builder: (context, state) => const ProviderPendingScreen(),
      ),
      GoRoute(
        name: AppRoute.providerBookings.name,
        path: AppRoute.providerBookings.path,
        redirect: (_, __) => AppRoute.providerHome.path,
      ),
      GoRoute(
        name: AppRoute.providerProfile.name,
        path: AppRoute.providerProfile.path,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<HandymanCubit>(),
          child: Scaffold(
            appBar: AppBar(title: const Text(AppText.profile)),
            body: const ProviderProfileTab(),
          ),
        ),
      ),
      GoRoute(
        name: AppRoute.providerChat.name,
        path: AppRoute.providerChat.path,
        builder: (context, state) => ChatScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
    ];
