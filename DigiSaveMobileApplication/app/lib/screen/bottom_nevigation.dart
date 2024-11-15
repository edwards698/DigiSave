import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.selectedItemColor = Colors.blue,
    this.unselectedItemColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/wallet.png'),
          ),
          label: 'Pockets',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/pay.png'),
          ),
          label: 'Payments',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/pie-chart.png'),
          ),
          label: 'Budget',
        ),
      ],
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
    );
  }
}
