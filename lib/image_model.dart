import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// This enum will manage the overall state of the app
enum ImageSection {
  noStoragePermission, // Permission denied, but not forever
  noStoragePermissionPermanent, // Permission denied forever
  browseFiles, // The UI shows the button to pick files
  imageLoaded, // File picked and shown in the screen
}

class ImageModel extends ChangeNotifier {
  ImageSection _imageSection = ImageSection.browseFiles;

  ImageSection get imageSection => _imageSection;

  set imageSection(ImageSection value) {
    if (value != _imageSection) {
      _imageSection = value;
      notifyListeners();
    }
  }

  // We are going to save the picked file in this var
  File? file;

  /// Request the files permission and updates the UI accordingly
  Future<bool> requestFilePermission() async {
    PermissionStatus result;
    // In Android we need to request the storage permission,
    // while in iOS is the photos permission
    if (Platform.isAndroid) {
      result = await Permission.storage.request();
    } else {
      result = await Permission.photos.request();
    }

    if (result.isGranted) {
      imageSection = ImageSection.browseFiles;
      return true;
    } else if (Platform.isIOS || result.isPermanentlyDenied) {
      imageSection = ImageSection.noStoragePermissionPermanent;
    } else {
      imageSection = ImageSection.noStoragePermission;
    }
    return false;
  }

  /// Invoke the file picker
  Future<void> pickFile() async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    // Update the UI with the picked file only if
    // it has a valid file path
    if (result != null &&
        result.files.isNotEmpty &&
        result.files.single.path != null) {
      file = File(result.files.single.path!);
      imageSection = ImageSection.imageLoaded;
    }
  }
}
