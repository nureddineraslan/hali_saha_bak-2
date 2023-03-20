import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SampleWebview extends StatefulWidget {
  const SampleWebview({Key? key}) : super(key: key);

  @override
  State<SampleWebview> createState() => _SampleWebviewState();
}

class _SampleWebviewState extends State<SampleWebview> {
  String link = 'https://www.paytr.com/link/OqCRCPT';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ÖDEME')),
      body: WebView(
        initialUrl: link,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
