import 'package:digi/screens/notification_history.dart';
import 'package:flutter/material.dart';
import 'package:digi/screens/bottom_navigation.dart';
import 'package:digi/screens/setting_and_privacy.dart';
//Google fonts popins
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nfc_manager/nfc_manager.dart';

// Add your HomeScreen StatefulWidget here
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _transactions = [];

  void _fetchTransactions() {
    final dbRef = FirebaseDatabase.instance.ref('transactions');
    print("Setting up transactions listener...");

    dbRef.onValue.listen((event) {
      print("Received data from Firebase: ${event.snapshot.value}");
      final data = event.snapshot.value;

      if (data is Map) {
        List<Map<String, dynamic>> txList = [];
        data.forEach((key, value) {
          if (value is Map) {
            print("Processing transaction: $key -> $value");
            txList.add({
              'id': key,
              'amount': value['amount'],
              'balanceAfter': value['balanceAfter'],
              'device': value['device'],
              'timestamp': value['timestamp'],
              'type': value['type'],
            });
          }
        });

        print("Total transactions found: ${txList.length}");

        // Sort transactions by timestamp in descending order (newest first)
        txList.sort((a, b) {
          try {
            // Handle different timestamp formats
            dynamic timestampA = a['timestamp'];
            dynamic timestampB = b['timestamp'];

            DateTime dateA;
            DateTime dateB;

            // Convert timestamps to DateTime objects with better handling
            if (timestampA is String) {
              dateA = DateTime.parse(timestampA);
            } else if (timestampA is int) {
              dateA = DateTime.fromMillisecondsSinceEpoch(timestampA * 1000);
            } else {
              dateA = DateTime.fromMillisecondsSinceEpoch(
                  0); // Very old date as fallback
            }

            if (timestampB is String) {
              dateB = DateTime.parse(timestampB);
            } else if (timestampB is int) {
              dateB = DateTime.fromMillisecondsSinceEpoch(timestampB * 1000);
            } else {
              dateB = DateTime.fromMillisecondsSinceEpoch(
                  0); // Very old date as fallback
            }

            // Descending order (newest first) - newer dates have higher millisecondsSinceEpoch values
            int comparison = dateB.compareTo(dateA);

            // Add logging to verify sorting
            if (comparison != 0) {
              print(
                  "Sorting: ${a['device']} ${a['type']} (${dateA}) vs ${b['device']} ${b['type']} (${dateB}) = $comparison");
            }

            return comparison;
          } catch (e) {
            print("Error sorting transactions: $e");
            return 0; // Keep original order if parsing fails
          }
        });

        // Log the final order to verify newest is first
        if (txList.isNotEmpty) {
          print(
              "First transaction after sorting: ${txList.first['device']} ${txList.first['type']} at ${txList.first['timestamp']}");
          if (txList.length > 1) {
            print(
                "Second transaction after sorting: ${txList[1]['device']} ${txList[1]['type']} at ${txList[1]['timestamp']}");
          }
        }

        // Check for new transactions and show notifications
        final newTransactions = txList
            .where((newTx) => !_transactions
                .any((existingTx) => existingTx['id'] == newTx['id']))
            .toList();

        print("Found ${newTransactions.length} new transactions");
        print("Current _transactions count: ${_transactions.length}");

        // Show notification for each new transaction
        for (var newTx in newTransactions) {
          print(
              "Processing new transaction: ${newTx['id']} - ${newTx['type']} - \$${newTx['amount']}");
          if (_transactions.isNotEmpty) {
            // Don't show notifications on initial load
            print(
                "Showing notification for: ${newTx['type']} - \$${newTx['amount']} from ${newTx['device']}");

            // Show notification for ALL new transactions (mobile app AND terminal)
            String deviceName =
                newTx['device'] == 'Mobile App' ? 'Mobile App' : 'Terminal';
            _showNotification(
              '${newTx['type'] == 'deposit' ? 'Deposit' : 'Withdrawal'} from $deviceName',
              'Device: ${newTx['device']} | Amount: \$${newTx['amount']}',
            );
          } else {
            print("Skipping notification on initial load");
          }
        }

        setState(() {
          _transactions = txList;
        });
        print("Transactions updated in UI: ${_transactions.length}");
      } else {
        print("No transaction data found or data is not a Map: $data");
        setState(() {
          _transactions = [];
        });
      }
    }).onError((error) {
      print("Error fetching transactions: $error");
    });
  }

  int _selectedIndex = 0; // Index for the selected bottom navigation item
  String? selectedPocket;

  // Balance fetched from Realtime Database
  double _fetchedBalance = 441.00; // Default balance

  // NFC availability (keep this as it's used globally)
  bool _isNfcAvailable = false;

