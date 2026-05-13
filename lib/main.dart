import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'app.dart';

/// entry point of Flutter App

Future<void> main() async {
  ///Todo: Add widget Binding
  ///Todo: Init local storage
  ///Todo: Await native spalsh
  ///Todo: Initialize Firebase
  ///Todo: Inidtialize Authentication

  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await _clearExpiredSession();
  await ApiMiddleware.init();
  runApp(const App());
}

Future<void> _clearExpiredSession() async {
  final storage = IAMLocalStorage();
  final lastActivityAt = storage.readData<int>(
    IAMLocalStorage.authLastActivityAtKey,
  );
  if (lastActivityAt == null) return;

  final lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityAt);
  final isExpired =
      DateTime.now().difference(lastActivity) >= IAMLocalStorage.authIdleTimeout;
  if (!isExpired) return;

  await ApiMiddleware.clearToken();
  await storage.removeData(IAMLocalStorage.authLastActivityAtKey);
}
