import 'package:flutter/material.dart';
import 'package:my_celengan/screens/add_savings_screen.dart';
import 'package:my_celengan/screens/savings_detail_screen.dart';
import 'package:my_celengan/models/saving_goals.dart';
import 'package:my_celengan/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:my_celengan/services/theme_service.dart';
import 'package:my_celengan/utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SavingsGoal> ongoingSavings = [];
  List<SavingsGoal> achievedSavings = [];
  bool _sortNewestFirst = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Menambahkan listener untuk perubahan data
    StorageService.addListener(_updateSavings);
    
    // Load data awal
    _loadSavingsData();
  }

  void _loadSavingsData() {
    setState(() => _isLoading = true);
    
    final separatedGoals = StorageService.getSeparatedSavingsGoals();
    
    setState(() {
      ongoingSavings = separatedGoals['ongoing'] ?? [];
      achievedSavings = separatedGoals['completed'] ?? [];
      _sortSavings();
      _isLoading = false;
    });
  }

  void _updateSavings(List<SavingsGoal> allGoals) {
    final separatedGoals = StorageService.getSeparatedSavingsGoals();
    
    setState(() {
      ongoingSavings = separatedGoals['ongoing'] ?? [];
      achievedSavings = separatedGoals['completed'] ?? [];
      _sortSavings();
    });
  }

  @override
  void dispose() {
    // Hapus listener saat widget di-dispose
    StorageService.removeListener(_updateSavings);
    _tabController.dispose();
    super.dispose();
  }

  void _addNewSavingsGoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSavingsScreen()),
    );

    if (result != null && result is SavingsGoal) {
      await StorageService.saveSavingsGoal(result);
      // _updateSavings() akan dipanggil otomatis
    }
  }

  void _sortSavings() {
    if (_sortNewestFirst) {
      ongoingSavings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      achievedSavings.sort((a, b) {
        if (b.completedAt == null) return -1;
        if (a.completedAt == null) return 1;
        return b.completedAt!.compareTo(a.completedAt!);
      });
    } else {
      ongoingSavings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      achievedSavings.sort((a, b) {
        if (a.completedAt == null) return -1;
        if (b.completedAt == null) return 1;
        return a.completedAt!.compareTo(b.completedAt!);
      });
    }
  }

  void _toggleSort() {
    setState(() {
      _sortNewestFirst = !_sortNewestFirst;
      _sortSavings();
    });
  }


  void _openSavingsDetail(SavingsGoal saving) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingsDetailScreen(
          savingsGoal: saving,
        ),
      ),
    );
    
    // Data akan di-update otomatis melalui listener
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeService>().isDarkMode;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'My Celengan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              context.read<ThemeService>().toggleTheme();
            },
            tooltip: isDarkMode ? 'Mode Terang' : 'Mode Gelap',
          ),
          IconButton(
            icon: Icon(_sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _toggleSort,
            tooltip: _sortNewestFirst ? 'Terbaru ke Terlama' : 'Terlama ke Terbaru',
          ),
        ],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Saat ini'),
            Tab(text: 'Tercapai'),
          ],
          indicatorColor: Theme.of(context).colorScheme.secondary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Ongoing Savings Tab
                _buildSavingsListView(ongoingSavings, true),
                // Achieved Savings Tab
                _buildSavingsListView(achievedSavings, false),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewSavingsGoal,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Celengan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSavingsListView(List<SavingsGoal> savings, bool isOngoing) {
    if (savings.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  isOngoing ? Icons.savings_outlined : Icons.celebration_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  isOngoing 
                      ? 'Belum ada tabungan aktif.' 
                      : 'Belum ada tabungan tercapai.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                if (isOngoing)
                  ElevatedButton(
                    onPressed: _addNewSavingsGoal,
                    child: const Text('Mulai Menabung'),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savings.length,
      itemBuilder: (context, index) {
        final saving = savings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _openSavingsDetail(saving),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.savings,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saving.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${saving.frequency} • ${saving.currencyCode} ${saving.depositAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Tambahkan badge kategori
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: saving.categoryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: saving.categoryColor.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    saving.category,
                                    style: TextStyle(
                                      color: saving.categoryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isOngoing)
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50)),
                          onPressed: () => _openSavingsDetail(saving),
                          tooltip: 'Tambah Saldo',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: saving.progressPercentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      saving.progressPercentage < 1 
                          ? Theme.of(context).colorScheme.primary 
                          : const Color(0xFF4CAF50)
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${saving.currencyCode} ${CurrencyFormatter.format(saving.currentAmount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        ' / ${CurrencyFormatter.format(saving.targetAmount)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOngoing
                        ? 'Estimasi tercapai: ${saving.estimatedCompletionDate.day}/${saving.estimatedCompletionDate.month}/${saving.estimatedCompletionDate.year}'
                        : 'Selesai pada: ${saving.completedAt?.day ?? "-"}/${saving.completedAt?.month ?? "-"}/${saving.completedAt?.year ?? "-"}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}