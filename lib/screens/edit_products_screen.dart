import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditableProduct {
  String title;
  String description;
  double price;
  String imageUrl;

  EditableProduct(
      {this.title = '',
      this.description = '',
      this.price = 0.0,
      this.imageUrl = ''});
}

class EditProductsScreen extends StatefulWidget {
  static const routeName = '/edit-products';

  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _aProduct = EditableProduct();
  var _actualProduct;
  var _isProduct;
  var _isLoading = false;

  var _isInit = true;
  var _initValues = {
    'title': '',
    'price': '',
    'descriptiton': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if (productId != null) {
        _isProduct = true;

        _actualProduct =
            Provider.of<Products>(context, listen: false).findById(productId);

        _initValues = {
          'title': _actualProduct.title,
          'price': _actualProduct.price.toString(),
          'description': _actualProduct.description,
          'imageUrl': ''
        };
        _imageUrlController.text = _actualProduct.imageUrl;
      } else {
        _isProduct = false;
      }
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);

    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(
        () {},
      );
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }

    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (!_isProduct) {
      _actualProduct = Product(
          id: null,
          title: _aProduct.title,
          description: _aProduct.description,
          price: _aProduct.price,
          imageUrl: _aProduct.imageUrl);
    }
    _actualProduct = Product(
        id: _actualProduct.id,
        title: _aProduct.title,
        description: _aProduct.description,
        price: _aProduct.price,
        imageUrl: _aProduct.imageUrl,
        isFavorite: _actualProduct.isFavorite);

    if (_actualProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_actualProduct.id, _actualProduct);
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_actualProduct);
        Navigator.of(context).pop();
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error Occured'),
            content: const Text('Something went wrong'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Okay'),
              )
            ],
          ),
        );
      }
      //  finally {
      //   setState(
      //     () {
      //       _isLoading = false;
      //     },
      //   );
      //   Navigator.of(context).pop();
      // }
    }
    setState(
      () {
        _isLoading = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Products'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _aProduct.title = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a Title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _aProduct.price = double.parse(value);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a Price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Enter a positive number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _aProduct.description = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a Description';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5, right: 5),
                          width: 120,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text(
                                  'Ener an URL',
                                  textAlign: TextAlign.center,
                                )
                              : Image.network(_imageUrlController.text),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Enter the Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _aProduct.imageUrl = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter a Valid URL';
                              }
                              if (!value.startsWith('http') &&
                                  (!value.startsWith('https'))) {
                                return 'Enter a valid URL';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
