
import 'package:flutter/material.dart';

import '../../modelos/modulo.dart';
import '../../modelos/planta.dart';
import '../../modelos/leitura_sensor.dart';
import '../../servicos/sensor_servico.dart';
import '../../componentes/grafico_sensor.dart';

const Color azulPrincipal = Color(0xFF015A84);
const Color azulEscuro = Color(0xFF073B57);
const Color azulClaro = Color(0xFFE8F3F8);
const Color fundoTela = Color(0xFFF5F8FA);
const Color textoPrincipal = Color(0xFF172B36);
const Color textoSecundario = Color(0xFF52616B);

class DetalhesPlanta extends StatefulWidget {
  final Planta planta;
  final Modulo modulo;

  const DetalhesPlanta({
    super.key,
    required this.planta,
    required this.modulo,
  });

  @override
  State<DetalhesPlanta> createState() => _DetalhesPlantaState();
}

class _DetalhesPlantaState extends State<DetalhesPlanta> {
  final SensorServico _sensorServico = SensorServico();

  String _formatarData(DateTime? data) {
    if (data == null) {
      return 'Horário não disponível';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year} às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoTela,
      appBar: AppBar(
        backgroundColor: azulPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Monitoramento',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<LeituraSensor?>(
        stream: _sensorServico.observarUltimaLeitura(
          widget.modulo.espId,
        ),
        builder: (context, snapshot) {
          final leitura = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting &&
              leitura == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: azulPrincipal,
              ),
            );
          }

          if (snapshot.hasError) {
            return _construirErro(
              snapshot.error.toString(),
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
            children: [
              _construirIdentificacaoPlanta(),

              const SizedBox(height: 25),

              const Text(
                'Sensores',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textoPrincipal,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Acompanhe as condições da sua planta em tempo real.',
                style: TextStyle(
                  color: textoSecundario,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 16),

              if (leitura == null)
                _construirSemLeitura()
              else
                _construirSensores(leitura),

              if (leitura != null) ...[
                const SizedBox(height: 15),
                _construirUltimaAtualizacao(leitura),
              ],

              const SizedBox(height: 25),

              GraficoSensor(
                key: ValueKey(widget.modulo.espId),
                modulo: widget.modulo,
              ),

              const SizedBox(height: 25),

              _construirInformacoesModulo(),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _construirIdentificacaoPlanta() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EEF2),
        ),
        boxShadow: [
          BoxShadow(
            color: azulEscuro.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: azulClaro,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_florist_outlined,
              color: azulPrincipal,
              size: 36,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.planta.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textoPrincipal,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.planta.especie,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textoSecundario,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(
                      Icons.memory_outlined,
                      size: 14,
                      color: azulPrincipal,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        widget.modulo.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: azulPrincipal,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSensores(LeituraSensor leitura) {
    final sensores = <Widget>[];

    if (widget.modulo.possuiTemperatura) {
      sensores.add(
        _cartaoSensorCompacto(
          titulo: 'Temperatura',
          valor: leitura.temperatura?.toStringAsFixed(1) ?? '--',
          unidade: '°C',
          icone: Icons.thermostat_rounded,
          cor: const Color(0xFFE47B48),
          possuiLeitura: leitura.temperatura != null,
        ),
      );
    }

    if (widget.modulo.possuiUmidadeAr) {
      sensores.add(
        _cartaoSensorCompacto(
          titulo: 'Umidade do ar',
          valor: leitura.umidadeAr?.toStringAsFixed(1) ?? '--',
          unidade: '%',
          icone: Icons.water_drop_outlined,
          cor: const Color(0xFF3988C5),
          possuiLeitura: leitura.umidadeAr != null,
        ),
      );
    }

    if (widget.modulo.possuiUmidadeSolo) {
      sensores.add(
        _cartaoSensorCompacto(
          titulo: 'Umidade do solo',
          valor: leitura.umidadeSolo?.toStringAsFixed(1) ?? '--',
          unidade: '%',
          icone: Icons.grass_rounded,
          cor: const Color(0xFF4E9B70),
          possuiLeitura: leitura.umidadeSolo != null,
        ),
      );
    }

    if (sensores.isEmpty) {
      return _construirSemLeitura();
    }

    return SizedBox(
      height: 145,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < sensores.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),

            Expanded(
              child: sensores[i],
            ),
          ],
        ],
      ),
    );
  }

  Widget _cartaoSensorCompacto({
    required String titulo,
    required String valor,
    required String unidade,
    required IconData icone,
    required Color cor,
    required bool possuiLeitura,
  }) {
    return Container(
      height: 145,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE8EEF2),
        ),
        boxShadow: [
          BoxShadow(
            color: azulEscuro.withOpacity(0.035),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 21,
            ),
          ),

          const SizedBox(height: 11),

          Text(
            titulo,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valor,
                  style: TextStyle(
                    color: possuiLeitura
                        ? textoPrincipal
                        : textoSecundario,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (possuiLeitura) ...[
                  const SizedBox(width: 2),

                  Text(
                    unidade,
                    style: TextStyle(
                      color: cor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (!possuiLeitura) ...[
            const SizedBox(height: 4),

            const Text(
              'Sem leitura',
              style: TextStyle(
                color: textoSecundario,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirSemLeitura() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EEF2),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.sensors_off_outlined,
            color: azulPrincipal,
            size: 36,
          ),

          SizedBox(height: 10),

          Text(
            'Nenhuma leitura disponível',
            style: TextStyle(
              color: textoPrincipal,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Assim que o ESP32 enviar dados, '
            'as informações aparecerão aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textoSecundario,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirUltimaAtualizacao(LeituraSensor leitura) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: azulClaro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: azulPrincipal,
            size: 17,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Atualizado em ${_formatarData(leitura.dataHora)}',
              style: const TextStyle(
                color: azulEscuro,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirInformacoesModulo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: azulClaro,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.memory_outlined,
              color: azulPrincipal,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dispositivo responsável',
                  style: TextStyle(
                    color: azulPrincipal,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.modulo.espId,
                  style: const TextStyle(
                    color: textoSecundario,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirErro(String erro) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFFD9534F),
              size: 45,
            ),

            const SizedBox(height: 12),

            const Text(
              'Não foi possível carregar os sensores.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoPrincipal,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              erro,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textoSecundario,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
