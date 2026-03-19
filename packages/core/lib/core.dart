library;

export "src/connectivity/connectivity_repository.dart";
export "src/connectivity/connectivity_service.dart";
export "src/database/app_database.dart";
export "src/utils/stream_to_listenable.dart";
export "src/widgets/offline_banner.dart";
export "src/extensions/padding_extension.dart";
export "src/extensions/context_extension.dart";
export "src/exceptions/app_exception.dart";

// Re-exporta os packages de pattern para os outros packages
// não precisarem depender diretamente deles
export "package:result_dart/result_dart.dart";
export "package:result_command/result_command.dart";
export "package:drift/drift.dart" hide Column;
export "package:shared_preferences/shared_preferences.dart";
export "package:connectivity_plus/connectivity_plus.dart";
