import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final bool _isPremium = false;
  String _photoUrl = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isPremium => _isPremium;
  String get userName => 'Invitado';
  String get photoUrl => _photoUrl;

  AuthProvider() {
    _user = User(isAnonymous: true);
  }

  Future<String?> signInAsGuest() async {
    try {
      _setLoading(true);
      _user = User(isAnonymous: true);
      _setLoading(false);
      notifyListeners();
      return null;
    } catch (e) {
      _setLoading(false);
      return 'Error al iniciar sesión como invitado';
    }
  }

  Future<void> updateProfilePicture(String urlOrBase64) async {
    if (_user != null && !_user!.isAnonymous) {
      try {
        _photoUrl = urlOrBase64;
        notifyListeners();
      } catch (e) {
        debugPrint("Error actualizando foto: $e");
      }
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    if (_user == null || _user!.isAnonymous) return;

    try {
      _setLoading(true);

      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      await updateProfilePicture(base64String);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint("Error convirtiendo imagen: $e");
    }
  }

  Future<String?> changeUserEmail(String newEmail, String currentPassword) async {
    try {
      _setLoading(false);
      return null;
    } catch (e) {
      _setLoading(false);
      return 'No se puede cambiar el email en modo invitado';
    }
  }

  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class User {
  final bool isAnonymous;
  final String? uid;
  final String? email;
  final String? displayName;

  User({
    this.isAnonymous = true,
    this.uid,
    this.email,
    this.displayName,
  });
}
