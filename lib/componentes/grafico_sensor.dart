
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../modelos/leitura_sensor.dart';
import '../modelos/modulo.dart';
import '../servicos/sensor_servico.dart';

const Color _azulPrincipal = Color(0xFF015A84);
const Color _azulEscuro = Color(0xFF073B57);
const Color _textoPrincipal = Color(0xFF172B36);
const Color _textoSecundario = Color(0xFF52616B);

enum _PeriodoGrafico {
  dia,
  mes,
  ano,
}

class _SensorGrafico {
  final String nome;
  final String unidade;
  final IconData icone;
  final Color cor;
  final double? Function(LeituraSensor) obterValor;

  const _SensorGrafico({
    required this.nome,
    required this.unidade,
    required this.icone,
    required this.cor,
    required this.obterValor,
  });
}

class GraficoSensor extends StatefulWidget {
  final Modulo modulo;

  const GraficoSensor({
    super.key,
    required this.modulo,
  });

  @override
  State<GraficoSensor> createState() => _GraficoSensorState();
}

class _GraficoSensorState extends State<GraficoSensor> {
  final SensorServico _sensorServico = SensorServico();

  _PeriodoGrafico _periodoSelecionado = _PeriodoGrafico.dia;

  late Stream<List<LeituraSensor>> _streamHistorico;

  late DateTime _inicioPeriodo;
  late DateTime _fimPeriodo;

  int _sensorSelecionado = 0;

  final List<String> _meses = const [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  List<_SensorGrafico> get _sensoresDisponiveis {
    final sensores = <_SensorGrafico>[];

    if (widget.modulo.possuiTemperatura) {
      sensores.add(
        _SensorGrafico(
          nome: 'Temperatura',
          unidade: '°C',
          icone: Icons.thermostat_rounded,
          cor: const Color(0xFFE47B48),
          obterValor: (leitura) => leitura.temperatura,
        ),
      );
    }

    if (widget.modulo.possuiUmidadeAr) {
      sensores.add(
        _SensorGrafico(
          nome: 'Umidade do ar',
          unidade: '%',
          icone: Icons.water_drop_outlined,
          cor: const Color(0xFF3988C5),
          obterValor: (leitura) => leitura.umidadeAr,
        ),
      );
    }

    if (widget.modulo.possuiUmidadeSolo) {
      sensores.add(
        _SensorGrafico(
          nome: 'Umidade do solo',
          unidade: '%',
          icone: Icons.grass_rounded,
          cor: const Color(0xFF4E9B70),
          obterValor: (leitura) => leitura.umidadeSolo,
        ),
      );
    }

    return sensores;
  }

  @override
  void initState() {
    super.initState();
    _atualizarStream();
  }

  @override
  void didUpdateWidget(covariant GraficoSensor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.modulo.espId != widget.modulo.espId) {
      _sensorSelecionado = 0;
      _atualizarStream();
    }
  }

  void _atualizarStream() {
    final agora = DateTime.now();

    switch (_periodoSelecionado) {
      case _PeriodoGrafico.dia:
        _inicioPeriodo = DateTime(
          agora.year,
          agora.month,
          agora.day,
        );
        break;

      case _PeriodoGrafico.mes:
        _inicioPeriodo = DateTime(
          agora.year,
          agora.month,
          1,
        );
        break;

      case _PeriodoGrafico.ano:
        _inicioPeriodo = DateTime(
          agora.year,
          1,
          1,
        );
        break;
    }

    _fimPeriodo = agora;

    _streamHistorico = _sensorServico.observarHistoricoPorPeriodo(
      widget.modulo.espId,
      inicio: _inicioPeriodo,
      fim: _fimPeriodo,
    );
  }

