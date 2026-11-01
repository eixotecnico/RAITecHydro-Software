class LeituraSensor {
  final String espId;
  final double? temperatura;
  final double? umidadeAr;
  final double? umidadeSolo;
  final DateTime? dataHora;
  final int? timestamp;

  LeituraSensor({
    required this.espId,
    this.temperatura,
    this.umidadeAr,
    this.umidadeSolo,
    this.dataHora,
    this.timestamp,
  });

  factory LeituraSensor.fromMap(
    Map<String, dynamic> dados,
  ) {
    return LeituraSensor(
      espId: dados['espId'] as String? ?? '',
      temperatura: (dados['temperatura'] as num?)?.toDouble(),
      umidadeAr: (dados['umidadeAr'] as num?)?.toDouble(),
      umidadeSolo: (dados['umidadeSolo'] as num?)?.toDouble(),
      dataHora: DateTime.tryParse(
        dados['dataHora'] as String? ?? '',
      ),
      timestamp: (dados['timestamp'] as num?)?.toInt(),
    );
  }
}