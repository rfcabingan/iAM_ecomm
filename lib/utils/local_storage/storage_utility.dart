import 'package:get_storage/get_storage.dart';

/// Generic class for managing local data storage.
/// Implemented as a Singleton.
class IAMLocalStorage {
  // Singleton instance
  static final IAMLocalStorage _instance = IAMLocalStorage._internal();

  // Factory constructor returns the singleton instance
  factory IAMLocalStorage() {
    return _instance;
  }

  // Private constructor
  IAMLocalStorage._internal();

  // Instance of GetStorage
  final _storage = GetStorage();

  /// Generic method to save data
  Future<void> saveData<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  /// Generic method to read data
  T? readData<T>(String key) {
    return _storage.read<T>(key);
  }

  /// Generic method to remove data
  Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  /// Clear all data in storage
  Future<void> clearAll() async {
    await _storage.erase();
  }
}
