import 'package:flutter/material.dart';
import 'package:my_celengan/models/saving_goals.dart';
import 'package:my_celengan/screens/add_savings_screen.dart';
import 'package:my_celengan/services/storage_service.dart';
import 'package:intl/intl.dart';
import 'package:my_celengan/utils/formatters.dart';

class SavingsDetailScreen extends StatefulWidget {
  final SavingsGoal savingsGoal;

  const SavingsDetailScreen({
    super.key,
    required this.savingsGoal,
  });

  @override
  State<SavingsDetailScreen> createState() => _SavingsDetailScreenState();
}

class _SavingsDetailScreenState extends State<SavingsDetailScreen> {
  late SavingsGoal _savingsGoal;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isDeposit = true;

  @override
  void initState() {
    super.initState();
    _savingsGoal = widget.savingsGoal;
  }

  void _showTransactionDialog() {
    _amountController.clear();
    _noteController.clear();
    _isDeposit = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Menggunakan warna dari tema
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isDeposit ? 'Tambah Saldo' : 'Tarik Saldo',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Transaction type toggle
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Tambah'),
                        icon: Icon(Icons.add_circle),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Tarik'),
                        icon: Icon(Icons.remove_circle),
                      ),
                    ],
                    selected: {_isDeposit},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _isDeposit = selection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(WidgetState.selected)) {
                            return _isDeposit 
                                ? const Color(0xFF4CAF50) 
                                : const Color(0xFFFF5252);
                          }
                          return Colors.transparent;
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Amount field
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      prefixText: '${_savingsGoal.currencyCode} ',
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[800] 
                          : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : null,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Note field
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          final amount = double.parse(_amountController.text);
                          if (amount <= 0) throw Exception('Invalid amount');
                          
                          final note = _noteController.text.isEmpty 
                              ? (_isDeposit ? 'Tambah saldo' : 'Tarik saldo') 
                              : _noteController.text;
                          
                          if (_isDeposit) {
                            _savingsGoal.addDeposit(amount, note);
                          } else {
                            if (amount > _savingsGoal.currentAmount) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saldo tidak cukup!')),
                              );
                              return;
                            }
                            _savingsGoal.withdraw(amount, note);
                          }
                          
                          // Simpan perubahan ke storage
                          StorageService.updateSavingsGoal(_savingsGoal);
                          
                          Navigator.pop(context);
                          
                          // Update state lokal
                          this.setState(() {});
                          
                          // Cek apakah tabungan sudah tercapai
                          if (_savingsGoal.isCompleted && _savingsGoal.completedAt == null) {
                            _savingsGoal.completedAt = DateTime.now();
                            StorageService.updateSavingsGoal(_savingsGoal);
                            
                            // Tampilkan pesan sukses
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selamat! Tabungan ${_savingsGoal.name} telah tercapai'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nominal tidak valid')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDeposit 
                            ? const Color(0xFF4CAF50) 
                            : const Color(0xFFFF5252),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_isDeposit ? 'Tambah Saldo' : 'Tarik Saldo'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _editSavingsGoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSavingsScreen(
          existingSavingsGoal: _savingsGoal,
        ),
      ),
    );

    if (result != null && result is SavingsGoal) {
      // Update model lokal
      setState(() {
        _savingsGoal = result;
      });
      
      // Simpan ke storage
      StorageService.updateSavingsGoal(_savingsGoal);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tabungan'),
        content: const Text('Anda yakin ingin menghapus tabungan ini? Semua data akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Hapus dari storage
              StorageService.deleteSavingsGoal(_savingsGoal.id);
              
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to home screen
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _savingsGoal.targetAmount - _savingsGoal.currentAmount;
    final isCompleted = _savingsGoal.isCompleted;
    
    Widget buildMilestoneProgressBar() {
      return Container(
        height: 16,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          children: [
            // Base progress bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            
            // Actual progress
            FractionallySizedBox(
              widthFactor: _savingsGoal.progressPercentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? const Color(0xFF4CAF50) 
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            // Milestone markers
            ..._savingsGoal.milestones.asMap().entries.map((entry) {
              final index = entry.key;
              final milestone = entry.value;
              final isAchieved = _savingsGoal.achievedMilestones[index];
              
              return Positioned(
                left: milestone * MediaQuery.of(context).size.width - 32, // Adjust position
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAchieved 
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[400],
                    border: Border.all(
                      color: Theme.of(context).cardColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${(milestone * 100).toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    Widget buildMilestoneAchievements() {
      final achievedMilestones = _savingsGoal.milestones
          .asMap()
          .entries
          .where((entry) => _savingsGoal.achievedMilestones[entry.key])
          .map((entry) => entry.value)
          .toList();
          
      if (achievedMilestones.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Milestone Tercapai',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...achievedMilestones.map((milestone) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF4CAF50),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mencapai ${(milestone * 100).toInt()}% dari target',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_savingsGoal.name),
        actions: [
          if (!isCompleted)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editSavingsGoal,
              tooltip: 'Edit Tabungan',
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Hapus Tabungan',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Instead of Colors.white
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress Indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        value: _savingsGoal.progressPercentage,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted 
                              ? const Color(0xFF4CAF50) 
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${(_savingsGoal.progressPercentage * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isCompleted ? 'Tercapai!' : 'Progres',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                buildMilestoneProgressBar(),
                
                const SizedBox(height: 8),
                
                // Current Amount Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Terkumpul',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${_savingsGoal.currencyCode} ${CurrencyFormatter.format(_savingsGoal.currentAmount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Target Amount Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Target',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${_savingsGoal.currencyCode} ${CurrencyFormatter.format(_savingsGoal.targetAmount)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Remaining Amount Row
                if (!isCompleted)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kekurangan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${_savingsGoal.currencyCode} ${remaining.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 16),
                
                // Frequency info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800]  // warna gelap untuk tema gelap
                        : Colors.grey[100], // warna terang untuk tema terang
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_savingsGoal.frequency} • ${_savingsGoal.currencyCode} ${_savingsGoal.depositAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isCompleted) ...[
                        const Spacer(),
                        Icon(
                          Icons.event_available,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_savingsGoal.estimatedCompletionDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                if (_savingsGoal.achievedMilestones.contains(true))
                  buildMilestoneAchievements(),
              ],
            ),
          ),
          
          // Transactions Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isCompleted)
                  ElevatedButton.icon(
                    onPressed: _showTransactionDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Transaksi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: _savingsGoal.transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada transaksi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (!isCompleted) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _showTransactionDialog,
                            child: const Text('Tambah Saldo'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savingsGoal.transactions.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = _savingsGoal.transactions.length - 1 - index;
                      final transaction = _savingsGoal.transactions[reversedIndex];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.isDeposit
                                ? const Color(0xFF4CAF50).withOpacity(0.2)
                                : const Color(0xFFFF5252).withOpacity(0.2),
                            child: Icon(
                              transaction.isDeposit ? Icons.add : Icons.remove,
                              color: transaction.isDeposit
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFF5252),
                            ),
                          ),
                          title: Text(
                            transaction.note,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(transaction.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Text(
                            '${transaction.isDeposit ? '+' : '-'} ${_savingsGoal.currencyCode} ${transaction.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaction.isDeposit
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFF5252),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isCompleted ? null : FloatingActionButton(
        onPressed: _showTransactionDialog,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}