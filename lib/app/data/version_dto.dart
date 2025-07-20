class VersionDto {
  final String version;
  final String comment;
  final bool forceUpdate;
  final String downloadUrl;

  VersionDto({required this.version, required this.comment, required this.forceUpdate, required this.downloadUrl});

  factory VersionDto.fromJson(Map<String, dynamic> json) {
    return VersionDto(
      version: json['version'],
      comment: json['comment'],
      forceUpdate: json['force_update'],
      downloadUrl: json['download_url'],
    );
  }
}