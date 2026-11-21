import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/registro_foto.dart';
import '../services/image_storage_service.dart';

class DetalhesRegistroScreen extends StatelessWidget {
  final RegistroFoto registro;

  const DetalhesRegistroScreen({super.key, required this.registro});

  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro'),
        content: const Text(
            'Deseja remover esta fotografia e seus dados permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true && registro.id != null) {
      await DatabaseHelper.instance.excluirRegistro(registro.id!);
      await ImageStorageService.excluirArquivoFoto(registro.caminhoImagem);

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arquivoImagem = File(registro.caminhoImagem);

    return Scaffold(
      appBar: AppBar(
        title: Text(registro.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (arquivoImagem.existsSync())
              Image.file(arquivoImagem, fit: BoxFit.contain)
            else
              Container(
                height: 220,
                color: Colors.grey.shade300,
                child: const Center(
                    child: Text('Arquivo de imagem não encontrado.')),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registro.titulo,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (registro.descricao.isNotEmpty) ...[
                    Text(
                      registro.descricao,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Data e Hora'),
                    subtitle: Text(registro.dataHora),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on),
                    title: const Text('Coordenadas GPS'),
                    subtitle: Text(
                      'Lat: ${registro.latitude.toStringAsFixed(6)} | Lon: ${registro.longitude.toStringAsFixed(6)}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
