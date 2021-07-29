class ProductValidator {
  String validateImages(List images) {
    if (images == null || images.isEmpty)
      return "Adicione pelo menos uma imagem ao produto";

    return null;
  }

  String validateTitle(String text) {
    if (text == null || text.isEmpty) return "Preencha o título do produto";
    return null;
  }

  String validateDescription(String text) {
    if (text == null || text.isEmpty) return "Preencha a descrição do produto";
    return null;
  }

  String validatePrice(String text) {
    double price = double.tryParse(text);
    if (text == null || text.isEmpty) return "Preço invalido";
    if (!text.contains(".") || text.split(".")[1].length != 2)
      return "Utilize 2 casas decimais";
    return null;
  }
}
