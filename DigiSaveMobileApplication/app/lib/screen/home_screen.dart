import 'package:app/screen/bottom_nevigation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  final List<String> pockets = ['Rentals', 'Holiday', 'Expense'];
  final Map<String, double> pocketBalances = {
    'Rentals': 1200.00,
    'Holiday': 600.50,
    'Expense': 441.00,
  };

  double get selectedPocketBalance {
    return pocketBalances[selectedPocket] ?? 441.00;
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
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/Mr._Krabs.png'), // Path to local asset
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
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
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 70, 130, 180),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: pockets.map((pocket) {
                          return ListTile(
                            title: Text(
                              '$pocket - \$${pocketBalances[pocket]!.toStringAsFixed(2)}',
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
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '*6749',
                            style: TextStyle(
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
                      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text("Get", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text("Send", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const Text(
                "Recent transactions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: const [
                    TransactionItem(
                      icon: Icons.directions_car,
                      title: 'Lyft',
                      subtitle: '12:20',
                      amount: '\$10.34',
                      iconColor: Colors.pink,
                    ),
                    TransactionItem(
                      icon: Icons.local_cafe,
                      title: 'Starbucks',
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
                backgroundColor: iconColor,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
