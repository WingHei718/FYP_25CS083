class ProductModel {
  String name = "";
  bool isARSupported = false;
  String modelPath = "";
  String realImagePath = "";
  String virtualImagePath = "";

  set setName(String value) => name = value;
  set setIsARSupported(bool value) => isARSupported = value;
  set setModelPath(String value) => modelPath = value;
  set setRealImagePath(String value) => realImagePath = value;
  set setVirtualImagePath(String value) => virtualImagePath = value;
}