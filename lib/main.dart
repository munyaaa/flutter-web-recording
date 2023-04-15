import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late html.MediaRecorder _recorder;
  late html.VideoElement _result;
  late html.CanvasElement _canvas;
  late html.CanvasRenderingContext2D _context;

  @override
  void initState() {
    super.initState();
    _canvas = html.CanvasElement()
      ..width = 300
      ..height = 200;
    _context = _canvas.context2D;
    _context.fillStyle = "grey";
    _context.fillRect(0, 0, 300, 200);

    _result = html.VideoElement()
      ..autoplay = false
      ..muted = false
      ..width = html.window.innerWidth!
      ..height = html.window.innerHeight!
      ..controls = true;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('result', (int _) => _result);

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('canvas', (int _) => _canvas);
  }

  void startRecording(html.MediaStream stream) {
    _recorder = html.MediaRecorder(stream);
    _recorder.start();

    _drawPath();

    html.Blob blob = html.Blob([]);

    _recorder.addEventListener('dataavailable', (event) {
      blob = js.JsObject.fromBrowserObject(event)['data'];
    }, true);

    _recorder.addEventListener('stop', (event) {
      final url = html.Url.createObjectUrl(blob);
      _result.src = url;
      _download(url);

      stream.getTracks().forEach((track) {
        if (track.readyState == 'live') {
          track.stop();
        }
      });
    });
  }

  Future<html.MediaStream?> _getAudioPermission() async {
    final html.MediaStream? stream = await html.window.navigator.mediaDevices
        ?.getUserMedia({'video': false, 'audio': true});
    return stream;
  }

  html.MediaStream _getCombinedStreams({
    required html.MediaStream canvasStream,
    required html.MediaStream? audioStream,
  }) {
    final html.MediaStream combinedStream = new html.MediaStream();
    canvasStream.getTracks().forEach((track) {
      combinedStream.addTrack(track);
    });
    audioStream?.getAudioTracks().forEach((track) {
      combinedStream.addTrack(track);
    });

    return combinedStream;
  }

  void stopRecording() => _recorder.stop();

  void _download(String url) {
    html.AnchorElement(href: url)
      ..setAttribute('download', 'recorded-video.webm')
      ..click();
  }

  void _drawPath() {
    _canvas.onMouseDown.listen((event) {
      _context.beginPath();
      _context.moveTo(event.offset.x, event.offset.y);

      final mouseMoveListener = _canvas.onMouseMove.listen((event) {
        _context.lineTo(event.offset.x, event.offset.y);
        _context.stroke();
      });

      _canvas.onMouseUp.listen((event) {
        mouseMoveListener.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Recording',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Web Recording'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Recording Preview',
                style: Theme.of(context).textTheme.headline6,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                width: 300,
                height: 200,
                color: Colors.purple,
                child: HtmlElementView(
                  key: UniqueKey(),
                  viewType: 'canvas',
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                margin: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        html.MediaStream? audioStream =
                            await _getAudioPermission();
                        html.MediaStream stream = _getCombinedStreams(
                          canvasStream: _canvas.captureStream(),
                          audioStream: audioStream,
                        );
                        startRecording(stream);
                      },
                      child: Text('Start Recording'),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    ElevatedButton(
                      onPressed: () => stopRecording(),
                      child: Text('Stop Recording'),
                    ),
                  ],
                ),
              ),
              Text(
                'Recording Result',
                style: Theme.of(context).textTheme.headline6,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                width: 300,
                height: 200,
                color: Colors.blue,
                child: HtmlElementView(
                  key: UniqueKey(),
                  viewType: 'result',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
