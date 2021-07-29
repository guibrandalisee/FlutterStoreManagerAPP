import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlinestoremanager/blocs/categoryBloc.dart';
import 'package:onlinestoremanager/blocs/userBloc.dart';
import 'package:onlinestoremanager/screens/productScreen/ProductScreen.dart';
import 'package:onlinestoremanager/screens/productScreen/productScreenWidgets.dart';
import 'package:shimmer/shimmer.dart';

class SearchField extends StatelessWidget {
  SearchField({this.label = "Pesquisar", this.icon = Icons.search});
  final String label;
  final IconData icon;
  @override
  Widget build(
    BuildContext context,
  ) {
    final _userBloc = BlocProvider.getBloc<UserBloc>();
    return Container(
      height: 55,
      margin: EdgeInsets.only(left: 16, right: 16),
      padding: EdgeInsets.only(left: 24, right: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: label,
                  labelStyle: TextStyle(color: Colors.white)),
              onChanged: _userBloc.onChangedSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  UserTile(this.user);
  @override
  Widget build(BuildContext context) {
    if (user.containsKey("money"))
      return ListTile(
        title: Text(user["name"]),
        subtitle: Text(user["email"]),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Pedidos: ${user['orders']}"),
            Text("Gasto: \$${user['money'].toStringAsFixed(2)}"),
          ],
        ),
      );
    else
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              height: 30,
              child: Shimmer.fromColors(
                  child: Container(
                    color: Colors.white.withAlpha(50),
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                  baseColor: Colors.white,
                  highlightColor: Colors.grey),
            ),
            SizedBox(
              width: 50,
              height: 25,
              child: Shimmer.fromColors(
                  child: Container(
                    color: Colors.white.withAlpha(50),
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                  baseColor: Colors.white,
                  highlightColor: Colors.grey),
            )
          ],
        ),
      );
  }
}

