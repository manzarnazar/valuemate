class LegalModel {
  final String title;
  final String content;

  LegalModel({required this.title, required this.content});

  factory LegalModel.fromJson(Map<String, dynamic> json) {
    return LegalModel(
      title: json['title'],
      content: json['content'],
    );
  }
}
