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
  String? selectedPocket;
  final List<Map<String, dynamic>> pockets = [
    {'name': 'Main Pocket', 'balance': 441.00},
    {'name': 'Savings Pocket', 'balance': 150.00},
    {'name': 'Expense Pocket', 'balance': 75.50},
  ];

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
              // Top Row with Profile Picture and Search Icon
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://www.example.com/profile.jpg'), // Replace with actual image
                    radius: 20,
                  ),
                  Icon(Icons.search, size: 28),
                ],
              ),
              const SizedBox(height: 24),

              // Balance Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(31, 8, 8, 8),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Pocket',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ExpansionTile for the pockets
                    ExpansionTile(
                      title: Text(selectedPocket ?? 'Select a pocket'),
                      children: pockets.map((pocket) {
                        return ListTile(
                          title: Text('${pocket['name']}'),
                          subtitle: Text('\$${pocket['balance'].toStringAsFixed(2)}'),
                          onTap: () {
                            setState(() {
                              selectedPocket = pocket['name'];
                            });
                            // Optionally, close the expansion tile when a pocket is selected
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (selectedPocket != null) ...[
                      Text(
                        'Selected Pocket: $selectedPocket',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Balance: \$${pockets.firstWhere((pocket) => pocket['name'] == selectedPocket)['balance'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                              'assets/icons/visa.png', // Path to your local asset
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/icons/master.png', // Path to your local asset for MasterCard
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

              const SizedBox(height: 24),

              // Add Pocket Button
              ElevatedButton(
                onPressed: () {
                  // Logic to add a new pocket
                  // You can show a dialog or navigate to another screen
                },
                child: const Text('Add Pocket'),
              ),

              const SizedBox(height: 24),

              // Add and Send Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Add", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Send", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              // Transactions Title
              const Text(
                "Today",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Transactions List
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
