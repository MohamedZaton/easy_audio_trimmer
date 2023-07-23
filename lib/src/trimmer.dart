import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'utils/file_formats.dart';
import 'utils/storage_dir.dart';

enum TrimmerEvent { initialized }

/// Helps in loading audio from file, saving trimmed audio to a file
/// and gives audio playback controls. Some of the helpful methods
/// are:
/// * [loadAudio()]
/// * [saveTrimmedAudio)]
/// * [audioPlaybackControl()]
class Trimmer {
  // final FlutterFFmpeg _flutterFFmpeg = FFmpegKit();

  final StreamController<TrimmerEvent> _controller =
      StreamController<TrimmerEvent>.broadcast();

  AudioPlayer? _audioPlayer;

  AudioPlayer? get audioPlayer => _audioPlayer;

  File? currentAudioFile;

  /// Listen to this stream to catch the events
  Stream<TrimmerEvent> get eventStream => _controller.stream;

  /// Loads a audio using the path provided.
  ///
  /// Returns the loaded audio file.
  Future<void> loadAudio({required File audioFile}) async {
    currentAudioFile = audioFile;
    if (audioFile.existsSync()) {
      _audioPlayer = AudioPlayer();
      await _audioPlayer?.setSource(DeviceFileSource(audioFile.path));

      _controller.add(TrimmerEvent.initialized);

      // await _audioPlayer!.).then((_) {
      //
      // });
    }
  }

  Future<String> _createFolderInAppDocDir(
    String folderName,
    StorageDir? storageDir,
  ) async {
    Directory? directory;

    if (storageDir == null) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      switch (storageDir.toString()) {
        case 'temporaryDirectory':
          directory = await getTemporaryDirectory();
          break;

        case 'applicationDocumentsDirectory':
          directory = await getApplicationDocumentsDirectory();
          break;

        case 'externalStorageDirectory':
          directory = await getExternalStorageDirectory();
          break;
      }
    }

    // Directory + folder name
    final Directory directoryFolder =
        Directory('${directory!.path}/$folderName/');

