class Book {
  final int idBuku;
  final String judul;
  final String penulis;
  final String? penerbit;
  final String? tahunTerbit;
  final String? deskripsi;
  final String? coverUrl;

  Book({
    required this.idBuku,
    required this.judul,
    required this.penulis,
    this.penerbit,
    this.tahunTerbit,
    this.deskripsi,
    this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> j) => Book(
        idBuku: j['id_buku'],
        judul: j['judul'],
        penulis: j['penulis'],
        penerbit: j['penerbit'],
        tahunTerbit: j['tahun_terbit'],
        deskripsi: j['deskripsi'],
        coverUrl: j['cover_url'],
      );
}