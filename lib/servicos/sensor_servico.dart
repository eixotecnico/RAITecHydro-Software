
import 'package:firebase_database/firebase_database.dart';

import '../modelos/leitura_sensor.dart';

class SensorServico {
  final FirebaseDatabase _banco = FirebaseDatabase.instance;

  DatabaseReference _referenciaLeituras(String espId) {
    return _banco.ref('esps/$espId/leituras');
  }

  /// Observa a leitura mais recente do ESP32.
  Stream<LeituraSensor?> observarUltimaLeitura(String espId) {
    return _referenciaLeituras(espId)
        .orderByChild('timestamp')
        .limitToLast(1)
        .onValue
        .map((evento) {
      final dados = evento.snapshot.value;

      if (dados == null || dados is! Map) {
        return null;
      }

      final leituras = dados.values.toList();

      if (leituras.isEmpty || leituras.last is! Map) {
        return null;
      }

      final leitura = Map<String, dynamic>.from(
        leituras.last as Map,
      );

      return LeituraSensor.fromMap(leitura);
    });
  }

  /// Observa as últimas leituras do ESP32.
  Stream<List<LeituraSensor>> observarHistorico(
    String espId, {
    int limite = 50,
  }) {
    return _referenciaLeituras(espId)
        .orderByChild('timestamp')
        .limitToLast(limite)
        .onValue
        .map((evento) {
      return _converterLeituras(evento.snapshot.value);
    });
  }

  /// Observa as leituras de um intervalo específico.
  ///
  /// Detecta automaticamente se o timestamp está em segundos
  /// ou milissegundos.
  Stream<List<LeituraSensor>> observarHistoricoPorPeriodo(
    String espId, {
    required DateTime inicio,
    required DateTime fim,
  }) {
    final referencia = _referenciaLeituras(espId);

    return referencia
        .orderByChild('timestamp')
        .limitToLast(1)
        .onValue
        .asyncExpand((evento) {
      final dados = evento.snapshot.value;

      if (dados == null || dados is! Map || dados.isEmpty) {
        return Stream.value(<LeituraSensor>[]);
      }

      final ultimaLeitura = dados.values.last;

      if (ultimaLeitura is! Map) {
        return Stream.value(<LeituraSensor>[]);
      }

      final timestamp = (ultimaLeitura['timestamp'] as num?)?.toInt();

      if (timestamp == null) {
        return Stream.value(<LeituraSensor>[]);
      }

      // Timestamps com 13 dígitos normalmente estão em milissegundos.
      // Timestamps com 10 dígitos normalmente estão em segundos.
      final divisor = timestamp > 100000000000 ? 1 : 1000;

      final inicioTimestamp =
          inicio.millisecondsSinceEpoch ~/ divisor;

      final fimTimestamp =
          fim.millisecondsSinceEpoch ~/ divisor;

      return referencia
          .orderByChild('timestamp')
          .startAt(inicioTimestamp)
          .endAt(fimTimestamp)
          .onValue
          .map((evento) {
        return _converterLeituras(evento.snapshot.value);
      });
    });
  }

  /// Converte os dados recebidos do Firebase em uma lista de leituras.
  List<LeituraSensor> _converterLeituras(dynamic dados) {
    if (dados == null || dados is! Map) {
      return [];
    }

    final resultado = <LeituraSensor>[];

    for (final item in dados.values) {
      if (item is Map) {
        resultado.add(
          LeituraSensor.fromMap(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }

    resultado.sort((a, b) {
      return (a.timestamp ?? 0).compareTo(
        b.timestamp ?? 0,
      );
    });

    return resultado;
  }
}
