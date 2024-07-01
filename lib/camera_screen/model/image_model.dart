import 'dart:typed_data';

class ImageModel{
  Uint8List  imageByte;
  String name;
  String docType;
  ImageModel({ required this.imageByte,  required this.name,  required this.docType});

}