// Removed duplicate/stray Expanded widget and transaction list code that was outside the main widget tree.
// Removed stray code block that was outside any function or widget.
// ...existing code...

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
  void initState() {
    super.initState();
    _fetchTransactions();
    _fetchBalanceFromRealtimeDB();
    _initializeNFC();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  void dispose() {
    // Stop any running NFC session
    NfcManager.instance.stopSession().catchError((e) {
      print("Error stopping NFC session on dispose: $e");
    });
    super.dispose();
  }

  // Fetch balance from Realtime Database
  void _fetchBalanceFromRealtimeDB() {
    final dbRef = FirebaseDatabase.instance.ref('account/balance');
    dbRef.onValue.listen((event) {
      final balance = event.snapshot.value;
      if (balance != null) {
        final parsedBalance = double.tryParse(balance.toString()) ?? 441.00;
        if (_fetchedBalance != parsedBalance) {
          String changeType =
              parsedBalance > _fetchedBalance ? 'Deposit' : 'Withdrawal';
          double changeAmount = (parsedBalance - _fetchedBalance).abs();
          _showNotification(
            '$changeType Bank Terminal',
            'Amount: \$${changeAmount.toStringAsFixed(2)}',
          );
        }
        setState(() {
          _fetchedBalance = parsedBalance;
        });
        print("Fetched balance from RTDB: $parsedBalance");
      } else {
        print("No balance found in RTDB");
      }
    });
  }

  void _showNotification(String title, String body) {
    print("_showNotification called with title: '$title', body: '$body'");
    AwesomeNotifications()
        .createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    )
        .then((_) {
      print("Notification created successfully");
    }).catchError((error) {
      print("Error creating notification: $error");
    });
  }

  // Initialize NFC functionality
  void _initializeNFC() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      setState(() {
        _isNfcAvailable = isAvailable;
      });

      if (isAvailable) {
        print("NFC is available on this device");
      } else {
        print("NFC is not available on this device");
      }
    } catch (e) {
      print("Error initializing NFC: $e");
      setState(() {
        _isNfcAvailable = false;
      });
    }
  }

  // Start NFC scanning for RC522 cards
  void _startNFCScanning({
    Function(bool, double)? onPaymentSuccess,
    Function(String, String?, bool)? onStatusUpdate,
  }) async {
    if (!_isNfcAvailable) {
      _showNotification('NFC Error', 'NFC is not available on this device');
      return;
    }

    // Update status using callback
    onStatusUpdate?.call('Scanning for RC522 card...', null, true);

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print("NFC tag detected: ${tag.data}");

          // Extract card UID for RC522 cards
          String? cardId = _extractCardId(tag);

          // Update status using callback
          onStatusUpdate?.call(
            cardId != null
                ? 'RC522 Card Detected: $cardId'
                : 'Card detected but not RC522 compatible',
            cardId,
            false,
          );

          if (cardId != null) {
            _showNotification('RC522 Card Detected', 'Card ID: $cardId');
            // Process payment automatically when RC522 card is detected
            double paymentAmount = await _processNFCPayment(cardId);

            // Call the success callback if provided
            onPaymentSuccess?.call(paymentAmount > 0, paymentAmount);
          }

          // Stop NFC session after detection
          await NfcManager.instance.stopSession();
        },
      );
    } catch (e) {
      print("Error during NFC scanning: $e");
      onStatusUpdate?.call('Error scanning for NFC cards', null, false);
      _showNotification('NFC Error', 'Failed to scan for NFC cards');
      await NfcManager.instance.stopSession();
    }
  }

  // Extract card ID from NFC tag data
  String? _extractCardId(NfcTag tag) {
    try {
      // Try to get UID from different NFC technologies

      // NfcA (most common for RC522)
      if (tag.data['nfca'] != null) {
        final nfcA = tag.data['nfca'];
        if (nfcA['identifier'] != null) {
          List<int> uid = List<int>.from(nfcA['identifier']);
          return uid
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join(':')
              .toUpperCase();
        }
      }

      // NfcB
      if (tag.data['nfcb'] != null) {
        final nfcB = tag.data['nfcb'];
        if (nfcB['identifier'] != null) {
          List<int> uid = List<int>.from(nfcB['identifier']);
          return uid
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join(':')
              .toUpperCase();
        }
      }

      // NfcF
      if (tag.data['nfcf'] != null) {
        final nfcF = tag.data['nfcf'];
        if (nfcF['identifier'] != null) {
          List<int> uid = List<int>.from(nfcF['identifier']);
          return uid
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join(':')
              .toUpperCase();
        }
      }

      // NfcV
      if (tag.data['nfcv'] != null) {
        final nfcV = tag.data['nfcv'];
        if (nfcV['identifier'] != null) {
          List<int> uid = List<int>.from(nfcV['identifier']);
          return uid
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join(':')
              .toUpperCase();
        }
      }

      print("Could not extract card ID from tag data: ${tag.data}");
      return null;
    } catch (e) {
      print("Error extracting card ID: $e");
      return null;
    }
  }

  // Process NFC payment when RC522 card is detected
  Future<double> _processNFCPayment(String cardId) async {
    double paymentAmount = 25.0; // Default payment amount

    if (_fetchedBalance >= paymentAmount) {
      // Update balance directly without setState to avoid conflicts
      _fetchedBalance -= paymentAmount;

      // Add transaction to Firebase
      _addTransactionToFirebase('withdrawal', paymentAmount);

      _showNotification('NFC Payment Successful',
          'RC522 Card: $cardId\nAmount: \$${paymentAmount.toStringAsFixed(2)}');

      return paymentAmount;
    } else {
      _showNotification('Payment Failed', 'Insufficient balance for payment');
      return 0.0;
    }
  }

  // Stop NFC scanning
  void _stopNFCScanning(
      {Function(String, String?, bool)? onStatusUpdate}) async {
    try {
      await NfcManager.instance.stopSession();
      onStatusUpdate?.call('NFC scanning stopped', null, false);
    } catch (e) {
      print("Error stopping NFC session: $e");
    }
  }

  void _deposit(double amount) {
    setState(() {
      _fetchedBalance += amount;
    });
    _showNotification(
        'Deposit Successful', 'You deposited \$${amount.toStringAsFixed(2)}');

    // Add transaction to Firebase
    _addTransactionToFirebase('deposit', amount);

    // Show success dialog
    _showPaymentSuccessDialog('deposit', amount);
  }

  void _withdraw(double amount) {
    if (_fetchedBalance >= amount) {
      setState(() {
        _fetchedBalance -= amount;
      });
      _showNotification('Withdrawal Successful',
          'You withdrew \$${amount.toStringAsFixed(2)}');

      // Add transaction to Firebase
      _addTransactionToFirebase('withdrawal', amount);

      // Show success dialog
      _showPaymentSuccessDialog('withdrawal', amount);
    } else {
      _showNotification(
          'Withdrawal Failed', 'Insufficient balance for withdrawal.');
    }
  }

  // Add transaction to Firebase Realtime Database
  void _addTransactionToFirebase(String type, double amount) {
    final dbRef = FirebaseDatabase.instance.ref('transactions');
    final balanceRef = FirebaseDatabase.instance.ref('account/balance');
    final timestamp = DateTime.now().toIso8601String();

    // Add transaction record
    dbRef.push().set({
      'amount': amount,
      'balanceAfter': _fetchedBalance,
      'device': 'Mobile App',
      'timestamp': timestamp,
      'type': type,
    }).then((_) {
      print(
          "Transaction added successfully: $type, \$${amount.toStringAsFixed(2)}");
    }).catchError((error) {
      print("Error adding transaction: $error");
    });

    // Update balance in Firebase to trigger UI update through listener
    balanceRef.set(_fetchedBalance).then((_) {
      print(
          "Balance updated in Firebase: \$${_fetchedBalance.toStringAsFixed(2)}");
    }).catchError((error) {
      print("Error updating balance: $error");
    });
  }

  // Show NFC payment bottom sheet
  void _showNFCPaymentSheet() {
    bool isPaymentSuccessful = false;
    double transactionAmount = 0.0;

    // Local state for the sheet to avoid setState conflicts
    bool localIsNfcReading = false;
    String localNfcStatus = 'Ready to scan';
    String? localDetectedCardId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar (optional - can be removed since it's now static)
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/seed.png',
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 12),
                    Text(
                      isPaymentSuccessful
                          ? 'Payment Successful!'
                          : 'NFC Payment Wio Terminal',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isPaymentSuccessful
                            ? Colors.green[700]
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: !isPaymentSuccessful
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // NFC Status indicator
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // Lottie animation for NFC
                                  Container(
                                    width: 220,
                                    height: 220,
                                    child: Lottie.asset(
                                      'assets/animations/nfc.json',
                                      fit: BoxFit.contain,
                                      repeat: localIsNfcReading,
                                      animate: localIsNfcReading,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    localIsNfcReading
                                        ? 'Scanning for RC522...'
                                        : 'Ready for Wio Terminal Payment',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: localIsNfcReading
                                          ? Colors.orange[800]
                                          : Colors.blue[800],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    localNfcStatus,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (localDetectedCardId != null) ...[
                                    SizedBox(height: 12),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.green[200]!),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.credit_card,
                                              color: Colors.green[600],
                                              size: 32),
                                          SizedBox(height: 8),
                                          Text(
                                            'RC522 Card Detected',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                          Text(
                                            'ID: $localDetectedCardId',
                                            style: GoogleFonts.robotoMono(
                                              fontSize: 12,
                                              color: Colors.green[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            SizedBox(height: 32),

                            // NFC Scan button
                            if (!localIsNfcReading &&
                                localDetectedCardId == null)
                              ElevatedButton(
                                onPressed: _isNfcAvailable
                                    ? () {
                                        _startNFCScanning(
                                          onPaymentSuccess: (success, amount) {
                                            if (success) {
                                              setSheetState(() {
                                                isPaymentSuccessful = true;
                                                transactionAmount = amount;
                                              });
                                            }
                                          },
                                          onStatusUpdate:
                                              (status, cardId, isReading) {
                                            setSheetState(() {
                                              localNfcStatus = status;
                                              localDetectedCardId = cardId;
                                              localIsNfcReading = isReading;
                                            });
                                          },
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isNfcAvailable
                                      ? Colors.blue[600]
                                      : Colors.grey[400],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.nfc, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      _isNfcAvailable
                                          ? 'Make Payment'
                                          : 'NFC Not Available',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Stop scanning button
                            if (localIsNfcReading)
                              ElevatedButton(
                                onPressed: () {
                                  _stopNFCScanning(
                                    onStatusUpdate:
                                        (status, cardId, isReading) {
                                      setSheetState(() {
                                        localNfcStatus = status;
                                        localDetectedCardId = cardId;
                                        localIsNfcReading = isReading;
                                      });
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.stop, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Stop Scanning',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            SizedBox(height: 16),

                            // Simulate payment button (fallback)

                            // Close button
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Close',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          // Success view
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 40),
                            // Success animation
                            Container(
                              width: 150,
                              height: 150,
                              child: Lottie.asset(
                                'assets/animations/success_tick.json',
                                fit: BoxFit.contain,
                                repeat: false,
                                animate: true,
                              ),
                            ),
                            SizedBox(height: 30),
                            // Transaction details
                            Text(
                              'Payment of \$${transactionAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'has been processed successfully',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 30),
                            // Balance info
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'New Balance:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '\$${_fetchedBalance.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40),
                            // Done button
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Done',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Open Seeed Studio GitHub page in app browser
  void _openSeedStudioGitHub() {
    print("Opening GitHub in draggable sheet");
    // Directly open the draggable scroll sheet
    _showGitHubSheet();
  }

  // Open DigiSave GitHub page in app browser
  void _openDigiSaveGitHub() {
    print("Opening DigiSave GitHub in draggable sheet");
    // Directly open the draggable scroll sheet
    _showDigiSaveGitHubSheet();
  }

  // Show GitHub in draggable scrollable sheet
  void _showGitHubSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.2,
        maxChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar for dragging
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with title and close button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/seed.png',
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Seeed Studio GitHub',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey[300]),

              // URL address bar
              Container(
                padding: EdgeInsets.all(16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/github.png',
                        width: 16,
                        height: 16,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'GitHub',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Open in external browser
                          final Uri uri =
                              Uri.parse('https://github.com/seeed-studio');
                          try {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } catch (e) {
                            print('Error opening external browser: $e');
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.open_in_new,
                              color: Colors.blue, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add some bottom padding to prevent content from being too close to the edge
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Show DigiSave GitHub in draggable scrollable sheet
  void _showDigiSaveGitHubSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.2,
        maxChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar for dragging
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with title and close button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/terminal.png',
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'My GitHub Repository',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey[300]),

              // URL address bar
              Container(
                padding: EdgeInsets.all(16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/github.png',
                        width: 16,
                        height: 16,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DigiSave Repository',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Open in external browser
                          final Uri uri = Uri.parse(
                              'https://github.com/edwards698/Seed-Studio-DigiSave');
                          try {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } catch (e) {
                            print('Error opening external browser: $e');
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.open_in_new,
                              color: Colors.blue, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add some bottom padding to prevent content from being too close to the edge
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build info chips with icons
  Widget _buildInfoChip(String icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build repository cards
  Widget _buildRepositoryCard(String name, String description, String language,
      String stars, String forks) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder,
                color: Colors.blue[600],
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  'Public',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getLanguageColor(language),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                language,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.star_outline, size: 14, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                stars,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.call_split, size: 14, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                forks,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build repository cards

  // Helper method to get language colors
  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return Colors.blue;
      case 'c++':
        return Colors.orange;
      case 'javascript':
        return Colors.yellow[700]!;
      case 'documentation':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Helper method to build instruction steps

  Widget _buildInstructionStep(
      String number, String instruction, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              instruction,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show payment success dialog
  void _showPaymentSuccessDialog(String transactionType, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success animation/icon
                Container(
                  width: 100,
                  height: 100,
                  child: Lottie.asset(
                    'assets/animations/success_tick.json',
                    fit: BoxFit.contain,
                    repeat: false,
                    animate: true,
                  ),
                ),
                SizedBox(height: 20),
                // Success title
                Text(
                  'Payment Successful!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                // Transaction details
                Text(
                  transactionType == 'deposit'
                      ? 'Deposit of \$${amount.toStringAsFixed(2)}'
                      : transactionType == 'payment'
                          ? 'Payment of \$${amount.toStringAsFixed(2)}'
                          : 'Withdrawal of \$${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'has been processed successfully',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // Balance info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Balance:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '\$${_fetchedBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close success dialog
                      Navigator.of(context).pop(); // Close NFC sheet if open
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show NotificationHistoryScreen if Notifications tab is selected
    if (_selectedIndex == 1) {
      // Convert _transactions to List<Map<String, String>> for NotificationHistoryScreen
      // Transactions are already sorted by timestamp (newest first) from _fetchTransactions()
      final notifications = _transactions
          .map((tx) => {
                'title':
                    '${tx['type'] == 'deposit' ? 'Deposit' : 'Withdrawal'} from ${tx['device'] == 'Mobile App' ? 'Mobile App' : 'Terminal'}',
                'body':
                    'Device: ${tx['device']} | Time: ${tx['timestamp']} | Amount: \$${tx['amount']}',
                'device': tx['device'].toString(), // Add device field
                'type': tx['type'].toString(), // Add type field
                'amount': tx['amount'].toString(), // Add amount field
                'timestamp':
                    tx['timestamp'].toString(), // Add timestamp for sorting
              })
          .toList();

      // Extra sort to ensure newest transactions are always on top
      notifications.sort((a, b) {
        try {
          dynamic timestampA = a['timestamp'];
          dynamic timestampB = b['timestamp'];

          DateTime dateA;
          DateTime dateB;

          // Handle string timestamps (ISO format)
          if (timestampA is String) {
            dateA = DateTime.parse(timestampA);
          } else {
            dateA = DateTime.fromMillisecondsSinceEpoch(
                0); // Very old date as fallback
          }

          if (timestampB is String) {
            dateB = DateTime.parse(timestampB);
          } else {
            dateB = DateTime.fromMillisecondsSinceEpoch(
                0); // Very old date as fallback
          }

          // Descending order (newest first)
          int comparison = dateB.compareTo(dateA);

          // Add logging for notification sorting
          print(
              "Notification sorting: ${a['device']} vs ${b['device']} = $comparison");

          return comparison;
        } catch (e) {
          print("Error sorting notifications: $e");
          return 0;
        }
      });

      // Log final notification order
      if (notifications.isNotEmpty) {
        print(
            "First notification: ${notifications.first['device']} ${notifications.first['type']} at ${notifications.first['timestamp']}");
      }
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: NotificationHistoryScreen(notifications: notifications),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      );
    }

    // Show TerminalLibraryScreen if Settings tab is selected
    if (_selectedIndex == 2) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: TerminalLibraryScreen(),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      );
    }

    // Default: Show main home screen (Pockets tab)
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

                  // Image.asset(
                  //   'assets/icons/setting.png', // Path to local asset
                  //   width: 24,
                  //   height: 24,
                  // ),
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
                              const SizedBox(width: 8),
                              Image.asset(
                                'assets/icons/seed.png', // Path to local asset
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
                    onPressed: () => _deposit(50.0), // Example deposit
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
                    onPressed: () => _withdraw(20.0), // Example withdraw
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
                    onPressed: _showNFCPaymentSheet,
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
                          'assets/icons/nfc.png',
                          width: 25, // Adjust icon size as needed
                          height: 25,
                        ),
                        const SizedBox(width: 8), // Space between icon and text
                        Text(
                          "Deposit",
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Library Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Library",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full library screen
                    },
                    child: Text(
                      "View All",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Library Cards Grid
              Row(
                children: [
                  // Meeting App Card - Large
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/icons/video.png',
                                width: 24,
                                height: 24,
                                color: Colors.orange[800],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "New",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            "Security App",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "32 Items",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Gym UI Library Card - Small
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        // Open DigiSave GitHub page in app browser
                        _openDigiSaveGitHub();
                      },
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/icons/terminal.png',
                                  width: 20,
                                  height: 20,
                                  color: Colors.grey[700],
                                ),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              "My Library",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "1 Items",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Second Row of Library Cards
              Row(
                children: [
                  // Education Card - Small
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        // Open Seeed Studio GitHub page in app browser
                        _openSeedStudioGitHub();
                      },
                      child: Container(
                        height: 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/icons/seed.png',
                                  width: 20,
                                  height: 20,
                                  color: Colors.grey[700],
                                ),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              "Seed Studio\nOpen Source",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Task Manager Card - Small
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        // // Navigate to Terminal Library Screen
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => TerminalLibraryScreen(),
                        //   ),
                        // );
                      },
                      child: Container(
                        height: 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.grey[700],
                                  size: 20,
                                ),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              "Add Task",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
  final String device; // Add device parameter

  const TransactionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.iconColor,
    required this.device, // Make device required
  });

  @override
  Widget build(BuildContext context) {
    // Determine which icon to show based on device
    String deviceIcon;
    if (device == 'Mobile App') {
      deviceIcon = 'assets/icons/smartphone.png'; // Mobile phone icon
    } else {
      deviceIcon =
          'assets/icons/terminal.png'; // Terminal icon for terminal transactions
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[100], // Light background
                radius: 20, // Adjust radius as needed
                child: Image.asset(
                  deviceIcon, // Use device-specific icon
                  width: 24, // Adjust width as needed
                  height: 24, // Adjust height as needed
                  fit: BoxFit.contain, // Make sure icon shows fully
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
