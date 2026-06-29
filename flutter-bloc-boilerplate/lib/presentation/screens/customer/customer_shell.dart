import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';
import 'package:my_bloc_app/presentation/blocs/handyman/handyman_cubit.dart';
import 'package:my_bloc_app/presentation/common/orders_tab_page.dart';
import 'package:my_bloc_app/presentation/common/profile_tab_widgets.dart';
import 'package:my_bloc_app/presentation/common/role_shell_widgets.dart';
import 'package:my_bloc_app/presentation/common/service_list_tile.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_app_bar.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_bottom_bar.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_shell.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

class CustomerShell extends StatefulWidget {
  final int initialIndex;
  const CustomerShell({super.key, this.initialIndex = 0});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  late int _index;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  static const _titles = [
    AppText.homeTitle,
    AppText.orders,
    AppText.chat,
    AppText.profile,
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _scrollController.addListener(_onScroll);
    if (_index == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<HandymanCubit>().loadBookings();
      });
    } else if (_index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<HandymanCubit>().loadChatPreviews();
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<HandymanCubit>().loadMoreServices();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final cubit = context.read<HandymanCubit>();
      final trimmed = value.trim();
      cubit.applyServiceFilters(
        categoryId: cubit.state.selectedCategoryId,
        search: trimmed.isEmpty ? null : trimmed,
      );
    });
  }

  void _onTabSelected(int index) {
    setState(() => _index = index);
    if (index == 1) {
      context.read<HandymanCubit>().loadBookings();
    } else if (index == 2) {
      context.read<HandymanCubit>().loadChatPreviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassShell(
      appBar: GlassAppBar(
        title: Text(_titles[_index]),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: const [NotificationBellButton()],
      ),
      drawer: const RoleAppDrawer(role: AppRole.customer),
      body: IndexedStack(
        index: _index,
        children: [
          _buildBrowse(),
          const OrdersTabPage(
            role: AppRole.customer,
            chatRoutePrefix: '/customer/chat',
          ),
          const ActiveChatsPage(chatRoutePrefix: '/customer/chat'),
          const CustomerProfileTab(),
        ],
      ),
      bottomNavigationBar: BlocBuilder<HandymanCubit, HandymanState>(
        buildWhen: (previous, current) =>
            previous.hasUnreadChats != current.hasUnreadChats ||
            previous.chatPreviews != current.chatPreviews,
        builder: (context, state) {
          final hasUnread = state.hasUnreadChats;
          return GlassBottomBar(
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _onTabSelected,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: AppText.homeTitle,
                ),
                const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: AppText.orders,
                ),
                NavigationDestination(
                  icon: ChatNavIcon(showUnreadDot: hasUnread),
                  selectedIcon:
                      ChatNavIcon(showUnreadDot: hasUnread, selected: true),
                  label: AppText.chat,
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: AppText.profile,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrowse() {
    return BlocBuilder<HandymanCubit, HandymanState>(
      builder: (context, state) {
        return CustomScrollView(
          controller: _scrollController,
          cacheExtent: 600,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: GlassStyle.inputDecoration(
                    context,
                    hintText: AppText.searchServices,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _onSearchChanged(value);
                  },
                  onSubmitted: _onSearchChanged,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildCategoryChips(context, state)),
            if (state.isLoading && state.services.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && state.services.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.error!, style: TextStyle(color: context.appTheme.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<HandymanCubit>().loadHomeFeed(),
                        child: const Text(AppText.retry),
                      ),
                    ],
                  ),
                ),
              )
            else if (state.services.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No services found')),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  GlassStyle.shellTabBottomInset(context),
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                    childCount: state.services.length + (state.hasMoreServices ? 1 : 0),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChips(BuildContext context, HandymanState state) {
    if (state.categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: state.selectedCategoryId == null,
              onSelected: (_) {
                context.read<HandymanCubit>().applyServiceFilters(
                      categoryId: null,
                      search: state.serviceSearchQuery,
                    );
              },
            ),
          ),
          ...state.categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.name),
                selected: state.selectedCategoryId == category.id,
                onSelected: (_) {
                  context.read<HandymanCubit>().applyServiceFilters(
                        categoryId: category.id,
                        search: state.serviceSearchQuery,
                      );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
