import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/registro_foto.dart';
import 'detalhes_registro_screen.dart';
import 'novo_registro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<RegistroFoto>> _registrosFuture;

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  void _atualizarLista() {
    setState(() {
      _registrosFuture = DatabaseHelper.instance.listarRegistros();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GeoDiário')),
      body: FutureBuilder<List<RegistroFoto>>(
        future: _registrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final registros = snapshot.data ?? [];
          if (registros.isEmpty) {
            return const Center(
              child: Text(
                  'Nenhum registro encontrado.\nToque no botão + para começar.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: registros.length,
            itemBuilder: (context, index) {
              final item = registros[index];
              final arquivo = File(item.caminhoImagem);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: arquivo.existsSync()
                        ? Image.file(arquivo,
                            width: 56, height: 56, fit: BoxFit.cover)
                        : const Icon(Icons.broken_image, size: 40),
                  ),
                  title: Text(item.titulo,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${item.dataHora}\nGPS: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}',
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    final houveAlteracao = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalhesRegistroScreen(registro: item),
                      ),
                    );
                    if (houveAlteracao == true) _atualizarLista();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final salvo = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const NovoRegistroScreen()),
          );
          if (salvo == true) _atualizarLista();
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
