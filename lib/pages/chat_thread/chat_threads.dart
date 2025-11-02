import 'package:extera_next/pages/chat_thread/chat_threads_view.dart';
import 'package:extera_next/widgets/matrix.dart';
import 'package:flutter/cupertino.dart';
import 'package:matrix/matrix.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ChatThreads extends StatefulWidget {
  final String roomId;

  const ChatThreads({
    super.key,
    required this.roomId,
  });

  @override
  ChatThreadsController createState() => ChatThreadsController();
}

class ChatThreadsController extends State<ChatThreads> {
  String get roomId => widget.roomId;
  Room? get room => Matrix.of(context).client.getRoomById(roomId);

  bool isLoadingThreads = false;

  final AutoScrollController scrollController = AutoScrollController();

  @override
  Widget build(BuildContext context) => ChatThreadsView(this);

  void loadThreads([dynamic _]) async {
    final room = Matrix.of(context).client.getRoomById(roomId);

    if (room == null) {
      return;
    }

    isLoadingThreads = true;

    await room.loadThreadsFromServer();

    isLoadingThreads = false;
  }

  List<Thread>? get threads => room?.threads.values.toList();

  Stream get onChanged => Matrix.of(context).client.onSync.stream.where(
        (e) =>
            (e.rooms?.join?.containsKey(roomId) ?? false) &&
            (e.rooms!.join![roomId]?.timeline?.events
                    ?.any((s) => s.type == EventTypes.Message && s.content['m.relates_to'] != null) ??
                false),
      );
}