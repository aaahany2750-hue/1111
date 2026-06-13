import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/discovery/presentation/discover_screen.dart';
import '../../features/game_transfer/presentation/games_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/transfer/presentation/transfers_screen.dart';
import '../localization/app_localizations.dart';

final appRouter = GoRouter(
  initialLocation: DiscoverScreen.routePath,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
        return HomeShell(shell: shell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: DiscoverScreen.routePath,
            builder: (BuildContext context, GoRouterState state) => const DiscoverScreen(),
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: TransfersScreen.routePath,
            builder: (BuildContext context, GoRouterState state) => const TransfersScreen(),
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: GamesScreen.routePath,
            builder: (BuildContext context, GoRouterState state) => const GamesScreen(),
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: HistoryScreen.routePath,
            builder: (BuildContext context, GoRouterState state) => const HistoryScreen(),
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: SettingsScreen.routePath,
            builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
          ),
        ]),
      ],
    ),
  ],
);

class HomeShell extends StatelessWidget {
  const HomeShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(child: shell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (int index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.wifi_tethering),
            label: l.discover,
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz),
            label: l.transfers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.sports_esports),
            label: l.games,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: l.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l.settings,
          ),
        ],
      ),
    );
  }
}