class OrderTile extends StatelessWidget {
  final DocumentSnapshot order;
  OrderTile(this.order);
  final states = [
    '',
    'Em Preparação',
    'Em Transporte',
    'Aguardando Entrega',
    'Entregue'
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Theme(
        data: ThemeData(
            dividerColor: Colors.transparent,
            primarySwatch: Colors.pink,
            brightness: Brightness.dark,
            accentColor: Colors.pinkAccent),
        child: Card(
          child: ExpansionTile(
            initiallyExpanded: order.data["status"] != 4,
            key: UniqueKey(),
            title: Text(
              "#${order.documentID.substring(order.documentID.length - 7, order.documentID.length)} - ${states[order.data["status"]]}",
              style: TextStyle(
                  color: order.data["status"] != 4
                      ? Colors.white70
                      : Colors.green),
            ),
            children: [
              Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OrderHeader(order),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: order.data["products"].map<Widget>((p) {
                        return ListTile(
                          title:
                              Text(p["product"]["title"] + " - " + p["size"]),
                          subtitle: Text(p["category"] + "/" + p["pid"]),
                          trailing: Text(
                            p["quantity"].toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          onPressed: () {
                            return showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                title: Text("Você tem certeza?"),
                                content: Text(
                                    "Exluir um pedido não só exclui ele aqui, mas também no perfil do usuario no APP da loja!"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Não',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Firestore.instance
                                            .collection('users')
                                            .document(order["clientId"])
                                            .collection('orders')
                                            .document(order.documentID)
                                            .delete();
                                        order.reference.delete();
                                      },
                                      child: Text('Sim, Excluir')),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            "Excluir",
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  order.data["status"] > 1
                                      ? Colors.blue
                                      : Colors.grey)),
                          onPressed: order.data["status"] > 1
                              ? () {
                                  order.reference.updateData(
                                      {"status": order.data["status"] - 1});
                                }
                              : null,
                          child: Text(
                            "Regredir",
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  order.data["status"] < 4
                                      ? Colors.green
                                      : Colors.grey)),
                          onPressed: order.data["status"] < 4
                              ? () {
                                  order.reference.updateData(
                                      {"status": order.data["status"] + 1});
                                }
                              : null,
                          child: Text(
                            "Avançar",
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OrderHeader extends StatelessWidget {
  final DocumentSnapshot order;
  OrderHeader(this.order);
  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProvider.getBloc<UserBloc>();
    final _user = _userBloc.getUser(order.data['clientId']);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text("${_user["name"]}"), Text("${_user["adress"]}")],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Produtos R\$${order.data['productsPrice'].toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              "Total R\$${order.data['totalPrice'].toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.w500),
            )
          ],
        )
      ],
    );
  }
}

class CategoryTile extends StatelessWidget {
  final DocumentSnapshot category;
  CategoryTile(this.category);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Theme(
        data: ThemeData(
            dividerColor: Colors.transparent,
            primarySwatch: Colors.pink,
            brightness: Brightness.dark,
            accentColor: Colors.pinkAccent),
        child: Card(
          child: ExpansionTile(
            leading: GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => EditCategoryDialog(
                          category: category,
                        ));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(category.data["icon"]),
                backgroundColor: Colors.transparent,
              ),
            ),
            title: Text(
              category.data["title"],
              style:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
            children: [
              FutureBuilder<QuerySnapshot>(
                future: category.reference.collection("items").getDocuments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Container();
                  else
                    return Container(
                      padding: EdgeInsets.only(top: 8),
                      child: Column(
                        children: snapshot.data.documents.map<Widget>((doc) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage:
                                        NetworkImage(doc.data["images"][0]),
                                  ),
                                  title: Text(doc.data["title"]),
                                  trailing: Text(
                                      "R\$${doc.data["price"].toStringAsFixed(2)}"),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => ProductScreen(
                                                  categoryId:
                                                      category.documentID,
                                                  product: doc,
                                                )));
                                  },
                                ),
                                Divider(
                                  color: Colors.white60.withOpacity(0.2),
                                )
                              ],
                            ),
                          );
                        }).toList()
                          ..add(
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.pink,
                                  ),
                                ),
                                title: Text("Adicionar"),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ProductScreen(
                                          categoryId: category.documentID)));
                                },
                              ),
                            ),
                          ),
                      ),
                    );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EditCategoryDialog extends StatelessWidget {
  final CategoryBloc _categoryBloc;
  final TextEditingController _controller;
  EditCategoryDialog({DocumentSnapshot category})
      : _categoryBloc = CategoryBloc(category),
        _controller = TextEditingController(
            text: category != null ? category.data["title"] : "");
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) => ImageSourceSheet(
                            onImageSelected: (image) {
                              _categoryBloc.setImage(image);
                            },
                          ));
                },
                child: StreamBuilder(
                    stream: _categoryBloc.outImage,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Icon(
                          Icons.image_search,
                        );
                      return CircleAvatar(
                        child: snapshot.data is File
                            ? Image.file(
                                snapshot.data,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                snapshot.data,
                                fit: BoxFit.cover,
                              ),
                        backgroundColor: Colors.transparent,
                      );
                    }),
              ),
              title: StreamBuilder<String>(
                  stream: _categoryBloc.outTitle,
                  builder: (context, snapshot) {
                    return TextField(
                      controller: _controller,
                      onChanged: _categoryBloc.setTitle,
                      decoration: InputDecoration(
                          errorText: snapshot.hasError ? snapshot.error : null),
                    );
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StreamBuilder<bool>(
                    stream: _categoryBloc.outDelete,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      return SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor: MaterialStateProperty.all(
                              snapshot.data
                                  ? Colors.red.withGreen(1)
                                  : Colors.grey[750],
                            ),
                          ),
                          onPressed: snapshot.data
                              ? () {
                                  _categoryBloc.delete();
                                  Navigator.of(context).pop();
                                }
                              : null,
                          child: Text("Excluir"),
                        ),
                      );
                    }),
                StreamBuilder<bool>(
                    stream: _categoryBloc.submitValid,
                    builder: (context, snapshot) {
                      return SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              elevation: snapshot.hasData
                                  ? MaterialStateProperty.all(5)
                                  : MaterialStateProperty.all(0)),
                          onPressed: snapshot.hasData
                              ? () async {
                                  await _categoryBloc.saveData();
                                  Navigator.of(context).pop();
                                }
                              : null,
                          child: Text("Salvar"),
                        ),
                      );
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
