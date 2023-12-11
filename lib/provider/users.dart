import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crud/data/dummy_users.dart';
import 'package:flutter_crud/models/user.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  static const _baseUrl =
      'https://fir-ifms-default-rtdb.firebaseio.com/';
  final Map<String, User> _items = {...DUMMY_USERS};


  //para nao retornar os usuarios deixando expostos a alteracao
  List<User> get all {
    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  User byIndex(int i) {
    return _items.values.elementAt((i));
  }

  Future<void> put(User user) async {
    if (user.id.trim().isNotEmpty && _items.containsKey(user.id)) 
      await http.patch(
        Uri.parse("$_baseUrl/users/${user.id}.json"),
        body: json.encode({
          'name': user.name,
          'email': user.email,
          'avatarUrl': user.avatarUrl,
        }),
      );
      _items.update(
          user.id,
          (_) => User(
              id: user.id,
              name: user.name,
              email: user.email,
              avatarUrl: user.avatarUrl));
    } else {
      final response = await http.post(
        Uri.parse("$_baseUrl/users.json"),
        body: json.encode({
          'name': user.name,
          'email': user.email,
          'avatarUrl': user.avatarUrl,
        }),
      );

      final id = json.decode(response.body)['name'];
      print(json.decode(response.body));
      _items.putIfAbsent(
          id,
          () => User(
                id: id,
                name: user.name,
                email: user.email,
                avatarUrl: user.avatarUrl,
              ));
    }

    notifyListeners();
  }

  void remove(User user) {
    if (user != null && user.id != null) {
      _items.removeWhere((key, value) => key == user.id);
      notifyListeners();
    }
  }
}
