import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlinestoremanager/blocs/productsBloc.dart';
import 'package:onlinestoremanager/screens/productScreen/productScreenWidgets.dart';
import 'package:onlinestoremanager/validators/productValidators.dart';

class ProductScreen extends StatelessWidget with ProductValidator {
  final String categoryId;
  final DocumentSnapshot product;
  final ProductBloc _productBloc;
  final _formKey = GlobalKey<FormState>();
  ProductScreen({@required this.categoryId, this.product})
      : _productBloc = ProductBloc(categoryId: categoryId, product: product);
  @override
  Widget build(BuildContext context) {
    bool salvo = true;

    Future<bool> _onWillPop() async {
      if (!salvo) {
        return (await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Quer mesmo sair sem salvar?'),
                content: Text(
                    "As alterações feitas ainda não foram salvar no banco de dados, sair agora resultara na perca dessas alterações"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Não'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Sim'),
                  ),
                ],
              ),
            )) ??
            false;
      } else {
        Navigator.of(context).pop(true);
      }
    }

    void saveProduct() async {
      salvo = true;
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Salvando Conteudo...",
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(minutes: 1),
          backgroundColor: Colors.pink,
        ));
        bool _success = await _productBloc.saveProduct();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            _success ? "Conteudo salvo!" : "erro ao salvar conteudo",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: _success ? Colors.green : Colors.red,
          duration: Duration(seconds: 3),
        ));
      }
    }

    final _fieldStyle = TextStyle(color: Colors.white, fontSize: 16);
    InputDecoration _buildDecoration({String label}) {
      return InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          alignLabelWithHint: true);
    }

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<bool>(
            stream: _productBloc.outCreated,
            initialData: false,
            builder: (context, snapshot) {
              return Text(
                  snapshot.data == true ? "Criar Produto" : "Criar Produto");
            }),
        actions: [
          StreamBuilder<bool>(
              stream: _productBloc.outCreated,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data) {
                  return StreamBuilder(
                      stream: _productBloc.outLoading,
                      initialData: false,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return IconButton(
                          icon: Icon(Icons.delete_forever),
                          onPressed: snapshot.data
                              ? null
                              : () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title:
                                          Text('Quer mesmo remover o produto?'),
                                      content: Text(
                                          "O produto será removido aqui e no banco de dados. Após isso ser feito não tem como voltar atras"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Não'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _productBloc.deleteProduct();
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Sim'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          tooltip: "Deletar Produto Permanentemente",
                        );
                      });
                } else {
                  return Container();
                }
              }),
          StreamBuilder<bool>(
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IconButton(
                  icon: Icon(Icons.save),
                  onPressed: snapshot.data ? null : saveProduct,
                  tooltip: "Salvar Altterações",
                );
              })
        ],
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: StreamBuilder<Map>(
                  stream: _productBloc.outData,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.pink),
                        ),
                      );
                    else
                      return ListView(
                        key: UniqueKey(),
                        padding: EdgeInsets.all(16),
                        children: [
                          Text(
                            "Imagens",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          ImagesWidget(
                            context: context,
                            initialValue: snapshot.data["images"],
                            onsaved: _productBloc.saveImages,
                            validator: validateImages,
                          ),
                          TextFormField(
                            onChanged: (t) {
                              salvo = false;
                            },
                            initialValue: snapshot.data["title"],
                            style: _fieldStyle,
                            decoration: _buildDecoration(label: "Título"),
                            onSaved: _productBloc.saveTitle,
                            validator: validateTitle,
                          ),
                          TextFormField(
                            onChanged: (t) {
                              salvo = false;
                            },
                            initialValue: snapshot.data["description"],
                            maxLines: 5,
                            style: _fieldStyle,
                            decoration: _buildDecoration(label: "Descrição"),
                            onSaved: _productBloc.saveDescription,
                            validator: validateDescription,
                          ),
                          TextFormField(
                            onChanged: (t) {
                              salvo = false;
                            },
                            initialValue:
                                snapshot.data["price"]?.toStringAsFixed(2),
                            style: _fieldStyle,
                            decoration: _buildDecoration(label: "Preço"),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            onSaved: _productBloc.savePrice,
                            validator: validatePrice,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Tamanhos",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          ProductSizes(
                            context: context,
                            initialValue: snapshot.data["sizes"],
                            onSaved: _productBloc.saveSizes,
                            validator: (s) {
                              if (s.isEmpty) return "Adicione um tamanho";
                              return null;
                            },
                          )
                        ],
                      );
                  }),
            ),
            StreamBuilder(
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IgnorePointer(
                  ignoring: !snapshot.data,
                  child: Container(
                    color: snapshot.data ? Colors.black54 : Colors.transparent,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
