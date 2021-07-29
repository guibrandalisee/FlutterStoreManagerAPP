import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  CustomInput(
      {this.icon,
      this.hint,
      this.stream,
      this.onChanged,
      this.obscure,
      this.pLeft,
      this.pBottom,
      this.pRight,
      this.pTop,
      this.type});
  IconData icon;
  String hint;
  Stream<String> stream;
  Function(String) onChanged;
  double pLeft = 16;
  double pRight = 16;
  double pTop = 8;
  double pBottom = 8;
  bool obscure = false;
  TextInputType type;
  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pLeft, pTop, pRight, pBottom),
      child: Container(
        constraints: BoxConstraints(minHeight: 55),
        padding: EdgeInsets.only(left: 16, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
              child: StreamBuilder<String>(
                  stream: stream,
                  builder: (context, snapshot) {
                    return TextField(
                      keyboardType: type,
                      onChanged: onChanged,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: 11, right: 3, top: 4, bottom: 0),
                        errorStyle: TextStyle(
                            fontSize: 12, height: 0.4, color: Colors.pink),
                        border: InputBorder.none,
                        hintText: hint,
                        labelStyle: TextStyle(color: Colors.white),
                        errorText: snapshot.hasError ? snapshot.error : null,
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
