import 'package:extera_next/config/themes.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/chat_thread/chat_threads.dart';
import 'package:extera_next/utils/platform_infos.dart';
import 'package:extera_next/widgets/avatar.dart';
import 'package:extera_next/widgets/layouts/max_width_body.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ChatThreadsView extends StatelessWidget {
  final ChatThreadsController controller;

  const ChatThreadsView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = FluffyThemes.isColumnMode(context) ? 8.0 : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: const Center(child: BackButton()),
        title: Text(L10n.of(context).chatThreads),
      ),
      body: MaxWidthBody(
        child: ListView.custom(
          padding: EdgeInsets.only(
            top: 16,
            bottom: 8,
            left: horizontalPadding,
            right: horizontalPadding,
          ),
          reverse: true,
          controller: controller.scrollController,
          keyboardDismissBehavior: PlatformInfos.isIOS
              ? ScrollViewKeyboardDismissBehavior.onDrag
              : ScrollViewKeyboardDismissBehavior.manual,
          childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int i) {
              if (i == (controller.threads?.length ?? 0) + 1) {
                if (controller.isLoadingThreads) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  );
                } else if (!(controller.room?.loadedAllThreads ?? false)) {
                  return Builder(
                    builder: (context) {
                      WidgetsBinding.instance
                          .addPostFrameCallback(controller.loadThreads);
                      return Center(
                        child: IconButton(
                          onPressed: controller.loadThreads,
                          icon: const Icon(Icons.refresh_outlined),
                        ),
                      );
                    },
                  );
                }
                i--;

                final thread = controller.threads![i];

                return AutoScrollTag(
                  key: ValueKey(thread.rootEvent.eventId),
                  index: i,
                  controller: controller.scrollController,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FutureBuilder<User?>(
                          future: thread.rootEvent.fetchSenderUser(),
                          builder: (context, snapshot) {
                            final user = snapshot.data ??
                                thread.rootEvent.senderFromMemoryOrFallback;

                            return Avatar(
                              mxContent: user.avatarUrl,
                              name: user.calcDisplayname(),
                              size: 48,
                            );
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(thread.rootEvent.senderFromMemoryOrFallback.calcDisplayname()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(thread.rootEvent.text),
                      ],
                    ),
                  ),
                );
              }
            },
            childCount: (controller.threads?.length ?? 0) + 1,
          ),
        ),
      ),
    );
  }
}
