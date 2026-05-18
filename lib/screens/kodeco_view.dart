import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KodecoView extends StatefulWidget {
  const KodecoView({super.key});

  @override
  State<KodecoView> createState() => _KodecoViewState();
}

class _KodecoViewState extends State<KodecoView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.kodeco.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kodeco')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
