import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:fijkplayer/fijkplayer.dart';

// *****
// TODO: FFprobe native framerate for -re and -r flags to prevent frame dropping
// TODO: Automatically pausing after a few minutes... Maybe -re would fix it?
// TODO: Autostarting after load (probably have to check if enough data first)
// _startAudioGeneration().then((_) async {
//     // await Future.delayed(const Duration(milliseconds: 750));
//     // await _videoPlayer.start();
//     setState(() => _audioGenerationStarted = true);
// });
// TODO: Try audio players?
// import 'package:audioplayers/audioplayers.dart';
// import 'package:just_audio/just_audio.dart';
// *****

void main() {
  runApp(const DeepSeaRadio());
}

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
  String? _pipePath;
  FijkPlayer _videoPlayer = FijkPlayer();
  bool? _audioGenerationStarted;
  double _amplitude = 1.0;
  int _lowpass = 400;
  String _color = "brown";

  @override
  void initState() {
    super.initState();
  }

  Future<void> _reset() async {
    _log = "Reseting...";
    await _videoPlayer.reset();
    _videoPlayer.stop(); // DO NOT AWAIT STOP
    await FFmpegKit.cancel();
    await FFmpegKitConfig.closeFFmpegPipe('$_pipePath.aac');
    _pipePath = null;
  }

  Future<void> _startAudioGeneration() async {
    if (_pipePath != null) await _reset();

    _pipePath = await FFmpegKitConfig.registerNewFFmpegPipe();
    print("[PRINT] FFmpeg file path: $_pipePath.aac");
    FFmpegSession session = await FFmpegKit.executeAsync(
        '-y -f lavfi -i anoisesrc=color=$_color:amplitude=$_amplitude -filter "lowpass=f=$_lowpass" $_pipePath.aac');

    final returnCode = await session.getReturnCode();
    print("[PRINT] Return Code: $returnCode");
    if (ReturnCode.isSuccess(returnCode)) {
      _log = "SUCCESS!";
    } else if (ReturnCode.isCancel(returnCode)) {
      _log = "CANCELED! 😵‍💫";
    } else if (returnCode == null) {
      _log = "Running 💪";
    } else {
      _log = "ERRORED! 🤒";
    }

    String? fullOutput = await session.getOutput();
    _log = "$_log\n$fullOutput";
    await _videoPlayer.reset();
    _videoPlayer.stop(); // DO NOT AWAIT STOP
    await _videoPlayer.setDataSource('file://$_pipePath.aac');
    setState(() {});
  }

  void _load() {
    setState(() {
      _log = "Loading...";
      _audioGenerationStarted = false;
    });
    _startAudioGeneration().then((_) => _audioGenerationStarted = true);
  }

  void _start(String? decibels) {
    double? amplitude =
        decibels == null ? _amplitude : double.tryParse(decibels.trim());
    if (amplitude == null) return;
    _amplitude = amplitude;
    _load();
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
          Container(
            // padding: EdgeInsets.only(bottom: 30),
            alignment: Alignment.center,
            width: 320,
            height: 180,
            child: FijkView(player: _videoPlayer),
          ),
          FilledButton(
            onPressed:
                _audioGenerationStarted == null || _audioGenerationStarted!
                    ? _load
                    : null,
            child: Text("Load"),
          ),
          Row(children: <Widget>[
            Text(
              "Amplitude (0.0 to 1.0):",
              style: themeData.textTheme.headlineSmall!
                  .merge(TextStyle(color: themeData.colorScheme.primary)),
            ),
            Container(
              width: 100,
              padding: EdgeInsets.only(left: 20),
              child: TextField(
                keyboardType: TextInputType.number,
                onSubmitted: _start,
              ),
            ),
          ]),
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
    if (_pipePath != null) {
      FFmpegKitConfig.closeFFmpegPipe('$_pipePath.aac');
      _pipePath = null;
    }

    super.dispose();
    _videoPlayer.release();
  }
}
