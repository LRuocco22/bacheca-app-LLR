import 'package:file_picker/file_picker.dart';
import 'package:file_picker_web/file_picker_web.dart';

/// Web: Safari su iPhone restituisce il "focus" alla pagina prima di
/// consegnare il file scelto; con l'opzione predefinita la scelta poteva
/// essere scambiata per un annullamento. Qui si aspetta solo la scelta vera.
const WebOptions cvWebOptions =
    FilePickerWebOptions(cancelUploadOnWindowBlur: false);
