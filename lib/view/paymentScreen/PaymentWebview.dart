import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:valuemate/view/paymentScreen/payment_response.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final VoidCallback? onGuestOrdersDetected;

  const WebViewPage({
    super.key,
    required this.url,
    this.onGuestOrdersDetected,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            setState(() => _isLoading = false);

            try {
              final jsResult = await controller.runJavaScriptReturningResult(
                  'document.body.innerText');

              var rawText = jsResult.toString();

              // Remove extra quotes if present (e.g., from JS string result)
              if (rawText.startsWith('"') && rawText.endsWith('"')) {
                rawText = rawText.substring(1, rawText.length - 1);
              }

              // Replace escaped quotes inside the string
              rawText = rawText.replaceAll(r'\"', '"');

              print("Manzar $rawText");

              final data = json.decode(rawText);

              if (data['status'] == true) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentSuccessScreen(),));
                return;
              }
              else{
                 Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentFailedScreen(),));
                 return;
              }
            } catch (e) {
              debugPrint('JavaScript evaluation error: $e');
            }

            // Fallback to URL logic
            // if (url.contains('/success') || url.contains('/cancel')) {
            //   Navigator.of(context).pop(); // Handle cancel/success
            // }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // print("ye bhi kam kar raha hai");
            // if (url.contains('/cancel')) {
            //   Navigator.of(context).pop(); // Early cancel detection
            //   return NavigationDecision.prevent;
            // }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
          : WebViewWidget(controller: controller),
    );
  }
}
