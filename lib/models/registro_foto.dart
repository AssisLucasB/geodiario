class RegistroFoto {
  final int? id;
  final String titulo;
  final String descricao;
  final String caminhoImagem;
  final String dataHora;
  final double latitude;
  final double longitude;

  RegistroFoto({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.caminhoImagem,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'caminho_imagem': caminhoImagem,
      'data_hora': dataHora,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory RegistroFoto.fromMap(Map<String, dynamic> map) {
    return RegistroFoto(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      caminhoImagem: map['caminho_imagem'] as String,
      dataHora: map['data_hora'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}
