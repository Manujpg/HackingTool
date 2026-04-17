import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class SignalItem {
  String? id;
  String name;
  String hexData;
  String frequency;
  DateTime timestamp;
  String? modulation;
  String? rxBv;


  SignalItem({
    this.id,
    required this.name,
    required this.hexData,
    required this.frequency,
    required  this.timestamp,
    this.modulation,
    this.rxBv,
  });

  factory SignalItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return SignalItem(
      id: data?['id'] ?? '',
      name: data?['name'] ?? '',
      hexData: data?['hexData'] ?? '',
      frequency: data?['frequency'] ?? '',
      timestamp: (data?['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      modulation: data?['modulation'] ?? '',
      rxBv: data?['rxBv'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "name": name,
      "hexData": hexData,
      "frequency": frequency,
      "timestamp": Timestamp.fromDate(timestamp),
      "modulation": modulation,
      "rxBv": rxBv,
    };
  }
}

// Firestore Referenz mit Converter
final ref = db.collection('Signals').withConverter(
  fromFirestore: SignalItem.fromFirestore,
  toFirestore: (SignalItem item, _) => item.toFirestore(),
);

void listener() {
  ref.snapshots().listen(
        (event) => print("current data: $event"),
    onError: (error) => print("Listen failed: $error"),
  );
}

void addSignal(SignalItem item) {ref.doc(item.id).set(item).then((_) {
  print("Cloud confirmation: Signal ${item.id} successfully written!");
}).catchError((error) {
  print("Firestore Error: $error");
});
}

/*
// Beibehaltene DSM Funktionen (auskommentiert)
void addDSM(DSM dsm) {
  ref.doc(dsm.id).set(dsm);
}

void updateDSM(DSM dsm) {
  addDSM(dsm);
}

Future<List<DSM>> fetchDSM() async {
  try {
    final querySnapshot = await ref.get();
    List<DSM> dsmList = querySnapshot.docs.map((doc) => doc.data()).toList();
    print("Successfully completed");
    return dsmList;
  } catch (e) {
    print("Error completing: $e");
    return [];
  }
}
*/

void updateSignal(SignalItem item) {
  try {
  addSignal(item);
  print("Signal ${item.id} successfully updated!");
  } catch (e) {
    print("Firestore Error: $e");
  }
}
void deleteSignal(SignalItem item) {
  ref.doc(item.id).delete().then(
        (doc) => print("Document deleted"),
    onError: (e) => print("Error updating document $e"),
  );
}

Future<List<SignalItem>> fetchSignals() async {
  try {
    final querySnapshot = await ref.get();
    List<SignalItem> signalList = querySnapshot.docs.map((doc) => doc.data()).toList();
    print("Successfully fetched signals");
    return signalList;
  } catch (e) {
    print("Error fetching: $e");
    return [];
  }
}

// Static objects for testing
final List<SignalItem> testSignals = [
  SignalItem(
    id: 'test_01',
    name: 'Garage Remote',
    hexData: 'A1B2C3D4',
    frequency: '433.92 MHz',
    timestamp: DateTime.now(),
    modulation: 'OOK',
    rxBv: '12V',
  ),
  SignalItem(
    id: 'test_02',
    name: 'Weather Station',
    hexData: 'E5F6G7H8',
    frequency: '868.30 MHz',
    timestamp: DateTime.now(),
    modulation: 'FSK',
    rxBv: '3.3V',
  ),
];

void sendTestSignals() {
  for (var signal in testSignals) {
    addSignal(signal);
  }
}
/*
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

//Hier sind alle DSM in einer Liste? Nicht ganz UseCase abgedeckt wrrscheinlich wird Stream/Listner diese Aufgabe erfüllen
Future<List<DSM>> fetchDSM() async {
  try {

    final querySnapshot = await ref.get();

    //mapped query in Liste
    List<DSM> dsmList = querySnapshot.docs.map((doc) => doc.data()).toList();

    print("Successfully completed");
    return dsmList;

  } catch (e) {
    print("Error completing: $e");

    return [];
  }
}


// Static objects for testing
final List<DSM> testDSMs = [
  DSM(
    id: 'test_signal_01',
    title: 'Garage Remote',
    signals: ['raw_01', 'raw_02'],
    frequenz: '433.92 MHz',
    modulation: 'OOK',
    rxBv: '12V',
  ),
  DSM(
    id: 'test_signal_02',
    title: 'Weather Station',
    signals: ['data_packet_A'],
    frequenz: '868.30 MHz',
    modulation: 'FSK',
    rxBv: '3.3V',
  ),
  DSM(
    id: 'test_signal_03',
    title: 'Car Key Fob',
    signals: ['lock', 'unlock', 'trunk'],
    frequenz: '315.00 MHz',
    modulation: 'ASK',
    rxBv: '5V',
  ),
];

// Helper function to send all test data
void sendTestDSMs() {
  for (var dsm in testDSMs) {
    addDSM(dsm);
  }
}

*/