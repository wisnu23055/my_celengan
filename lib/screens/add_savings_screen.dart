import 'package:flutter/material.dart';
import 'package:my_celengan/models/saving_goals.dart';
import 'package:intl/intl.dart';

class AddSavingsScreen extends StatefulWidget {
  final SavingsGoal? existingSavingsGoal;
  
  const AddSavingsScreen({
    super.key, 
    this.existingSavingsGoal,
  });

  @override
  State<AddSavingsScreen> createState() => _AddSavingsScreenState();
}

class _AddSavingsScreenState extends State<AddSavingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  String _frequency = 'Harian';
  String _selectedCurrency = 'Rp';
  DateTime? _estimatedDate;
  
  // Tambahkan variabel untuk kategori
  String _selectedCategory = 'Umum';
  
  final List<String> _frequencies = ['Harian', 'Mingguan', 'Bulanan'];
  final List<String> _currencies = ['Rp', 'USD', 'EUR', 'JPY', 'SGD', 'AUD', 'CNY', 'GBP'];
  
  // Tambahkan daftar kategori
  final List<String> _categories = [
    'Umum', 'Pendidikan', 'Liburan', 'Kendaraan', 
    'Rumah', 'Gadget', 'Kesehatan', 'Lainnya'
  ];
  
  // Map kategori ke warna
  final Map<String, Color> _categoryColors = {
    'Umum': const Color(0xFF42A5F5),      // Biru
    'Pendidikan': const Color(0xFF26A69A), // Teal
    'Liburan': const Color(0xFFFFCA28),    // Kuning
    'Kendaraan': const Color(0xFF7E57C2),  // Ungu
    'Rumah': const Color(0xFF66BB6A),      // Hijau
    'Gadget': const Color(0xFFEC407A),     // Pink
    'Kesehatan': const Color(0xFFEF5350),  // Merah
    'Lainnya': const Color(0xFF8D6E63),    // Coklat
  };

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
      _selectedCategory = widget.existingSavingsGoal!.category;
      
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

  // Update metode saveSavingsGoal untuk menyimpan kategori
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
      id: widget.existingSavingsGoal?.id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: widget.existingSavingsGoal?.currentAmount ?? 0,
      frequency: _frequency,
      depositAmount: depositAmount,
      currencyCode: _selectedCurrency,
      createdAt: widget.existingSavingsGoal?.createdAt,
      completedAt: widget.existingSavingsGoal?.completedAt,
      transactions: widget.existingSavingsGoal?.transactions,
      category: _selectedCategory,
      categoryColorValue: _categoryColors[_selectedCategory]?.value ?? 0xFF42A5F5,
    );
    
    Navigator.pop(context, savingsGoal);
  }

  // Tambahkan widget untuk memilih kategori
  Widget _buildCategorySelector() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              final color = _categoryColors[category] ?? Colors.blue;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
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
            // Informasi Tabungan
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light 
                    ? Colors.grey[100]
                    : Colors.grey[800],
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
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
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
                            fillColor: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[800] 
                                : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black,
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
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).dividerColor),
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
                  
                  // Tambahkan UI pemilihan kategori
                  _buildCategorySelector(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Deposit plan section
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light 
                    ? Colors.grey[100]
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kode rencana pengisian tetap sama
                  const Text(
                    'Rencana Pengisian',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  // Kode untuk frequency selection tabs dan lainnya tetap sama
                  // ...
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Theme.of(context).dividerColor),
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
                                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
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
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).dividerColor),
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