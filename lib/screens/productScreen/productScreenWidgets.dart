import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagesWidget extends FormField<List> {
  ImagesWidget({
    BuildContext context,
    FormFieldSetter<List> onsaved,
    FormFieldValidator<List> validator,
    List initialValue,
  }) : super(
            onSaved: onsaved,
            validator: validator,
            initialValue: initialValue,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 124,
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: ListView(
                      key: UniqueKey(),
                      scrollDirection: Axis.horizontal,
                      children: state.value.map<Widget>((i) {
                        return Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            child: i is String
                                ? Image.network(
                                    i,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    i,
                                    fit: BoxFit.cover,
                                  ),
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title:
                                          Text("Deseja excluir essa imagem?"),
                                      content: Text(
                                          "Ao excluir essa imagem as ações só tem efeito localmente, as mesmas só serão salvas ao clicar em salvar"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancelar")),
                                        TextButton(
                                            onPressed: () {
                                              state.didChange(
                                                  state.value..remove(i));
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Excluir")),
                                      ],
                                    );
                                  });
                            },
                          ),
                        );
                      }).toList()
                        ..add(
                          GestureDetector(
                            child: Container(
                              color: Colors.grey[800],
                              height: 100,
                              width: 100,
                              child: Icon(Icons.camera_enhance),
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) => ImageSourceSheet(
                                        onImageSelected: (image) {
                                          state.didChange(
                                              state.value..add(image));
                                        },
                                      ));
                            },
                          ),
                        ),
                    ),
                  ),
                  state.hasError
                      ? Text(
                          state.errorText,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        )
                      : Container()
                ],
              );
            });
}

class ImageSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        onClosing: () {},
        builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                    onPressed: () async {
                      File image = await ImagePicker.pickImage(
                          source: ImageSource.camera);
                      imageSelected(image);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Câmera",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    )),
                Divider(
                  endIndent: 12,
                  indent: 12,
                  thickness: 1.2,
                ),
                TextButton(
                    onPressed: () async {
                      File image = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      imageSelected(image);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Galeria", style: TextStyle(color: Colors.white)),
                      ],
                    )),
              ],
            ));
  }

  final Function(File) onImageSelected;
  ImageSourceSheet({this.onImageSelected});

  void imageSelected(File image) async {
    if (image != null) {
      File croppedImage = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
      if (croppedImage != null) onImageSelected(croppedImage);
    }
  }
}

class ProductSizes extends FormField<List> {
  ProductSizes({
    BuildContext context,
    List initialValue,
    FormFieldSetter<List> onSaved,
    FormFieldValidator<List> validator,
  }) : super(
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (state) {
              return SizedBox(
                height: 34,
                child: GridView(
                  padding: EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1 / 2,
                  ),
                  children: state.value.map((s) {
                    return GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.pink, width: 3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onLongPress: () {
                        state.didChange(state.value..remove(s));
                      },
                    );
                  }).toList()
                    ..add(
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color:
                                    state.hasError ? Colors.red : Colors.pink,
                                width: 3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '+',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () async {
                          String size = await showDialog(
                              context: context,
                              builder: (context) => AddSizeDialog());
                          if (size != null) {
                            state.didChange(state.value..add(size));
                          }
                        },
                      ),
                    ),
                ),
              );
            });
}

class AddSizeDialog extends StatelessWidget {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Adicionar Tamanho",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: _controller,
              maxLength: 4,
            ),
            Container(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(_controller.text);
                  },
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.pink),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
