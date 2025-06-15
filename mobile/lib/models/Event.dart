class Event {
  final int id;
  final String name;
  final String type;
  final DateTime date;
  final String description;
  final List<Link> links;

  Event({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.description,
    required this.links,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'] as int,
    name: json['name'] as String,
    type: json['type'] as String,
    date: DateTime.parse(json['date'] as String),
    description: json['description'] as String,
    links: (json['links'] as List<dynamic>)
        .map((e) => Link.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'date': date.toIso8601String(),
    'description': description,
    'links': links.map((l) => l.toJson()).toList(),
  };
}

class Link {
  final String href;
  final String rel;
  final String method;

  Link({
    required this.href,
    required this.rel,
    required this.method,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    href: json['href'] as String,
    rel: json['rel'] as String,
    method: json['method'] as String,
  );

  Map<String, dynamic> toJson() => {
    'href': href,
    'rel': rel,
    'method': method,
  };
}
