import 'package:flutter/material.dart';
import 'package:digi/screens/bottom_navigation.dart';
//Google fonts popins
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
        textTheme: GoogleFonts.poppinsTextTheme(), // Custom font
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
  int _selectedIndex = 0; // Index for the selected bottom navigation item
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

  final List<String> pockets = ['Rentals', 'Holiday', 'Expense'];
  final Map<String, double> pocketBalances = {
    'Rentals': 1200.00,
    'Holiday': 600.50,
    'Expense': 441.00,
  };

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
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                          width:
                              8), // Space between the name and profile picture

                      // Profile Picture
                      const CircleAvatar(
                        backgroundImage: AssetImage(
                            'assets/images/Mr._Krabs.png'), // Path to local asset
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      // User Name Text
                      Text(
                        'Edward Phiri', // Replace with the user's name or a variable
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/icons/setting.png', // Path to local asset
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              RepaintBoundary(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      // BoxShadow settings
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpansionTile(
                        title: Text(
                          selectedPocket ?? 'Main Pocket',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Color.fromARGB(255, 70, 130, 180),
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: pockets.map((pocket) {
                          return ListTile(
                            title: Text(
                              "$pocket - \$${selectedPocketBalance.toStringAsFixed(2)}",
                            ),
                            onTap: () {
                              setState(() {
                                selectedPocket = pocket;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${selectedPocketBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '*6749',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/visa.png', // Path to local asset
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                'assets/icons/master.png', // Path to local asset
                                width: 32,
                                height: 32,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/get_money.png', // Path to your asset icon
                          width: 25, // Adjust size as needed
                          height: 25,
                        ),
                        const SizedBox(width: 8), // Space between icon and text
                        Text(
                          "Get",
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/Send_money.png', // Path to your asset icon
                          width: 25, // Adjust size as needed
                          height: 25,
                        ),
                        const SizedBox(width: 8), // Space between icon and text
                        Text(
                          "Send",
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/add.png',
                          width: 25, // Adjust icon size as needed
                          height: 25,
                        ),
                        const SizedBox(width: 8), // Space between icon and text
                        Text(
                          "Add",
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              Text(
                "Recent transactions",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  //fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: const [
                    TransactionItem(
                      icon: Icons.directions_car,
                      title: 'Digi-Save Card',
                      subtitle: '12:20',
                      amount: '\$10.34',
                      iconColor: Colors.pink,
                    ),
                    TransactionItem(
                      icon: Icons.local_cafe,
                      title: 'Mobile',
                      subtitle: '11:31',
                      amount: '\$7.40',
                      iconColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final Color iconColor;

  const TransactionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent, // No background color
                radius: 20, // Adjust radius as needed
                child: ClipOval(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      const Color.fromARGB(
                          255, 33, 150, 243), // Set your desired color here
                      BlendMode
                          .srcIn, // Blend mode to apply the color to the image
                    ),
                    child: Image.asset(
                      'assets/icons/transaction.png', // Path to your asset icon
                      fit: BoxFit
                          .cover, // Ensures the image covers the CircleAvatar area
                      width: 24, // Adjust width as needed
                      height: 24, // Adjust height as needed
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
                fontSize: 16, color: const Color.fromARGB(255, 33, 150, 243)),
          ),
        ],
      ),
    );
  }
}
