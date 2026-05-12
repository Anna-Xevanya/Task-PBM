import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() =>
      _AddProductPageState();
}

class _AddProductPageState
    extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _priceController =
      TextEditingController();

  final _descController =
      TextEditingController();

  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!
        .validate()) return;

    setState(() => _isLoading = true);

    final apiService =
        Provider.of<ApiService>(
          context,
          listen: false,
        );

    try {
      await apiService.addProduct(
        _nameController.text,
        int.parse(_priceController.text),
        _descController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Product added successfully!',
            ),
            backgroundColor:
                Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll(
                'Exception: ',
                '',
              ),
            ),
            backgroundColor:
                Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  InputDecoration customInputDecoration({
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 13,
      ),

      prefixIcon: Padding(
        padding: EdgeInsets.only(
          bottom: maxLines > 1 ? 80 : 0,
        ),
        child: Icon(
          icon,
          color: Colors.grey,
          size: 20,
        ),
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                  28,
                ),
            borderSide:
                BorderSide.none,
          ),

      focusedBorder:
          OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                  28,
                ),
            borderSide:
                const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF9E111B),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF9E111B),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 20,
              ),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 30),

                const Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: 90,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                const Center(
                  child: Text(
                    'Create New Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    'Fill all product information',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // PRODUCT NAME
                TextFormField(
                  controller:
                      _nameController,

                  decoration:
                      customInputDecoration(
                        hint:
                            'Product Name',
                        icon: Icons
                            .shopping_bag_outlined,
                      ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Product name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // PRICE
                TextFormField(
                  controller:
                      _priceController,

                  keyboardType:
                      TextInputType.number,

                  decoration:
                      customInputDecoration(
                        hint:
                            'Product Price',
                        icon: Icons
                            .payments_outlined,
                      ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Price is required';
                    }

                    if (int.tryParse(
                          value,
                        ) ==
                        null) {
                      return 'Price must be number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // DESCRIPTION
                TextFormField(
                  controller:
                      _descController,

                  maxLines: 5,

                  decoration:
                      customInputDecoration(
                        hint:
                            'Product Description',
                        icon: Icons
                            .description_outlined,
                        maxLines: 5,
                      ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Description is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: _isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(
                                color:
                                    Colors.white,
                              ),
                        )
                      : ElevatedButton(
                          onPressed:
                              _submit,

                          style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors
                                        .white,

                                foregroundColor:
                                    const Color(
                                      0xFF9E111B,
                                    ),

                                elevation: 0,

                                shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            30,
                                          ),
                                    ),
                              ),

                          child:
                              const Text(
                                'SAVE PRODUCT',
                                style:
                                    TextStyle(
                                      fontSize:
                                          15,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      letterSpacing:
                                          1,
                                    ),
                              ),
                        ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }
}