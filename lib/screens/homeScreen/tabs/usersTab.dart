import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:onlinestoremanager/blocs/userBloc.dart';
import 'package:onlinestoremanager/screens/homeScreen/tabs/tabsWidgets.dart';

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _usersBloc = BlocProvider.getBloc<UserBloc>();
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SearchField(),
          ),
          Expanded(
            child: StreamBuilder<List>(
                stream: _usersBloc.outUsers,
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
                        "Nenhum usuário encrontrado!",
                        style: TextStyle(color: Colors.pink),
                      ),
                    );
                  } else
                    return ListView.separated(
                        itemBuilder: (context, index) {
                          return UserTile(snapshot.data[index]);
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                        itemCount: snapshot.data.length);
                }),
          )
        ],
      ),
    );
  }
}
