import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:school_app/config_service.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final TextEditingController _ipController = TextEditingController();

  String _fullUrl = '';
  bool _isLoading = true;

  static const int fixedPort = 5000;


  @override
  void initState() {
    super.initState();
    _loadSavedIP();
  }

  Future<void> _loadSavedIP() async {
    setState(() => _isLoading = true);

    final config = ConfigService();
    final savedUrl = await config.getLiveStreamUrl();

    if (savedUrl.isNotEmpty && savedUrl.contains("http://")) {
      try {
        final uri = Uri.parse(savedUrl);
        _ipController.text = uri.host;
      } catch (_) {}
    }

    _updateFullUrl();

    setState(() => _isLoading = false);
  }

  void _updateFullUrl() {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _fullUrl = "";
      return;
    }

    _fullUrl = "http://$ip:$fixedPort";
  }

  Future<void> _saveAndReload() async {
    _updateFullUrl();

    if (_fullUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('invalid_ip_address'.tr())),
      );
      return;
    }

    final config = ConfigService();
    await config.saveLiveStreamUrl(_fullUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("settings_saved_successfully".tr())),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('live_stream_title'.tr()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _saveAndReload,
            tooltip: 'reload_stream'.tr(),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),

      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              decoration: InputDecoration(
                labelText: "enter_camera_ip".tr(),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => _updateFullUrl(),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndReload,
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffD7FD8C), width: 2),
                  backgroundColor: const Color(0xff135FCB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xff135FCB).withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'save_reload'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffD7FD8C),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: _fullUrl.isEmpty
                    ? Text(
                  "stream_not_available".tr(),
                  style: const TextStyle(color: Colors.white),
                )
                    : Column(
                  children: [
                    Text(
                      "streaming_url".tr(args: [_fullUrl]),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),

                    Expanded(
                      child: MJPEGStreamScreen(
                        streamUrl: _fullUrl,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 300,
                        fit: BoxFit.cover,
                        showLiveIcon: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}