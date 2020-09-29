import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  searchByTag (String searchField) {
    return Firestore.instance.collection('tag').where('name' , isEqualTo: searchField).getDocuments();
  }
}