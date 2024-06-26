import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:fijkplayer/fijkplayer.dart';

void main() {
  runApp(const DeepSeaRadio());
}

// _videoPlayer.prepareAsync().then((_) => setState(() {}));
// _videoPlayer.setDataSource('asset:///assets/audios/nigga.aac', autoPlay: true);
// _audioPlayer = AudioPlayer();
// _audioPlayer
//     .setUrl('asset:///assets/videos/test.mp4')
//     .then((_) => _audioPlayer.play());
// .then((_) => setState(() {}));

// FFmpegKit.execute(
//   '-y -f lavfi -i anoisesrc=color=brown:amplitude=0.4 -filter "lowpass=f=400" -f flv -ar 44100 -ab 64000 -ac 1 $pipe'
// );

// getApplicationDocumentsDirectory().then((appDocumentsDir) =>
//   print(appDocumentsDir.listSync(recursive: true))
//   //_log = join(appDocumentsDir.path, "/")
// );
// var dir =
//     Directory.fromUri(Uri.file("/data/user/0/com.example.test_drive"));
// print(dir.listSync(recursive: true));
// rootBundle.loadString();

// FFmpegKitConfig.selectDocumentForWrite('nigga.aac', 'audio/*').then((uri) {
//     FFmpegKitConfig.getSafParameterForWrite(uri!).then((safUrl) {
//         FFmpegKit.execute(
//           '-f lavfi -i anoisesrc=color=brown:amplitude=0.4 -filter "lowpass=f=400" -t 1 -c:a aac $safUrl')
//         .then((session) async {
//             final returnCode = await session.getReturnCode();
//             if (ReturnCode.isSuccess(returnCode)) {
//               _log = "SUCCESS!";
//             } else if (ReturnCode.isCancel(returnCode)) {
//               _log = "CANCELED! 😵‍💫";
//             } else {
//               // ERROR
//               _log = "ERRORED! 🤒";
//             }
//             session.getOutput().then(
//               (fullOutput) => setState(() => _log = "$_log\n$fullOutput"));
//         });
//     });
// });




// FFmpegKitConfig.registerNewFFmpegPipe().then((pipe) {
//     _pipe = pipe;
//     FFmpegKit.execute(// ADD -y option as the leftmost flag!!!
//       // '-y -f lavfi -i anoisesrc=color=brown:amplitude=0.4 -filter "lowpass=f=400" -f flac $pipe' // matroska
//       '-y -f lavfi -i anoisesrc=color=brown:amplitude=0.4 -filter "lowpass=f=400" -f flv -ar 44100 -ab 64000 -ac 1 $pipe')
//     .then((session) async {
//         final returnCode = await session.getReturnCode();
//         if (ReturnCode.isSuccess(returnCode)) {
//           _log = "SUCCESS!";
//         } else if (ReturnCode.isCancel(returnCode)) {
//           _log = "CANCELED! 😵‍💫";
//         } else {
//           // ERROR
//           _log = "ERRORED! 🤒";
//         }
//         session.getOutput().then((fullOutput) =>
//           setState(() => _log = "$_log\n$fullOutput")
//         );
//     }).then((_) =>
//       _videoPlayer.setDataSource('file://$_pipe', autoPlay: true)
//     );
// });


class DeepSeaRadio extends StatelessWidget {
  const DeepSeaRadio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Deep Sea Radio",
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _log = "😀";
  String? _pipe;
  late VideoPlayerController _videoController;
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();
    // _player.setSource(AssetSource("audios/nigga.aac")).then((_) =>
    //   _player.resume()
    // );

    _videoController = VideoPlayerController.asset('assets/videos/test.mp4')
      ..initialize().then(
          // Ensure the first frame is shown after the video is initialized,
          // even before the play button has been pressed.
          (_) => setState(() {}));
    //   ..setLooping(true);
    // ..play();
  }

  void _thysCommand() {
    // _videoController.value.isPlaying
    // ? _videoController.pause()
    // : _videoController.play();

    // _player.resume();

    if (_pipe != null) {
      FFmpegKitConfig.closeFFmpegPipe(_pipe!);
      _pipe = null;
    }

    FFmpegKitConfig.registerNewFFmpegPipe().then((pipe) {
      _pipe = pipe;
      FFmpegKit.execute(// ADD -y option as the leftmost flag!!!
              // '-y -f lavfi -i anoisesrc=color=brown:amplitude=0.4 -filter "lowpass=f=400" -f flac $pipe' // matroska
              '-y -f lavfi -i anoisesrc=color=brown:amplitude=0.4 -filter "lowpass=f=400" -f flv -ar 44100 -ab 64000 -ac 1 $pipe')
          .then((session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          _log = "SUCCESS!";
        } else if (ReturnCode.isCancel(returnCode)) {
          _log = "CANCELED! 😵‍💫";
        } else {
          // ERROR
          _log = "ERRORED! 🤒";
        }
        session
            .getOutput()
            .then((fullOutput) => setState(() => _log = "$_log\n$fullOutput"));
      });
    });
  }

  void _niggasCommand() {
    // if (_pipe != null) {
    //   _player.setSource(DeviceFileSource(_pipe!)).then((_) =>
    //     _player.resume()
    //   );
    // }

    _videoController = VideoPlayerController.file(File(_pipe!))
      ..initialize().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.inversePrimary,
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _videoController.value.isInitialized
              ? Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController)))
              : Container(),
          FilledButton(
            onPressed: _thysCommand,
            child: Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Container(
                //     padding: EdgeInsets.only(right: 5.0),
                //     child: Icon(_videoController.value.isInitialized && _videoController.value.isPlaying
                //         ? Icons.pause
                //         : Icons.play_arrow)),
                Text("Act upon thy's honered command"),
              ],
            ),
          ),
          FilledButton(
            onPressed: _niggasCommand,
            child: Text("Command the niggas"),
          ),
          Expanded(
              child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(
              _log,
              style: themeData.textTheme.headlineSmall!
                  .merge(TextStyle(color: themeData.colorScheme.primary)),
            ),
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_pipe != null) {
      FFmpegKitConfig.closeFFmpegPipe(_pipe!);
      _pipe = null;
    }
    _player.dispose();
    _videoController.dispose();

    super.dispose();
  }
}
