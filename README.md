# video_recorder_app

## Features
- Screen Recording canvas with audio recorded

## Flow
1. Run this code
2. Click Start Recording
3. Draw what do you want on canvas
4. Stop Recording if you finished

## Explaination
### Canvas
First, you'll need the canvas to draw.
You can't use the Flutter's `Canvas` because it doesn't have the `html.MediaStream` that we need to record.

```dart
late html.CanvasElement _canvas;

@override
void initState() {
  ...
  _canvas = html.CanvasElement()
    ..width = 300
    ..height = 200;
  ui.platformViewRegistry.registerViewFactory('canvas', (int _) => _canvas);
  ...
}

@override
Widget build() {
  ...
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
  ...
}
```

Then, call `_drawPath()` for canvas drawing functionality.
I put the `_drawPath()` when `startRecording()`, you can put this whereever you want if you need the canvas.

To `startRecording`,you need a `html.MediaStream`, you can simply use `_canvas.captureStream()` to get the canvas' stream.
If you just want to record the canvas, just use the canvas stream only. 

### Audio
It's same like camera, you need to ask for permission to use the audio.
How to get audio permission is also use `getUserMedia` from `MediaDevices`.
You can read the `_getAudioPermission()` function.

Now, to get the audio recorded, you'll need to combine the streams.
Here you have canvas & audio streams.
You can read the `_getCombinedStreams(...)` function.

Before start recording, you can simply combine it like this:
```dart
  html.MediaStream? audioStream = await _getAudioPermission();
  html.MediaStream stream = _getCombinedStreams(
    canvasStream: _canvas.captureStream(),
    audioStream: audioStream,
  );
```

### Download
You can read the `_download(...)` function.
Here, it get called when stop recording.

### It's a wrap!
Feel free to ask if you got questions!
