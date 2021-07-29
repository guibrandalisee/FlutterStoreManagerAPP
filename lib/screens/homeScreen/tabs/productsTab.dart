import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlinestoremanager/screens/homeScreen/tabs/tabsWidgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductsTab extends StatefulWidget {
  @override
  _ProductsTabState createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    RefreshController _refreshController =
        RefreshController(initialRefresh: false);
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context, builder: (context) => EditCategoryDialog());
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("products").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.pink),
              ),
            );
          else
            return SmartRefresher(
              onLoading: () {
                _refreshController.loadComplete();
              },
              onRefresh: () async {
                setState(() {});

                await Future.delayed(Duration(milliseconds: 250));

                _refreshController.refreshCompleted();
              },
              controller: _refreshController,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return CategoryTile(snapshot.data.documents[index]);
                },
                itemCount: snapshot.data.documents.length,
              ),
            );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
