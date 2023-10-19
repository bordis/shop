import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductFormPage> {
  final _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlController.addListener(_updateImage);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg != null) {
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;
        _imageUrlController.text = product.imageUrl;
      }
    }
  }

  void _updateImage() {
    setState(() {});
  }

  bool isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool endsWith = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');
    return isValidUrl && endsWith;
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState!.validate() ?? false;

    if (!isValid) {
      return Future.value();
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProductFromForm(_formData);
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro para salvar o produto!'),
          actions: [
            ElevatedButton(
              child: const Text('Fechar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário de Produto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(8),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _formData['name']?.toString(),
                        decoration: InputDecoration(labelText: 'Título'),
                        textInputAction: TextInputAction.next,
                        onSaved: (name) => _formData['name'] = name ?? '',
                        validator: (name) {
                          final nameString = name ?? '';
                          if (nameString.trim().isEmpty) {
                            return 'Nome é obrigatório.';
                          }
                          if (nameString.trim().length < 3) {
                            return 'Nome precisa no mínimo 3 letras.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['price']?.toString(),
                        decoration: InputDecoration(labelText: 'Preço'),
                        textInputAction: TextInputAction.next,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onSaved: (price) =>
                            _formData['price'] = double.parse(price ?? '0'),
                        validator: (price) {
                          final priceString = price ?? '';
                          final priceDouble =
                              double.tryParse(priceString) ?? -1;
                          if (priceString.trim().isEmpty) {
                            return 'Preço é obrigatório.';
                          }
                          if (priceDouble <= 0) {
                            return 'Preço precisa ser maior que zero.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['description']?.toString(),
                        decoration: InputDecoration(labelText: 'Descrição'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        onSaved: (description) =>
                            _formData['description'] = description ?? '',
                        validator: (description) {
                          final descriptionString = description ?? '';
                          if (descriptionString.trim().isEmpty) {
                            return 'Descrição é obrigatória.';
                          }
                          if (descriptionString.trim().length < 10) {
                            return 'Descrição precisa no mínimo 10 letras.';
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _imageUrlController.text.isEmpty
                                  ? const Text(
                                      'Nenhuma imagem!',
                                      style: TextStyle(fontSize: 10),
                                    )
                                  : Image.network(_imageUrlController.text,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                      return const Text('😢');
                                    })),
                          Expanded(
                            child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'URL da Imagem'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlController,
                                onFieldSubmitted: (_) => _submitForm(),
                                onSaved: (imageUrl) =>
                                    _formData['imageUrl'] = imageUrl ?? '',
                                validator: (imageUrl) {
                                  final imageUrlString = imageUrl ?? '';
                                  if (!isValidImageUrl(imageUrlString)) {
                                    return 'Informe uma URL válida!';
                                  }
                                  return null;
                                }),
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
