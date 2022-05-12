import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';

import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedItem = Product(
    id: '',
    description: '',
    imageUrl: '',
    price: 0,
    title: '',
  );
  var _isInit = true;
  var initValues = {
    'title': '',
    'price': '',
    'description': '',
  };
  var isLoading = false;

  @override
  void initState() {
    _imageController.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final arguments = ModalRoute.of(context)?.settings.arguments;

      if (arguments != null) {
        _editedItem = Provider.of<ProductProvider>(context, listen: false)
            .findById(arguments.toString());
        initValues = {
          'title': _editedItem.title,
          'price': _editedItem.price.toString(),
          'description': _editedItem.description,
        };
        _imageController.text = _editedItem.imageUrl;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageController.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  void _updateImage() {
    if (!_imageController.text.startsWith('http')) {
      return;
    }
    if (!_imageFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_editedItem.id.isEmpty) {
      _formKey.currentState?.save();
      setState(() {
        isLoading = true;
      });
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(_editedItem);
        Fluttertoast.showToast(msg: 'Done added to server');
      } catch (error) {
        // print(error.toString());
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurred'),
            content: const Text('Something went wrong'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                icon: Text(
                  "Ok",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      _formKey.currentState?.save();
      setState(() {
        isLoading = true;
      });
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(_editedItem.id, _editedItem);
        Fluttertoast.showToast(msg: 'Done updating');
      } catch (error) {
        Fluttertoast.showToast(msg: 'Fail to update');
        print('error in the update in edit product $error');
      }
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    print(initValues['imageUrl']);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editedItem == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).accentColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsetsDirectional.only(top: 8),
                        child: TextFormField(
                          initialValue: initValues['title'],
                          autocorrect: true,
                          decoration: const InputDecoration(
                            label: Text('Title'),
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _editedItem = Product(
                              id: _editedItem.id,
                              description: _editedItem.description,
                              imageUrl: _editedItem.imageUrl,
                              price: _editedItem.price,
                              title: value!,
                              isFavorite: _editedItem.isFavorite,
                            );
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        initialValue: initValues['price'],
                        autocorrect: true,
                        decoration: const InputDecoration(
                          label: Text('Price'),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _editedItem = Product(
                            id: _editedItem.id,
                            description: _editedItem.description,
                            imageUrl: _editedItem.imageUrl,
                            price: double.parse(value!),
                            title: _editedItem.title,
                            isFavorite: _editedItem.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid value please enter a valid number';
                          }
                          if (double.tryParse(value)! <= 0) {
                            return 'Please enter a value greater than zero';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        initialValue: initValues['description'],
                        maxLines: 5,
                        autocorrect: true,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.multiline,
                        onSaved: (value) {
                          _editedItem = Product(
                            id: _editedItem.id,
                            description: value!,
                            imageUrl: _editedItem.imageUrl,
                            price: _editedItem.price,
                            title: _editedItem.title,
                            isFavorite: _editedItem.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a description';
                          }
                          if (value.length < 10) {
                            return 'Please enter at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextFormField(
                              autocorrect: true,
                              decoration: const InputDecoration(
                                label: Text('Image URL'),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageController,
                              focusNode: _imageFocusNode,
                              onEditingComplete: () {
                                setState(() {});
                              },
                              onSaved: (value) {
                                _editedItem = Product(
                                  id: _editedItem.id,
                                  description: _editedItem.description,
                                  imageUrl: value!,
                                  price: _editedItem.price,
                                  title: _editedItem.title,
                                  isFavorite: _editedItem.isFavorite,
                                );
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter an image URL';
                                }
                                if (!value.startsWith('http')) {
                                  return 'Please enter a valid URL.';
                                }
                                // if (!value.endsWith('.jpg') ||
                                //     !value.endsWith('.jpeg') ||
                                //     !value.endsWith('.png')) {
                                //   return 'Please enter a valid URL.';
                                // }
                              },
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsetsDirectional.only(
                              start: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageController.text.isEmpty
                                ? const Icon(Icons.image)
                                : Image.network(_imageController.text),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
