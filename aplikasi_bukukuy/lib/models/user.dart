class User {
  final int idUser;
  final String nama;
  final String email;

  User({required this.idUser, required this.nama, required this.email});

  factory User.fromJson(Map<String, dynamic> j) =>
      User(idUser: j['id_user'], nama: j['nama'], email: j['email']);
}
