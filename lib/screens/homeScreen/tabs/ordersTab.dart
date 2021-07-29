import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:onlinestoremanager/blocs/ordersBloc.dart';
import 'package:onlinestoremanager/screens/homeScreen/tabs/tabsWidgets.dart';

class OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _ordersBloc = BlocProvider.getBloc<OrderBloc>();
    return StreamBuilder<List>(
        stream: _ordersBloc.outOrders,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.pink),
              ),
            );
          } else if (snapshot.data.length == 0) {
            return Center(
              child: Text(
                "Nenhum Pedido Encontrado",
                style: TextStyle(color: Colors.pink),
              ),
            );
          } else {
            return Scaffold(
              body: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemBuilder: (context, index) {
                  return OrderTile(snapshot.data[index]);
                },
                itemCount: snapshot.data.length,
              ),
              floatingActionButton: SpeedDial(
                child: Icon(Icons.sort),
                overlayOpacity: 0.4,
                overlayColor: Colors.black,
                children: [
                  SpeedDialChild(
                      child: Icon(Icons.arrow_downward_rounded),
                      labelWidget: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.all(8),
                        child: Text("Concluidos Abaixo"),
                      ),
                      onTap: () {
                        _ordersBloc.setOrderCriteria(SortCriteria.DONE_LAST);
                      }),
                  SpeedDialChild(
                      child: Icon(Icons.arrow_upward_rounded),
                      labelWidget: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.all(8),
                        child: Text("Concluidos Acima"),
                      ),
                      onTap: () {
                        _ordersBloc.setOrderCriteria(SortCriteria.DONE_FIRST);
                      }),
                ],
              ),
            );
          }
        });
  }
}
