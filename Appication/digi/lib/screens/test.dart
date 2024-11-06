import 'package:flutter/material.dart';
import 'package:digi/screens/bottom_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? selectedPocket;

  // Balance fetched from Firestore
  double _fetchedBalance = 441.00; // Default balance

  @override
  void initState() {
    super.initState();
    _fetchBalanceFromFirestore();
  }

  // Fetch balance from Firestore
  Future<void> _fetchBalanceFromFirestore() async {
    FirebaseFirestore.instance
        .collection('pockets')
        .doc('main-pocket')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final message = snapshot.get('message') as String;
        print("Fetched message from Firestore: $message"); // Debugging line

        // Extracting the balance from the message
        final balanceString = message.split(': ')[1];
        final balance = double.tryParse(balanceString) ?? 441.00;

        print("Parsed balance from Firestore: $balance"); // Debugging line

        setState(() {
          _fetchedBalance = balance;
        });
      } else {
        print("Document does not exist in Firestore"); // Debugging line
      }
    });
  }

  // Return balance fetched from Firestore
  double get selectedPocketBalance {
    return _fetchedBalance;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Pocket Balance: ${selectedPocketBalance.toStringAsFixed(2)}"),
      ),
      body: Center(
        child: Text(
          "Pocket Balance: ${selectedPocketBalance.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
