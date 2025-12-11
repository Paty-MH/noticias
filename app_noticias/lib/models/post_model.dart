class Post {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String date;
  final List<int> categories;
  final String? featuredImage;

  Post({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.categories,
    this.featuredImage,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // title.rendered, excerpt.rendered, content.rendered
    String? img;
    try {
      if (json['_embedded'] != null &&
          json['_embedded']['wp:featuredmedia'] != null &&
          (json['_embedded']['wp:featuredmedia'] as List).isNotEmpty) {
        img = json['_embedded']['wp:featuredmedia'][0]['source_url'];
      }
    } catch (e) {
      img = null;
    }

    return Post(
      id: json['id'],
      title: (json['title']?['rendered'] ?? '').toString(),
      excerpt: (json['excerpt']?['rendered'] ?? '').toString(),
      content: (json['content']?['rendered'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      featuredImage: img,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'date': date,
      'categories': categories,
      'featuredImage': featuredImage,
    };
  }
}
