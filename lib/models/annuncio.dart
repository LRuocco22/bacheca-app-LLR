import 'azienda.dart';

class Annuncio {
  final int id;
  final int aziendaId;
  final String aziendaNome;
  final String titolo;
  final String descrizione;
  final DateTime? createdAt;

  /// Presente solo nell'elenco "I miei annunci" dell'area riservata.
  final int? numCandidature;

  const Annuncio({
    required this.id,
    required this.aziendaId,
    required this.aziendaNome,
    required this.titolo,
    required this.descrizione,
    this.createdAt,
    this.numCandidature,
  });

  factory Annuncio.fromJson(Map<String, dynamic> j) => Annuncio(
        id: parseInt(j['id']),
        aziendaId: parseInt(j['aziendaId']),
        aziendaNome: (j['aziendaNome'] ?? '').toString(),
        titolo: (j['titolo'] ?? '').toString(),
        descrizione: (j['descrizione'] ?? '').toString(),
        createdAt: parseDate(j['createdAt']),
        numCandidature:
            j['numCandidature'] == null ? null : parseInt(j['numCandidature']),
      );
}
