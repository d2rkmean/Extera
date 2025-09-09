import 'package:extera_next/pages/download_manager/download_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadManagerView extends StatelessWidget {
  final DownloadManagerController controller;
  const DownloadManagerView(this.controller, {super.key});

  static void showDownloads(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => DownloadManagerView(Provider.of<DownloadManagerController>(context)),
      barrierDismissible: true
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 256, maxWidth: 256),
        child: ListView.builder(
          itemCount: controller.downloads.length,
          itemBuilder: (context, index) {
            final download = controller.downloads[index];
            return ListTile(
              title: Text(download.name),
              subtitle: LinearProgressIndicator(
                value: download.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // "Cancel" button action can be added here
                },
                child: Text("Cancel"),
              ),
            );
          },
        ),
      ),
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 256),
        child: const Center(child: Text("Downloads", textAlign: TextAlign.center)),
      ),
    );
  }
}
