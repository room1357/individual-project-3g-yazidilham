import '../models/expense.dart';

class LoopingExamples {
  static List<Expense> expenses = [
    Expense(
      id: '1',
      title: 'Nasi Goreng',
      description: 'Makan siang sederhana',
      categoryId: 'Makanan',
      amount: 20000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      id: '2',
      title: 'Ojek Online',
      description: 'Transportasi ke kampus',
      categoryId: 'Transportasi',
      amount: 15000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      id: '3',
      title: 'Buku Flutter',
      description: 'Belajar pemrograman mobile',
      categoryId: 'Pendidikan',
      amount: 80000,
      date: DateTime(2025, 9, 30),
    ),
    Expense(
      id: '4',
      title: 'Netflix',
      description: 'Langganan hiburan bulanan',
      categoryId: 'Hiburan',
      amount: 65000,
      date: DateTime(2025, 9, 28),
    ),
    Expense(
      id: '5',
      title: 'Air Minum',
      description: 'Air mineral botol',
      categoryId: 'Makanan',
      amount: 5000,
      date: DateTime(2025, 10, 2),
    ),
  ];
}
