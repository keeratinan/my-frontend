import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>?> fetchCartItemsFromMongoDB() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/carts')); 
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Failed to load cart items from MongoDB. Status code: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error fetching cart items: $error');
    return null;
  }
}

Future<bool> removeItemFromMongoDB(String cartItemId) async {
  try {
    print('Attempting to delete item with ID: $cartItemId');

    final response = await http.delete(
      Uri.parse('http://localhost:3000/carts/$cartItemId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Item removed from MongoDB');
      return true;
    } else {
      print('Error removing item: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error removing item: $e');
    return false;
  }
}

  Future<void> updateMongoDBItem(String cartItemId, int newQuantity) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/carts/$cartItemId'),
        body: jsonEncode({'quantity': newQuantity}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Item updated in MongoDB');
      } else {
        print('Error updating item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating item: $e');
    }
  }

class CartModel extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void setItems(List<Map<String, dynamic>> newItems) {
    _items = newItems;
    notifyListeners();
  }

  void addItem(Map<String, dynamic> item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void decreaseItemQuantity(int index) {
    if (_items[index]['quantity'] > 1) {
      _items[index]['quantity']--;
      notifyListeners();
    }
  }

  void increaseItemQuantity(int index) {
    _items[index]['quantity']++;
    notifyListeners();
  }

  double get totalPrice => _items.fold(0, (total, item) => total + (item['price'] * item['quantity']));
}
