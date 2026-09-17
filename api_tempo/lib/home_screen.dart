import 'package:api_tempo/services/clima_service.dart';
import 'package:api_tempo/models/clima_model.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cidadeController = TextEditingController();

  ClimaModel? _clima;
  bool _carregando = false;
  String? _erro;

  Future<void> buscarClima() async {
    final cidade = _cidadeController.text.trim();

    if (cidade.isEmpty) {
      setState(() => _erro = 'Digite uma cidade.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
      _clima = null;
    });

    try {
      final resultado = await ClimaService().buscarClima(cidade);

      if (!mounted) return;

      setState(() {
        _clima = resultado;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível buscar o clima.';
        _carregando = false;
      });
    }
  }

  @override
  void dispose() {
    _cidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text('Consulta do Clima'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: const Color(0xFFFACC15),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFACC15).withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consultar clima',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _cidadeController,
                  style: const TextStyle(color: Colors.white),
                  onFieldSubmitted: (_) => buscarClima(),
                  decoration: InputDecoration(
                    labelText: 'Cidade',
                    labelStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                    prefixIcon: const Icon(
                      Icons.location_city,
                      color: Color(0xFFFACC15),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF111827),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFFACC15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : buscarClima,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFACC15),
                      foregroundColor: const Color(0xFF111827),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _carregando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Buscar clima',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (_erro != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _erro!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                if (_clima != null) ...[
                  const SizedBox(height: 28),
                  _informacao(
                    Icons.location_on,
                    'Local',
                    _clima!.cidade,
                  ),
                  _informacao(
                    Icons.thermostat,
                    'Temperatura',
                    '${_clima!.temperatura} °C',
                  ),
                  _informacao(
                    Icons.cloud,
                    'Condição',
                    _clima!.descricao,
                  ),
                  _informacao(
                    Icons.water_drop,
                    'Umidade',
                    '${_clima!.umidade}%',
                  ),
                  _informacao(
                    Icons.air,
                    'Vento',
                    '${_clima!.vento} km/h',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _informacao(IconData icone, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icone, color: const Color(0xFFFACC15)),
          const SizedBox(width: 12),
          Text(
            '$titulo: ',
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

