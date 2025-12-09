import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

void showProfile({
  required BuildContext context,
  required Profile profile,
  bool noProfileWarning = false,
}) {
  final url = Uri(
    path: '/user/${profile.userId}',
    queryParameters: <String, dynamic>{
      'display_name': profile.displayName,
      'avatar_uri': profile.avatarUrl?.toString(),
      'no_profile_warning': noProfileWarning.toString(),
    },
  ).toString();
  context.push(url);
}
