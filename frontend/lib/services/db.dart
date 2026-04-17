import 'package:cloud_firestore/cloud_firestore.dart';


final db = FirebaseFirestore.instance;

class DSM {
  String id;
  String title;
  List<String> signals;
  String frequenz;
  String modulation;
  String rxBv;

  DSM({
    required this.id,
    required this.title,
    required this.signals,
    required this.frequenz,
    required this.modulation,
    required this.rxBv,
  });

  factory DSM.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options,){
    final data = snapshot.data();
    return DSM(
      id: data?['id'],
      title: data?['title'],
      //Inshallah
      signals: data?['signals'] is List ? List<String>.from(data?['signals']) : [],
      frequenz: data?['frequenz'],
      modulation: data?['modulation'],
      rxBv: data?['rxBv'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "title": title,
      "signals": signals,
      "frequenz": frequenz,
      "modulation": modulation,
      "rxBv": rxBv,
    };
  }

}


final ref = FirebaseFirestore.instance.collection('Signals').withConverter(fromFirestore: DSM.fromFirestore, toFirestore: (DSM dsm, _) => dsm.toFirestore(),);

void listener(){
  ref.snapshots().listen(
        (event) => print("current data: event}"),
    onError: (error) => print("Listen failed: $error"),
  );
}
void addDSM(DSM dsm) {
  ref.doc(dsm.id).set(dsm);
}
/*
void addDSM(DSM dsm) {
  db.collection('Signals').doc(dsm.id).set({
    'id': dsm.id,
    'title': dsm.title,
    'signals': dsm.signals,
    'frequenz': dsm.frequenz,
    'modulation': dsm.modulation,
    'rxBv': dsm.rxBv
  }).then((value) => print("DSM Added: ${dsm.id}"))
    .catchError((error) => print("Failed to add DSM: $error"));
}
*/
void updateDSM(DSM dsm) {
  addDSM(dsm);
}
