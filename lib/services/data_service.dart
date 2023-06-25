import 'package:cloud_firestore/cloud_firestore.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> loadItemsByUserId(uid) async {
    return await _db
      .collection("resources")
      .where("uid", isEqualTo: uid)
      .get().then(
        (querySnapshot) {
          return querySnapshot;
        },
        onError: (e) => print("<!!! -- Error completing: $e -- !!!>"),
    );
  }

  Future<void> insertResource(data) async {
    return await _db
      .collection("resources")
      .add(data)
      .then(
        (DocumentReference documentSnapshot) => print("<??? -- Resource Inserted: ${documentSnapshot.id} -- ???>"),
        onError: (e) => print("<!!! -- Error completing: $e -- !!!>"),
      );
  }

  Future<void> insertUser(user) async {
    return await _db
      .collection("users")
      .add(user)
      .then(
        (DocumentReference documentSnapshot) => print("<??? -- User Inserted: ${documentSnapshot.id} -- ???>"),
        onError: (e) => print("<!!! -- Error completing: $e -- !!!>"),
      );
  }

}