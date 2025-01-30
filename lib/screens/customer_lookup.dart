import 'package:flutter/material.dart';
import 'db_helper.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching companies: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Select a customer from the search results
  void _selectCustomer(Map<String, dynamic> customer) {
    setState(() {
      _selectedCustomer = customer;
      _searchController.text = customer['name'];
      _addressController.text = customer['address'] ?? '';
      _cityController.text = customer['city'] ?? '';
      _provinceController.text = customer['province'] ?? '';
      _searchResults = [];
    });
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
          // Insert a new customer
          await dbHelper.insertCompany(customerData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New customer profile created.')),
          );
        } else {
          // Update existing customer
          await dbHelper.updateCompany({
            'id': _selectedCustomer!['id'],
            ...customerData,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer profile updated.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving customer: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Reusable form field builder
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType inputType = TextInputType.text,
    bool isMandatory = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(labelText: label),
      validator: isMandatory
          ? (value) => value?.isEmpty == true ? 'This field is required' : null
          : null,
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

              // Autocomplete Suggestions
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
                        onTap: () => _selectCustomer(customer),
                      );
                    },
                  ),
                ),

              // Customer Details Form
              if (_selectedCustomer != null || _searchController.text.isNotEmpty)
                Expanded(
                  child: Column(
                    children: [
                      _buildTextFormField(
                        controller: _addressController,
                        label: 'Address',
                        isMandatory: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _cityController,
                        label: 'City',
                        isMandatory: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _provinceController,
                        label: 'Province',
                        isMandatory: true,
                      ),
                    ],
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
