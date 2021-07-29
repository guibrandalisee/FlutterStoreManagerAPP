import 'package:flutter/material.dart';
import 'package:onlinestoremanager/blocs/loginBloc.dart';
import 'package:onlinestoremanager/screens/homeScreen/homeScreen.dart';
import 'loginScreenWidgets.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginBloc = loginBloc();

  @override
  initState() {
    _loginBloc.outState.listen((state) {
      switch (state) {
        case LoginState.SUCCESS:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
          break;
        case LoginState.FAIL:
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Erro"),
              content: Text(
                  "Você não possui os privilegios necessários ou o usuario não existe"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"))
              ],
            ),
          );
          break;

        case LoginState.IDLE:
        case LoginState.LOADING:
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<LoginState>(
        initialData: LoginState.LOADING,
        stream: _loginBloc.outState,
        builder: (context, snapshot) {
          print(snapshot.data);
          switch (snapshot.data) {
            case LoginState.LOADING:
            case LoginState.SUCCESS:
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.pink),
                ),
              );
            case LoginState.FAIL:
            case LoginState.IDLE:
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store,
                          color: Colors.pink,
                          size: 200,
                        ),
                        CustomInput(
                            icon: Icons.person_outline,
                            hint: "E-mail",
                            stream: _loginBloc.outEmail,
                            onChanged: _loginBloc.changeEmail,
                            type: TextInputType.emailAddress),
                        CustomInput(
                          icon: Icons.lock_outline,
                          hint: "Password",
                          obscure: true,
                          stream: _loginBloc.outPassword,
                          onChanged: _loginBloc.changePassword,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: StreamBuilder<bool>(
                              stream: _loginBloc.outSubmittedValid,
                              builder: (context, snapshot) {
                                return SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.pink,
                                    ),
                                    onPressed: snapshot.hasData
                                        ? _loginBloc.submit
                                        : null,
                                    child: Text(
                                      "Entrar",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                ],
              );
            default:
              return Container();
          }
        },
      ),
    );
  }
}
