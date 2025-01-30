import 'package:flutter/material.dart';
import 'db_helper.dart'; // Import your SQLite helper

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Work Order App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttons = [
      {
        'label': 'Customer Lookup',
        'onTap': () => _navigateTo(context, const CustomerLookupPage())
      },
      {
        'label': 'Edit Existing Work Order',
        'onTap': () => _showSnackBar(context, 'Feature coming soon...')
      },
      {
        'label': 'Push All Completed Work Orders',
        'onTap': () => _showSnackBar(context, 'Pushing completed work orders...')
      },
      {
        'label': 'See Open List',
        'onTap': () => _showSnackBar(context, 'Feature coming soon...')
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Order App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 buttons per row
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 3.5, // Adjusted for smaller buttons (higher ratio = smaller height)
          children: buttons.map((button) {
            return ElevatedButton(
              onPressed: button['onTap'],
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), // Smaller padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                textStyle: const TextStyle(
                  fontSize: 16, // Further reduced font size for smaller buttons
                  fontWeight: FontWeight.w500, // Medium weight
                ),
              ),
              child: Text(
                button['label'],
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class CustomerLookupPage extends StatefulWidget {
  const CustomerLookupPage({super.key});

  @override
  State<CustomerLookupPage> createState() => _CustomerLookupPageState();
}

class _CustomerLookupPageState extends State<CustomerLookupPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedCustomer;
  bool _isLoading = false;

  // Search the database when the user types
  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper.instance;
      final results = await dbHelper.searchCompanies(query);

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      _showError('Error searching companies: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Submit the customer form
  void _submitCustomer() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final dbHelper = DatabaseHelper.instance;
        final customerData = {
          'name': _searchController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'province': _provinceController.text,
        };

        if (_selectedCustomer == null) {
          await dbHelper.insertCompany(customerData);
          _showMessage('New customer profile created.');
        } else {
          await dbHelper.updateCompany({
            'id': _selectedCustomer!['id'],
            ...customerData,
          });
          _showMessage('Customer profile updated.');
        }
      } catch (e) {
        _showError('Error saving customer: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Show a generic error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show a success message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Lookup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Company or Name',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchResults = []);
                    },
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final customer = _searchResults[index];
                      return ListTile(
                        title: Text(customer['name']),
                        subtitle: Text('${customer['city']}, ${customer['province']}'),
                        onTap: () {
                          setState(() {
                            _selectedCustomer = customer;
                            _addressController.text = customer['address'] ?? '';
                            _cityController.text = customer['city'] ?? '';
                            _provinceController.text = customer['province'] ?? '';
                          });
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitCustomer,
                child: const Text('Save Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
