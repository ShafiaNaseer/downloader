// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final TextEditingController _urlController = TextEditingController();
//   bool downloading = false;
//   double progress = 0.0;
//
//   void updateProgress(double value) {
//     setState(() {
//       progress = value;
//       print("progress: $progress");
//
//     });
//   }
//
//   Future<void> downloadYouTubeVideo(String videoUrl) async {
//     var youtube = YoutubeExplode();
//
//     try {
//       setState(() {
//         downloading = true;
//       });
//       var video = await youtube.videos.get(videoUrl);
//       var manifest = await youtube.videos.streamsClient.getManifest(video.id.value);
//       var streamInfo = manifest.muxed.withHighestBitrate();
//       var stream = youtube.videos.streamsClient.get(streamInfo);
//       var file = File('/sdcard/Download/${video.id.value}.mp4');
//       var output = file.openWrite();
//       await stream.pipe(output);
//       await output.close();
//       setState(() {
//         downloading = false;
//       });
//       print('Video downloaded successfully');
//       Fluttertoast.showToast(
//           msg: "Video downloaded successfully",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.CENTER,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//           fontSize: 16.0
//       );
//     } catch (e) {
//       print('Error occurred during video download: $e');
//       Fluttertoast.showToast(
//           msg: "Error occurred during video download: $e",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.CENTER,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//           fontSize: 16.0
//       );
//       setState(() {
//         downloading = false;
//       });
//     } finally {
//       youtube.close();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('YouTube Downloader'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _urlController,
//               decoration: InputDecoration(
//                 labelText: 'Paste Video URL',
//               ),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 final videoUrl = _urlController.text.trim();
//                 if (videoUrl.isNotEmpty) {
//                   downloadYouTubeVideo(videoUrl);
//                 }
//               },
//               child: Text('Download'),
//             ),
//             SizedBox(height: 16.0),
//            if (downloading)
//             CircularProgressIndicator(
//               value: progress,
//               strokeWidth: 8,
//               valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
//               backgroundColor: Colors.black38,
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
//
// }

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  bool downloading = false;
  double progress = 0.0;
  bool isPaused = false;
  bool isStopped = false;

  Completer<void> pauseCompleter = Completer<void>();

  void pauseDownload() {
    setState(() {
      isPaused = true;
    });
  }

  void resumeDownload() {
    setState(() {
      isPaused = false;
    });
    pauseCompleter.complete(); // Resume the download by completing the future.
  }

  void stopDownload() {
    setState(() {
      isStopped = true;
    });
    if (isPaused) {
      resumeDownload(); // Resume before stopping to ensure proper cleanup.
    }
  }

  void updateProgress(double value) {
    setState(() {
      progress = value;
      print("progress: $progress");
    });
  }

  Future<void> downloadYouTubeVideo(String videoUrl) async {
    var youtube = YoutubeExplode();

    try {
      setState(() {
        downloading = true;
        progress = 0.0;
      });

      var video = await youtube.videos.get(videoUrl);
      var manifest = await youtube.videos.streamsClient.getManifest(video.id.value);
      var streamInfo = manifest.muxed.withHighestBitrate();
      var stream = youtube.videos.streamsClient.get(streamInfo);
      var file = File('/sdcard/Download/${video.id.value}.mp4');
      var output = file.openWrite();
      if (isPaused) {
        // Pause the download until the user resumes.
        pauseCompleter = Completer<void>();
        await pauseCompleter.future;
      }
      int totalSize = streamInfo.size.totalBytes;
      int downloadedBytes = 0;

      await for (var data in stream) {
        if (isStopped) {
          break; // Stop the download if isStopped is true.
        }
        if (isPaused) {
          // Pause the download until the user resumes.
          pauseCompleter = Completer<void>();
          await pauseCompleter.future;
        }
        downloadedBytes += data.length;
        var currentProgress = downloadedBytes / totalSize;
        updateProgress(currentProgress);
        output.add(data);
        print('Data received: ${data.length} bytes');
        print('progress: $currentProgress ');
      }

      await output.close();

      setState(() {
        downloading = false;
        progress = 0.0;
      });

      print('Video downloaded successfully');
      Fluttertoast.showToast(
        msg: "Video downloaded successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error occurred during video download: $e');
      setState(() {
        downloading = false;
      });
      Fluttertoast.showToast(
        msg: "Error occurred during video download: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      youtube.close();
      isPaused = false;
      isStopped = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Downloader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Paste Video URL',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final videoUrl = _urlController.text.trim();
                if (videoUrl.isNotEmpty) {
                  downloadYouTubeVideo(videoUrl);
                }
              },
              child: Text('Download'),
            ),
            SizedBox(height: 16.0),
            if (downloading)
              CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 5.0,
                percent: progress,
                center: Text("${(progress * 100).toStringAsFixed(1)}%"),
                progressColor: Colors.green,
                backgroundColor: Colors.grey,
                animation: true,
                circularStrokeCap: CircularStrokeCap.round,
              ),


            ElevatedButton(
              onPressed: isPaused ? resumeDownload : pauseDownload,
              child: Text(isPaused ? 'Resume' : 'Pause'),
            ),
            ElevatedButton(
              onPressed: stopDownload,
              child: Text('Stop'),
            ),

          ],
        ),
      ),
    );
  }
}

