import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class statusCollectorPage extends StatefulWidget {
  const statusCollectorPage({Key? key}) : super(key: key);

  @override
  _statusCollectorPage createState() => _statusCollectorPage();
}

class _statusCollectorPage extends State<statusCollectorPage> {
// text fields' controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController progressController = TextEditingController();

  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('collectors')
      .doc('tanwenyee@gmail.com')
      .collection('userCollection');

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      dateController.text = documentSnapshot['date'];
      progressController.text = documentSnapshot['progress'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  controller: progressController,
                  decoration: const InputDecoration(labelText: 'Progress'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    final String date = dateController.text;
                    final String progress = progressController.text;
                    if (date != null) {
                      await _userCollection
                          .doc(documentSnapshot!.id)
                          .update({"date": date, "progress": progress});
                      dateController.text = '';
                      progressController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _delete(String activity) async {
    await _userCollection.doc(activity).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a request')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Firebase Firestore')),
      ),
      body: StreamBuilder(
        stream: _userCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['date']),
                    subtitle: Text(documentSnapshot['progress']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _update(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _delete(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
