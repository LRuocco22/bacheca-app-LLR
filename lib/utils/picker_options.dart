// Opzioni per la scelta del file, diverse tra web e app native.
// Import condizionale: sul web si usa picker_options_web.dart,
// altrove (Android/iOS nativi) picker_options_stub.dart.
export 'picker_options_stub.dart'
    if (dart.library.js_interop) 'picker_options_web.dart';
