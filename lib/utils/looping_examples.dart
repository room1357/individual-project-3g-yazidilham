import '../models/expense.dart';

class LoopingExamples {
  static List<Expense> expenses = [
    Expense(
      id: '1',
      title: 'Nasi Goreng',
      description: 'Makan siang sederhana',
      category: 'Makanan',
      amount: 20000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      id: '2',
      title: 'Ojek Online',
      description: 'Transportasi ke kampus',
      category: 'Transportasi',
      amount: 15000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      id: '3',
      title: 'Buku Flutter',
      description: 'Belajar pemrograman mobile',
      category: 'Pendidikan',
      amount: 80000,
      date: DateTime(2025, 9, 30),
    ),
    Expense(
      id: '4',
      title: 'Netflix',
      description: 'Langganan hiburan bulanan',
      category: 'Hiburan',
      amount: 65000,
      date: DateTime(2025, 9, 28),
    ),
    Expense(
      id: '5',
      title: 'Air Minum',
      description: 'Air mineral botol',
      category: 'Makanan',
      amount: 5000,
      date: DateTime(2025, 10, 2),
    ),
  ];
}