  void _selecionarPeriodo(_PeriodoGrafico periodo) {
    setState(() {
      _periodoSelecionado = periodo;
      _atualizarStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensores = _sensoresDisponiveis;

    if (sensores.isEmpty) {
      return _construirMensagem(
        'Este módulo não possui sensores configurados.',
        Icons.sensors_off_outlined,
      );
    }

    if (_sensorSelecionado >= sensores.length) {
      _sensorSelecionado = 0;
    }

    final sensor = sensores[_sensorSelecionado];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico de monitoramento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textoPrincipal,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Selecione um sensor para acompanhar sua evolução.',
          style: TextStyle(
            color: _textoSecundario,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 17),

        _construirSelecaoSensores(sensores),

        const SizedBox(height: 18),

        _construirSelecaoPeriodo(),

        const SizedBox(height: 16),

        StreamBuilder<List<LeituraSensor>>(
          stream: _streamHistorico,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _construirCarregamento();
            }

            if (snapshot.hasError) {
              return _construirMensagem(
                'Não foi possível carregar o histórico.',
                Icons.cloud_off_outlined,
              );
            }

            final leituras = snapshot.data ?? [];

            final pontos = _agruparLeituras(
              leituras,
              sensor,
            );

            if (pontos.isEmpty) {
              return _construirMensagem(
                'Ainda não existem leituras para este período.',
                Icons.show_chart_rounded,
              );
            }

            return _construirGrafico(
              pontos,
              sensor,
            );
          },
        ),
      ],
    );
  }

  Widget _construirSelecaoSensores(
    List<_SensorGrafico> sensores,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < sensores.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),

            _construirBotaoSensor(
              sensores[i],
              i,
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirBotaoSensor(
    _SensorGrafico sensor,
    int indice,
  ) {
    final selecionado = _sensorSelecionado == indice;

    return InkWell(
      onTap: () {
        setState(() {
          _sensorSelecionado = indice;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selecionado
              ? const Color(0xFFE8F3F8)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado
                ? _azulPrincipal
                : const Color(0xFFE8EEF2),
            width: selecionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sensor.icone,
              color: selecionado
                  ? _azulPrincipal
                  : _textoSecundario,
              size: 17,
            ),
            const SizedBox(width: 7),
            Text(
              sensor.nome,
              style: TextStyle(
                color: selecionado
                    ? _azulPrincipal
                    : _textoSecundario,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirSelecaoPeriodo() {
    return Row(
      children: [
        _construirBotaoPeriodo(
          'Dia',
          _PeriodoGrafico.dia,
        ),
        const SizedBox(width: 8),
        _construirBotaoPeriodo(
          'Mês',
          _PeriodoGrafico.mes,
        ),
        const SizedBox(width: 8),
        _construirBotaoPeriodo(
          'Ano',
          _PeriodoGrafico.ano,
        ),
      ],
    );
  }

  Widget _construirBotaoPeriodo(
    String titulo,
    _PeriodoGrafico periodo,
  ) {
    final selecionado = _periodoSelecionado == periodo;

    return Expanded(
      child: InkWell(
        onTap: () => _selecionarPeriodo(periodo),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selecionado
                ? _azulPrincipal
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selecionado
                  ? _azulPrincipal
                  : const Color(0xFFE8EEF2),
            ),
          ),
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selecionado
                  ? Colors.white
                  : _textoSecundario,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _agruparLeituras(
    List<LeituraSensor> leituras,
    _SensorGrafico sensor,
  ) {
    final agrupamento = <int, List<double>>{};

    for (final leitura in leituras) {
      final valor = sensor.obterValor(leitura);

      if (valor == null) continue;

      final data = _obterDataLeitura(leitura);

      if (data == null) continue;

      if (data.isBefore(_inicioPeriodo) ||
          data.isAfter(_fimPeriodo)) {
        continue;
      }

      int chave;

      switch (_periodoSelecionado) {
        case _PeriodoGrafico.dia:
          chave = data.hour;
          break;

        case _PeriodoGrafico.mes:
          chave = data.day - 1;
          break;

        case _PeriodoGrafico.ano:
          chave = data.month - 1;
          break;
      }

      agrupamento.putIfAbsent(chave, () => []);
      agrupamento[chave]!.add(valor);
    }

    final pontos = <FlSpot>[];

    final chaves = agrupamento.keys.toList()..sort();

    for (final chave in chaves) {
      final valores = agrupamento[chave]!;

      final media = valores.reduce((a, b) => a + b) /
          valores.length;

      pontos.add(
        FlSpot(
          chave.toDouble(),
          media,
        ),
      );
    }

    return pontos;
  }

  DateTime? _obterDataLeitura(LeituraSensor leitura) {
    if (leitura.timestamp != null) {
      final timestamp = leitura.timestamp!;

      final milissegundos = timestamp > 100000000000
          ? timestamp
          : timestamp * 1000;

      return DateTime.fromMillisecondsSinceEpoch(
        milissegundos,
      );
    }

    return leitura.dataHora;
  }

  Widget _construirGrafico(
    List<FlSpot> pontos,
    _SensorGrafico sensor,
  ) {
    final valores = pontos.map((ponto) => ponto.y).toList();

    double menorValor = valores.reduce(
      (a, b) => a < b ? a : b,
    );

    double maiorValor = valores.reduce(
      (a, b) => a > b ? a : b,
    );

    double margem = (maiorValor - menorValor) * 0.2;

    if (margem < 1) margem = 1;

    final minimoY = menorValor - margem;
    final maximoY = maiorValor + margem;

    final agora = DateTime.now();

    final double maximoX;

    switch (_periodoSelecionado) {
      case _PeriodoGrafico.dia:
        maximoX = 23;
        break;

      case _PeriodoGrafico.mes:
        maximoX = DateTime(
          agora.year,
          agora.month + 1,
          0,
        ).day - 1.0;
        break;

      case _PeriodoGrafico.ano:
        maximoX = 11;
        break;
    }

    final double intervaloEixo;

    switch (_periodoSelecionado) {
      case _PeriodoGrafico.dia:
        intervaloEixo = 6;
        break;

      case _PeriodoGrafico.mes:
        intervaloEixo = 5;
        break;

      case _PeriodoGrafico.ano:
        intervaloEixo = 2;
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE8EEF2),
        ),
        boxShadow: [
          BoxShadow(
            color: _azulEscuro.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sensor.nome,
                  style: const TextStyle(
                    color: _textoPrincipal,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                sensor.unidade,
                style: TextStyle(
                  color: sensor.cor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            'Média das leituras do período',
            style: TextStyle(
              color: _textoSecundario.withOpacity(0.8),
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 205,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maximoX,
                minY: minimoY,
                maxY: maximoY,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maximoY - minimoY) / 4,
                  getDrawingHorizontalLine: (valor) {
                    return FlLine(
                      color: const Color(0xFFE8EEF2),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                ),

                borderData: FlBorderData(
                  show: false,
                ),

                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 39,
                      getTitlesWidget: (valor, meta) {
                        return Text(
                          valor.toStringAsFixed(0),
                          style: const TextStyle(
                            color: _textoSecundario,
                            fontSize: 9,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 27,
                      interval: intervaloEixo,
                      getTitlesWidget: (valor, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _formatarEixo(valor.toInt()),
                            style: const TextStyle(
                              color: _textoSecundario,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (pontosTocados) {
                      return pontosTocados.map((ponto) {
                        return LineTooltipItem(
                          '${ponto.y.toStringAsFixed(1)} ${sensor.unidade}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: pontos,
                    isCurved: true,
                    color: sensor.cor,
                    barWidth: 2.8,
                    isStrokeCapRound: true,

                    dotData: FlDotData(
                      show: pontos.length <= 15,
                    ),

                    belowBarData: BarAreaData(
                      show: true,
                      color: sensor.cor.withOpacity(0.10),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                Icons.circle,
                color: sensor.cor,
                size: 8,
              ),
              const SizedBox(width: 6),
              Text(
                _descricaoPeriodo(),
                style: const TextStyle(
                  color: _textoSecundario,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatarEixo(int valor) {
    switch (_periodoSelecionado) {
      case _PeriodoGrafico.dia:
        return '${valor.toString().padLeft(2, '0')}h';

      case _PeriodoGrafico.mes:
        return (valor + 1).toString().padLeft(2, '0');

      case _PeriodoGrafico.ano:
        if (valor < 0 || valor >= _meses.length) {
          return '';
        }

        return _meses[valor];
    }
  }

  String _descricaoPeriodo() {
    switch (_periodoSelecionado) {
      case _PeriodoGrafico.dia:
        return 'Evolução ao longo das 24 horas';

      case _PeriodoGrafico.mes:
        return 'Evolução ao longo dos dias do mês';

      case _PeriodoGrafico.ano:
        return 'Evolução ao longo dos meses do ano';
    }
  }

  Widget _construirCarregamento() {
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const CircularProgressIndicator(
        color: _azulPrincipal,
      ),
    );
  }

  Widget _construirMensagem(
    String mensagem,
    IconData icone,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EEF2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icone,
            color: _azulPrincipal,
            size: 35,
          ),
          const SizedBox(height: 10),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textoSecundario,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
