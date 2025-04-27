import 'package:flutter/material.dart';
import 'package:my_celengan/models/saving_goals.dart';
import 'package:intl/intl.dart';

class AddSavingsScreen extends StatefulWidget {
  final SavingsGoal? existingSavingsGoal;
  
  const AddSavingsScreen({
    Key? key, 
    this.existingSavingsGoal,
  }) : super(key: key);

  @override
  State<AddSavingsScreen> createState() => _AddSavingsScreenState();
}

class _AddSavingsScreenState extends State<AddSavingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  String _frequency = 'Harian'; // Default value
  String _selectedCurrency = 'Rp';
  DateTime? _estimatedDate;
  
  final List<String> _frequencies = ['Harian', 'Mingguan', 'Bulanan'];
  final List<String> _currencies = ['Rp', 'USD', 'EUR', 'JPY', 'SGD', 'AUD', 'CNY', 'GBP'];

  @override
  void initState() {
    super.initState();
    
    // If editing an existing goal, populate the fields
    if (widget.existingSavingsGoal != null) {
      _nameController.text = widget.existingSavingsGoal!.name;
      _targetController.text = widget.existingSavingsGoal!.targetAmount.toString();
      _amountController.text = widget.existingSavingsGoal!.depositAmount.toString();
      _frequency = widget.existingSavingsGoal!.frequency;
      _selectedCurrency = widget.existingSavingsGoal!.currencyCode;
      
      _calculateEstimatedDate();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _calculateEstimatedDate() {
    if (_targetController.text.isNotEmpty && _amountController.text.isNotEmpty) {
      try {
        final targetAmount = double.parse(_targetController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
        final depositAmount = double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
        
        if (targetAmount > 0 && depositAmount > 0) {
          final depositsNeeded = targetAmount / depositAmount;
          
          int daysToAdd;
          if (_frequency == 'Harian') {
            daysToAdd = depositsNeeded.ceil();
          } else if (_frequency == 'Mingguan') {
            daysToAdd = (depositsNeeded * 7).ceil();
          } else {
            daysToAdd = (depositsNeeded * 30).ceil();
          }
          
          setState(() {
            _estimatedDate = DateTime.now().add(Duration(days: daysToAdd));
          });
          return;
        }
      } catch (_) {}
    }
    
    setState(() {
      _estimatedDate = null;
    });
  }

  void _saveSavingsGoal() {
    final name = _nameController.text;
    final targetAmountText = _targetController.text;
    final depositAmountText = _amountController.text;
    
    if (name.isEmpty || targetAmountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan target tabungan harus diisi')),
      );
      return;
    }
    
    double targetAmount;
    double depositAmount = 0;
    
    try {
      targetAmount = double.parse(targetAmountText.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (depositAmountText.isNotEmpty) {
        depositAmount = double.parse(depositAmountText.replaceAll(RegExp(r'[^0-9.]'), ''));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format nominal tidak valid')),
      );
      return;
    }
    
    final savingsGoal = SavingsGoal(
      id: widget.existingSavingsGoal?.id, // Gunakan ID yang ada jika edit
      name: name,
      targetAmount: targetAmount,
      currentAmount: widget.existingSavingsGoal?.currentAmount ?? 0,
      frequency: _frequency,
      depositAmount: depositAmount,
      currencyCode: _selectedCurrency,
      createdAt: widget.existingSavingsGoal?.createdAt,
      completedAt: widget.existingSavingsGoal?.completedAt,
      transactions: widget.existingSavingsGoal?.transactions,
    );
    
    Navigator.pop(context, savingsGoal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingSavingsGoal == null ? 'Tambah Tabungan' : 'Edit Tabungan',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveSavingsGoal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Savings name field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Tabungan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.list, color: Theme.of(context).colorScheme.primary),
                      hintText: 'Nama Tabungan',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: TextField(
                          controller: _targetController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateEstimatedDate(),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_balance_wallet, 
                                color: Theme.of(context).colorScheme.primary),
                            hintText: 'Target Tabungan',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: _currencies.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCurrency = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Deposit plan section
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rencana Pengisian',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  // Frequency selection tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: _frequencies.map((frequency) {
                        final isSelected = _frequency == frequency;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _frequency = frequency;
                                _calculateEstimatedDate();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  frequency,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Deposit amount field with estimation button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateEstimatedDate(),
                          decoration: InputDecoration(
                            hintText: 'Nominal Pengisian',
                            prefixIcon: Icon(Icons.attach_money, 
                                color: Theme.of(context).colorScheme.primary),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      ElevatedButton(
                        onPressed: _calculateEstimatedDate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text('Estimasi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  
                  if (_estimatedDate != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_available,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Estimasi tercapai: ${DateFormat('dd MMMM yyyy').format(_estimatedDate!)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}