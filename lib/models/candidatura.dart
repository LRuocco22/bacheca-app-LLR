import 'azienda.dart';

class Candidatura {
  final int id;
  final int annuncioId;
  final String nome;
  final String cognome;
  final String email;
  final String cvNomeOriginale;
  final DateTime? createdAt;

  const Candidatura({
    required this.id,
    required this.annuncioId,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.cvNomeOriginale,
    this.createdAt,
  });

  String get nomeCompleto => '$nome $cognome';

  factory Candidatura.fromJson(Map<String, dynamic> j) => Candidatura(
        id: parseInt(j['id']),
        annuncioId: parseInt(j['annuncioId']),
        nome: (j['nome'] ?? '').toString(),
        cognome: (j['cognome'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        cvNomeOriginale: (j['cvNomeOriginale'] ?? 'curriculum.pdf').toString(),
        createdAt: parseDate(j['createdAt']),
      );
}
