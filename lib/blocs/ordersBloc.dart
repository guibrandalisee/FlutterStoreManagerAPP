import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

enum SortCriteria { DONE_FIRST, DONE_LAST, NONE }

class OrderBloc extends BlocBase {
  final _ordersController = BehaviorSubject<List>();
  List<DocumentSnapshot> _orders = [];
  SortCriteria _criteria;
  Firestore _firestore = Firestore.instance;
  Stream<List> get outOrders => _ordersController.stream;
  OrderBloc() {
    _addOrdersListener();
  }
  void _addOrdersListener() {
    _firestore.collection("orders").snapshots().listen((snapshot) {
      snapshot.documentChanges.forEach((change) {
        String orderId = change.document.documentID;

        switch (change.type) {
          case DocumentChangeType.added:
            _orders.add(change.document);
            break;
          case DocumentChangeType.modified:
            int i = 0;
            int index = 0;
            // vai remover onde o order.documentID for = oid
            _orders.removeWhere((order) {
              if (order.documentID == orderId) {
                index = i;
                return true;
              } else {
                ++i;
                return false;
              }
            });
            // e vai adicionar um novo documento na mesma posição do anterior
            _orders.insert(index, change.document);
            _criteria = SortCriteria.NONE;
            break;
          case DocumentChangeType.removed:
            _orders.removeWhere((order) => order.documentID == orderId);
            break;
        }
      });

      _sort();
    });
  }

  void setOrderCriteria(SortCriteria criteria) {
    _criteria = criteria;
    _sort();
  }

  void _sort() {
    switch (_criteria) {
      case SortCriteria.DONE_FIRST:
        _orders.sort((a, b) {
          int sa = a.data["status"];
          int sb = b.data["status"];
          if (sa < sb)
            return 1;
          else if (sa > sb)
            return -1;
          else
            return 0;
        });
        break;
      case SortCriteria.DONE_LAST:
        _orders.sort((a, b) {
          int sa = a.data["status"];
          int sb = b.data["status"];
          if (sa > sb)
            return 1;
          else if (sa < sb)
            return -1;
          else
            return 0;
        });
        break;
      case SortCriteria.NONE:
        break;
    }
    _ordersController.add(_orders);
  }

  @override
  void dispose() {
    _ordersController.close();
    super.dispose();
  }
}
