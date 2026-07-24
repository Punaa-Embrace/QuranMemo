import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DonasiPaymentPage extends StatefulWidget {
  final String snapToken;
  final String orderId; // Dipertahankan agar tidak error di donasi_page.dart
  final String clientKey; // Client Key Midtrans

  const DonasiPaymentPage({
    super.key,
    required this.snapToken,
    required this.orderId,
    this.clientKey = 'SB-Mid-client-XXXXX', // GANTI DENGAN CLIENT KEY ANDA
  });

  @override
  State<DonasiPaymentPage> createState() => _DonasiPaymentPageState();
}

class _DonasiPaymentPageState extends State<DonasiPaymentPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupWebView(); // langsung setup, tidak perlu hit API lagi
  }

  void _setupWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
        onWebResourceError: (error) => setState(() {
          _errorMessage = 'Gagal memuat halaman pembayaran';
          _isLoading = false;
        }),
      ))
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: (msg) => _handleResult(msg.message),
      )
      ..loadHtmlString(
        _buildHtml(widget.snapToken, widget.clientKey),
        baseUrl: 'https://app.midtrans.com', // Wajib ada agar tidak terkena blokir CORS dari Midtrans
      );

    setState(() => _controller = controller);
  }

  String _buildHtml(String snapToken, String clientKey) => '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <script src="https://app.sandbox.midtrans.com/snap/snap.js"
        data-client-key="$clientKey"></script>
    </head>
    <body>
      <script>
        window.onload = function() {
          snap.pay('$snapToken', {
            onSuccess:  function() { PaymentChannel.postMessage('success'); },
            onPending:  function() { PaymentChannel.postMessage('pending'); },
            onError:    function() { PaymentChannel.postMessage('error'); },
            onClose:    function() { PaymentChannel.postMessage('close'); }
          });
        };
      </script>
    </body>
    </html>
  ''';

  void _handleResult(String status) {
    if (!mounted) return;
    Navigator.pop(context, status);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_controller != null && await _controller!.canGoBack()) {
          _controller!.goBack();
          return;
        }
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Batalkan Pembayaran?'),
            content: const Text('Kamu yakin ingin membatalkan pembayaran?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Lanjutkan'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Batalkan', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context, 'close');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, 'close'),
          ),
        ),
        body: Stack(
          children: [
            if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, 'close'),
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_controller != null)
              WebViewWidget(controller: _controller!),

            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}