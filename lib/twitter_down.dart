import 'package:flutter/material.dart';
import 'package:twitter_extractor/twitter_extractor.dart';

class TwitterDown extends StatefulWidget {
  const TwitterDown({Key? key}) : super(key: key);

  @override
  _TwitterDownState createState() => _TwitterDownState();
}

class _TwitterDownState extends State<TwitterDown> {
  Future<Twitter>? _twitterFuture;

  @override
  void initState() {
    super.initState();
    _twitterFuture = _getTwitterData();
  }

  Future<Twitter> _getTwitterData() async {
    return TwitterExtractor.extract(
        "https://twitter.com/waqas_amjaad/status/1680650390247821312?s=46&t=w9hQ0THWwfPU719X_dQOlg");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Twitter>(
        future: _twitterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading data'),
            );
          } else if (snapshot.hasData) {
            Twitter tweet = snapshot.data!;
            print(tweet.videos.first.text);
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Image.network(tweet.videos.first.thumb),
                  ),
                  Text(tweet.videos.first.text),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('No data found'),
            );
          }
        },
      ),
    );
  }
}
