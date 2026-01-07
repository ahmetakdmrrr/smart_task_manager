import 'package:go_router/go_router.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/task_detail_screen.dart';

/// Uygulama Router yapılandırması
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/task/new',
      name: 'newTask',
      builder: (context, state) => const TaskDetailScreen(taskId: null),
    ),
    GoRoute(
      path: '/task/:id',
      name: 'taskDetail',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return TaskDetailScreen(taskId: taskId);
      },
    ),
  ],
);
