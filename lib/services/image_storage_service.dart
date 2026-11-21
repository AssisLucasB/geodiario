import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> capturarESalvarFoto() async {
    final XFile? fotoCapturada = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (fotoCapturada == null) return null;

    final diretorioApp = await getApplicationDocumentsDirectory();
    final nomeArquivo =
        'geo_${DateTime.now().millisecondsSinceEpoch}${path.extension(fotoCapturada.path)}';
    final caminhoDestino = path.join(diretorioApp.path, nomeArquivo);

    final arquivoSalvo = await File(fotoCapturada.path).copy(caminhoDestino);
    return arquivoSalvo;
  }

  static Future<void> excluirArquivoFoto(String caminhoImagem) async {
    final arquivo = File(caminhoImagem);
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }
}
