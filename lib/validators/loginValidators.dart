import 'dart:async';

class LoginValidators {
  final validateEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email.contains('@') && email.contains('.') && email.length > 6) {
      sink.add(email);
    } else if (email.length > 3) {
      sink.addError("Insira um e-mail valido");
    }
  });

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password.length >= 6) {
      sink.add(password);
    } else if (password.length > 2) {
      sink.addError("Senha deve conter no minimo 6 caracteres");
    }
  });
}
