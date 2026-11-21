import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/registro_foto.dart';
import '../services/image_storage_service.dart';
import '../services/location_service.dart';

class NovoRegistroScreen extends StatefulWidget {
  const NovoRegistroScreen({super.key});

  @override
  State<NovoRegistroScreen> createState() => _NovoRegistroScreenState();
}

class _NovoRegistroScreenState extends State<NovoRegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  File? _imagemSelecionada;
  double? _latitude;
  double? _longitude;
  String? _dataHora;
  bool _carregando = false;

  Future<void> _capturarFotoELocalizacao() async {
    setState(() => _carregando = true);
    try {
      final foto = await ImageStorageService.capturarESalvarFoto();
      if (foto == null) {
        setState(() => _carregando = false);
        return;
      }

      final posicao = await LocationService.obterLocalizacaoAtual();
      final agora = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

      setState(() {
        _imagemSelecionada = foto;
        _latitude = posicao.latitude;
        _longitude = posicao.longitude;
        _dataHora = agora;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _salvarRegistro() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagemSelecionada == null || _latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Capture uma fotografia com GPS antes de salvar.')),
      );
      return;
    }

    final novoRegistro = RegistroFoto(
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      caminhoImagem: _imagemSelecionada!.path,
      dataHora: _dataHora!,
      latitude: _latitude!,
      longitude: _longitude!,
    );

    await DatabaseHelper.instance.inserirRegistro(novoRegistro);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _carregando ? null : _capturarFotoELocalizacao,
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _carregando
                      ? const Center(child: CircularProgressIndicator())
                      : _imagemSelecionada != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_imagemSelecionada!,
                                  fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Toque para fotografar'),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),
              if (_dataHora != null && _latitude != null && _longitude != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data e Hora: $_dataHora'),
                        const SizedBox(height: 4),
                        Text('Latitude: ${_latitude!.toStringAsFixed(6)}'),
                        Text('Longitude: ${_longitude!.toStringAsFixed(6)}'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Informe um título'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _carregando ? null : _salvarRegistro,
                icon: const Icon(Icons.save),
                label: const Text('Salvar no GeoDiário'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
