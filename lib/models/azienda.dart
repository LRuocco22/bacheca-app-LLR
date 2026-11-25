/// Parsing difensivo degli interi (possono arrivare come int, double o stringa).
int parseInt(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// Data ISO-8601 del server convertita in ora locale (null se assente).
DateTime? parseDate(dynamic v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;

class Azienda {
  final int id;
  final String nome;
  final String email;
  final DateTime? createdAt;

  const Azienda({
    required this.id,
    required this.nome,
    required this.email,
    this.createdAt,
  });

  factory Azienda.fromJson(Map<String, dynamic> j) => Azienda(
        id: parseInt(j['id']),
        nome: (j['nome'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        createdAt: parseDate(j['createdAt']),
      );
}
