import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/presentation/blocs/handyman/handyman_cubit.dart';
import 'package:my_bloc_app/presentation/common/orders_tab_page.dart';
import 'package:my_bloc_app/presentation/common/profile_tab_widgets.dart';
import 'package:my_bloc_app/presentation/common/role_shell_widgets.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_app_bar.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_bottom_bar.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_shell.dart';

class ProviderShell extends StatefulWidget {
  const ProviderShell({super.key});

  @override
  State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell> {
  int _index = 0;

  static const _titles = [
    AppText.orders,
    AppText.chat,
    AppText.profile,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HandymanCubit>()
          ..loadBookings()
          ..loadChatPreviews();
      }
    });
  }

  void _onTabSelected(int index) {
    setState(() => _index = index);
    if (index == 0) {
      context.read<HandymanCubit>().loadBookings();
    } else if (index == 1) {
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
      drawer: const RoleAppDrawer(role: AppRole.provider),
      body: IndexedStack(
        index: _index,
        children: const [
          OrdersTabPage(
            role: AppRole.provider,
            chatRoutePrefix: '/provider/chat',
          ),
          ActiveChatsPage(chatRoutePrefix: '/provider/chat'),
          ProviderProfileTab(),
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
}