    if (await directoryFolder.exists()) {
      // If folder already exists return path
      debugPrint('Exists');
      return directoryFolder.path;
    } else {
      debugPrint('Creating');
      // If folder does not exists create folder and then return its path
      final Directory directoryNewFolder =
          await directoryFolder.create(recursive: true);
      return directoryNewFolder.path;
    }
  }

  /// Saves the trimmed audio to file system.
  ///
  ///
  /// The required parameters are [startValue], [endValue] & [onSave].
  ///
  /// The optional parameters are [audioFolderName], [audioFileName],
  /// [outputFormat], [fpsGIF], [scaleGIF], [applyAudioEncoding].
  ///
  /// The `@required` parameter [startValue] is for providing a starting point
  /// to the trimmed audio. To be specified in `milliseconds`.
  ///
  /// The `@required` parameter [endValue] is for providing an ending point
  /// to the trimmed audio. To be specified in `milliseconds`.
  ///
  /// The `@required` parameter [onSave] is a callback Function that helps to
  /// retrieve the output path as the FFmpeg processing is complete. Returns a
  /// `String`.
  ///
  /// The parameter [audioFolderName] is used to
  /// pass a folder name which will be used for creating a new
  /// folder in the selected directory. The default value for
  /// it is `Trimmer`.
  ///
  /// The parameter [audioFileName] is used for giving
  /// a new name to the trimmed audio file. By default the
  /// trimmed audio is named as `<original_file_name>_trimmed.mp4`.
  ///
  /// The parameter [outputFormat] is used for providing a
  /// file format to the trimmed audio. This only accepts value
  /// of [FileFormat] type. By default it is set to `FileFormat.mp4`,
  /// which is for `mp4` files.
  ///
  /// The parameter [storageDir] can be used for providing a storage
  /// location option. It accepts only [StorageDir] values. By default
  /// it is set to [applicationDocumentsDirectory]. Some of the
  /// storage types are:
  ///
  /// * [temporaryDirectory] (Only accessible from inside the app, can be
  /// cleared at anytime)
  ///
  /// * [applicationDocumentsDirectory] (Only accessible from inside the app)
  ///
  /// * [externalStorageDirectory] (Supports only `Android`, accessible externally)
  ///
  /// The parameters [fpsGIF] & [scaleGIF] are used only if the
  /// selected output format is `FileFormat.gif`.
  ///
  /// * [fpsGIF] for providing a FPS value (by default it is set
  /// to `10`)
  ///
  ///
  /// * [scaleGIF] for proving a width to output GIF, the height
  /// is selected by maintaining the aspect ratio automatically (by
  /// default it is set to `480`)
  ///
  ///
  /// * [applyAudioEncoding] for specifying whether to apply audio
  /// encoding (by default it is set to `false`).
  ///
  ///
  /// ADVANCED OPTION:
  ///
  /// If you want to give custom `FFmpeg` command, then define
  /// [ffmpegCommand] & [customAudioFormat] strings. The `input path`,
  /// `output path`, `start` and `end` position is already define.
  ///
  /// NOTE: The advanced option does not provide any safety check, so if wrong
  /// audio format is passed in [customAudioFormat], then the app may
  /// crash.
  ///
  Future<String> saveTrimmedAudio({
    required double startValue,
    required double endValue,
    required Function(String? outputPath) onSave,
    bool applyAudioEncoding = false,
    FileFormat? outputFormat,
    String? ffmpegCommand,
    String? customAudioFormat,
    int? fpsGIF,
    int? scaleGIF,
    String? audioFolderName,
    String? audioFileName,
    StorageDir? storageDir,
  }) async {
    final String audioPath = currentAudioFile!.path;


    String command;

    // Formatting Date and Time
    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    // String _resultString;

    // Checking the start and end point strings
    debugPrint("Start: ${startValue.toString()} & End: ${endValue.toString()}");

   String outPath = await  AudioCutter.cutAudio(audioPath, 0.0, 5.7) ;
     return outPath;
  }

  /// For getting the audio controller state, to know whether the
  /// audio is playing or paused currently.
  ///
  /// The two required parameters are [startValue] & [endValue]
  ///
  /// * [startValue] is the current starting point of the audio.
  /// * [endValue] is the current ending point of the audio.
  ///
  /// Returns a `Future<bool>`, if `true` then audio is playing
  /// otherwise paused.
  Future<bool> audioPlaybackControl({
    required double startValue,
    required double endValue,
  }) async {
    if (audioPlayer?.state == PlayerState.playing) {
      await audioPlayer?.pause();
      return false;
    } else {
      var duration = await audioPlayer!.getCurrentPosition();
      if ((duration?.inMilliseconds ?? 0) >= endValue.toInt()) {
        await audioPlayer!.seek(Duration(milliseconds: startValue.toInt()));
        await audioPlayer!.resume();
        return true;
      } else {
        await audioPlayer!.resume();
        return true;
      }
    }
  }

  /// Clean up
  void dispose() {
    _controller.close();
  }
}
class AudioCutter {
  /// Return audio file path after cutting
  static Future<String> cutAudio(String path, double start, double end) async {
    if (start < 0 || end < 0) {
      throw ArgumentError('The starting and ending points cannot be negative');
    }
    if (start > end) {
      throw ArgumentError(
          'The starting point cannot be greater than the ending point');
    }

    final Directory dir = await getTemporaryDirectory();
    final outPath = "${dir.path}/audio_cutter/output.mp3";
    await File(outPath).create(recursive: true);

    var cmd =
        "-y -i \"$path\" -vn -ss $start -to $end -ar 16k -ac 2 -b:a 96k -acodec copy $outPath";
    await FFmpegKit.executeAsync(cmd, (session) async {
      final state =
      FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();

      debugPrint("FFmpeg process exited with state $state and rc $returnCode");

      if (ReturnCode.isCancel(returnCode) == false) {
        debugPrint("FFmpeg processing completed successfully.");
        debugPrint('Audio successfully saved');
      } else {
        debugPrint("FFmpeg processing failed.");
        debugPrint('Couldn\'t save the audio');
      }
    },(log) {
      debugPrint("trim_logger:  ${log.getMessage()}") ;
    },);

    return outPath;
  }
}
