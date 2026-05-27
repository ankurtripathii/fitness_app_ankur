import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/workout_provider.dart';
import '../widgets/animated_stat_card.dart';
import '../widgets/workout_card.dart';
import 'log_workout_screen.dart';
import 'exercises_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  late AnimationController _headerCtrl;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().setUserId(widget.user.uid);
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      ExercisesScreen(userId: widget.user.uid),
      HistoryScreen(userId: widget.user.uid),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      body: screens[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF6EE7B7).withOpacity(0.3),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Exercises'),
          NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LogWorkoutScreen(userId: widget.user.uid)),
              ),
              backgroundColor: const Color(0xFF302B63),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Log Workout'),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    return Consumer<WorkoutProvider>(
      builder: (_, provider, __) {
        final stats = provider.stats;
        final name = widget.user.displayName ??
            widget.user.email?.split('@')[0] ??
            'Champ';

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _headerSlide,
                  child: _buildHeader(name, stats.weeklyGoalPercent),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      AnimatedStatCard(
                          label: 'Workouts',
                          value: '${stats.totalWorkouts}',
                          icon: Icons.fitness_center,
                          color: const Color(0xFF6366F1),
                          delay: 0),
                      AnimatedStatCard(
                          label: 'Calories',
                          value: '${stats.totalCalories}',
                          icon: Icons.local_fire_department,
                          color: const Color(0xFFEF4444),
                          delay: 100),
                      AnimatedStatCard(
                          label: 'Minutes',
                          value: '${stats.totalMinutes}',
                          icon: Icons.timer_outlined,
                          color: const Color(0xFF10B981),
                          delay: 200),
                      AnimatedStatCard(
                          label: 'Day Streak',
                          value: '${stats.currentStreak} 🔥',
                          icon: Icons.trending_up,
                          color: const Color(0xFFF59E0B),
                          delay: 300),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Workouts',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      TextButton(
                        onPressed: () => setState(() => _tab = 2),
                        child: const Text('View all',
                            style: TextStyle(color: Color(0xFF6366F1))),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()))
              else if (provider.recentWorkouts.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final w = provider.recentWorkouts[i];
                        return WorkoutCard(
                          workout: w,
                          onDelete: () => provider.deleteWorkout(w.id),
                        );
                      },
                      childCount: provider.recentWorkouts.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name, double weeklyProgress) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF302B63), Color(0xFF0F0C29)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hey, $name! 👋',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('Keep crushing\nyour goals!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2)),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: Colors.white54, size: 14),
                  const SizedBox(width: 4),
                  Text('${(weeklyProgress * 5).round()}/5 workouts this week',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: weeklyProgress,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF6EE7B7)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircularPercentIndicator(
            radius: 44,
            lineWidth: 6,
            percent: weeklyProgress,
            center: Text(
              '${(weeklyProgress * 100).round()}%',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            progressColor: const Color(0xFF6EE7B7),
            backgroundColor: Colors.white.withOpacity(0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.fitness_center_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No workouts yet',
              style: TextStyle(fontSize: 18, color: Colors.black45)),
          const SizedBox(height: 8),
          const Text('Tap "Log Workout" to get started!',
              style: TextStyle(fontSize: 14, color: Colors.black38)),
        ],
      ),
    );
  }
}
