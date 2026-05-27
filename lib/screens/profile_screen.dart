import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../providers/workout_provider.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final stats = provider.stats;
    final name = user.displayName ?? user.email?.split('@')[0] ?? 'Champion';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildAvatar(name),
            const SizedBox(height: 24),
            _buildStatsRow(stats.totalWorkouts, stats.totalCalories,
                stats.currentStreak),
            const SizedBox(height: 24),
            _buildInfoCard(user),
            const SizedBox(height: 16),
            _buildAchievements(stats.totalWorkouts, stats.currentStreak),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  context.read<WorkoutProvider>().clearUser();
                  await AuthService().signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Sign Out',
                    style: TextStyle(color: Colors.red, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6EE7B7), Color(0xFF3B82F6)]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF6EE7B7).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: Text(name[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        Text(name,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 4),
        const Text('Fitness Enthusiast 💪',
            style: TextStyle(color: Colors.black45, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatsRow(int workouts, int calories, int streak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF302B63), Color(0xFF0F0C29)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('$workouts', 'Workouts', Icons.fitness_center),
          _divider(),
          _statItem('$calories', 'Calories', Icons.local_fire_department),
          _divider(),
          _statItem('$streak 🔥', 'Streak', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, IconData icon) {
    return Column(
      children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: Colors.white12);

  Widget _buildInfoCard(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.email_outlined, 'Email', user.email ?? '-'),
          const Divider(height: 20),
          _infoRow(Icons.verified_user_outlined, 'Account',
              user.emailVerified ? 'Verified ✓' : 'Not verified'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF302B63).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF302B63), size: 18),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black45)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ],
    );
  }

  Widget _buildAchievements(int workouts, int streak) {
    final badges = [
      if (workouts >= 1) ('First Workout! 🎉', 'Logged your first workout'),
      if (workouts >= 5) ('Regular 💪', 'Logged 5+ workouts'),
      if (workouts >= 10) ('Dedicated 🏆', 'Logged 10+ workouts'),
      if (streak >= 3) ('On Fire 🔥', '3+ day streak'),
      if (streak >= 7) ('Week Warrior ⚔️', '7+ day streak'),
    ];

    if (badges.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Achievements',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: badges.map((b) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF6EE7B7).withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Text(b.$1,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(b.$2,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black45)),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }
}
