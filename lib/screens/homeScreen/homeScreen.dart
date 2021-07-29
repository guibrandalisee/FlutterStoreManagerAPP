import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:onlinestoremanager/blocs/ordersBloc.dart';
import 'package:onlinestoremanager/blocs/userBloc.dart';
import 'package:onlinestoremanager/screens/homeScreen/tabs/ordersTab.dart';
import 'package:onlinestoremanager/screens/homeScreen/tabs/productsTab.dart';
import 'package:onlinestoremanager/screens/homeScreen/tabs/usersTab.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  int _page = 0;
  UserBloc _userBloc;
  OrderBloc _ordersBloc;
  @override
  void initState() {
    _pageController = PageController();
    _userBloc = UserBloc();
    _ordersBloc = OrderBloc();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: Theme(
      //   data: Theme.of(context).copyWith(canvasColor: Colors.pink),
      // Metodo antigo ^
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        fixedColor: Colors.white,
        backgroundColor: Colors.pink,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Clientes"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Pedidos"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Produtos"),
        ],
        onTap: (page) {
          int duration;
          int dif = (page - _pageController.page.toInt());
          if (dif < 0) dif = dif * -1;
          if (dif != 0) {
            duration = 500 * dif;
          } else {
            duration = 250;
          }
          _pageController.animateToPage(page,
              duration: Duration(milliseconds: duration), curve: Curves.ease);
        },
      ),
      body: SafeArea(
        child: BlocProvider(
          dependencies: [],
          blocs: [
            Bloc(
              (i) {
                return _userBloc;
              },
              singleton: true,
            ),
            Bloc(
              (i) {
                return _ordersBloc;
              },
              singleton: true,
            ),
          ],
          tagText: 'global',
          child: PageView(
            onPageChanged: (p) {
              setState(() {
                _page = p;
              });
            },
            controller: _pageController,
            children: [
              UsersTab(),
              OrdersTab(),
              ProductsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
