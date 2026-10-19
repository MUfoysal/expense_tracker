
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionRepository {
  TransactionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in to access transactions.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _transactions =>
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions');

  Future<String> addTransaction({
    required String type,
    required double amount,
    required String category,
    required DateTime date,
    String description = '',
  }) async {
    if (type != 'Income' && type != 'Expense') {
      throw ArgumentError.value(type, 'type', 'Invalid transaction type.');
    }

    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Amount must be greater than zero.',
      );
    }

    final document = await _transactions.add({
      'userId': _userId,
      'type': type,
      'amount': amount,
      'category': category,
      'description': description.trim(),
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Stream<List<Map<String, dynamic>>> watchTransactions() {
    return _transactions
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((document) {
            return {
              ...document.data(),
              'id': document.id,
            };
          }).toList(),
        );
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (transactionId.trim().isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty.');
    }

    await _transactions.doc(transactionId).delete();
  }
}
