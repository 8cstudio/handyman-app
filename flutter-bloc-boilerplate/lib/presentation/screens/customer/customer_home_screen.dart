import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/presentation/blocs/handyman/handyman_cubit.dart';
import 'package:my_bloc_app/presentation/common/service_list_tile.dart';
import 'package:my_bloc_app/presentation/screens/customer/customer_shell.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_app_bar.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_shell.dart';

class CustomerHomeScreen extends StatelessWidget {
  final int initialTabIndex;
  const CustomerHomeScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HandymanCubit>()
        ..loadHomeFeed()
        ..loadChatPreviews()
        ..startRealtimeSync(),
      child: CustomerShell(initialIndex: initialTabIndex),
    );
  }
}

class CustomerServicesScreen extends StatefulWidget {
  final String? categoryId;
  final String? search;
  const CustomerServicesScreen({super.key, this.categoryId, this.search});

  @override
  State<CustomerServicesScreen> createState() => _CustomerServicesScreenState();
}

class _CustomerServicesScreenState extends State<CustomerServicesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<HandymanCubit>().loadMoreServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HandymanCubit>()
        ..loadServices(categoryId: widget.categoryId, search: widget.search),
      child: GlassShell(
        extendBody: false,
        appBar: GlassAppBar(title: const Text(AppText.browseServices)),
        body: BlocBuilder<HandymanCubit, HandymanState>(
          builder: (context, state) {
            if (state.isLoading && state.services.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null && state.services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error!, style: TextStyle(color: context.appTheme.error)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<HandymanCubit>().loadServices(
                            categoryId: widget.categoryId,
                            search: widget.search,
                          ),
                      child: const Text(AppText.retry),
                    ),
                  ],
                ),
              );
            }
            if (state.services.isEmpty) {
              return const Center(child: Text('No services found'));
            }

            final itemCount = state.services.length + (state.hasMoreServices ? 1 : 0);
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              cacheExtent: 600,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index >= state.services.length) {
                  return state.isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }
                return ServiceListTile(service: state.services[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
