import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/food_provider.dart';
import 'scanner_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('NutriScan'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailySummary(context),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Logs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          _buildHistoryList(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ScannerScreen()));
        },
        label: const Text('Scan Food'),
        icon: const Icon(Icons.camera_alt),
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildDailySummary(BuildContext context) {
    final provider = context.watch<FoodProvider>();
    final totalCalories = provider.history.fold(
      0,
      (sum, item) => sum + item.calories,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today', style: Theme.of(context).textTheme.labelLarge),
              Text(
                '$totalCalories kcal',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.local_fire_department,
            size: 48,
            color: Colors.orange,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildHistoryList(BuildContext context) {
    final provider = context.watch<FoodProvider>();

    if (provider.history.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No food logged today yet')),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = provider.history[index];
        return ListTile(
          leading: item.imageUrl != null
              ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
              : const CircleAvatar(child: Icon(Icons.restaurant)),
          title: Text(item.name),
          subtitle: Text(
            '${item.protein}g P • ${item.fat}g F • ${item.carbs}g C',
          ),
          trailing: Text(
            '${item.calories} kcal',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }, childCount: provider.history.length),
    );
  }
}
