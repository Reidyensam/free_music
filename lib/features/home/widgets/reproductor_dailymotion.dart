import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;

class ReproductorDailymotion extends StatefulWidget {
  final String videoId;
  const ReproductorDailymotion({super.key, required this.videoId});

  @override
  State<ReproductorDailymotion> createState() => _ReproductorDailymotionState();
}

class _ReproductorDailymotionState extends State<ReproductorDailymotion> {
  late final wf.WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = wf.WebViewController()
  ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
  ..loadRequest(Uri.parse(
      'https://www.dailymotion.com/embed/video/${widget.videoId}?autoplay=0&controls=1&mute=0'));
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: wf.WebViewWidget(controller: _controller),
    );
  }
}