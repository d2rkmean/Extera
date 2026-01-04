import 'package:extera_next/widgets/list_divider.dart';
import 'package:flutter/material.dart';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/config/setting_keys.dart';
import 'package:extera_next/config/themes.dart';
import 'package:extera_next/utils/platform_infos.dart';
import 'package:extera_next/widgets/layouts/max_width_body.dart';
import 'package:extera_next/widgets/matrix.dart';
import 'package:extera_next/widgets/settings_switch_list_tile.dart';
import 'settings_chat.dart';

class SettingsChatView extends StatelessWidget {
  final SettingsChatController controller;
  const SettingsChatView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(AppConfig.borderRadius);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).chat),
        automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
        centerTitle: FluffyThemes.isColumnMode(context),
      ),
      body: ListTileTheme(
        iconColor: theme.textTheme.bodyLarge!.color,
        child: MaxWidthBody(
          child: Padding(
            padding: const .symmetric(horizontal: 8),
            child: Column(
              children: [
                Material(
                  clipBehavior: .hardEdge,
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: borderRadius,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          L10n.of(context).chat,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).formattedMessages,
                        subtitle: L10n.of(context).formattedMessagesDescription,
                        onChanged: (b) => AppConfig.renderHtml = b,
                        storeKey: SettingKeys.renderHtml,
                        defaultValue: AppConfig.renderHtml,
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).hideMemberChangesInPublicChats,
                        subtitle: L10n.of(
                          context,
                        ).hideMemberChangesInPublicChatsBody,
                        onChanged: (b) =>
                            AppConfig.hideUnimportantStateEvents = b,
                        storeKey: SettingKeys.hideUnimportantStateEvents,
                        defaultValue: AppConfig.hideUnimportantStateEvents,
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).hideRedactedMessages,
                        subtitle: L10n.of(context).hideRedactedMessagesBody,
                        onChanged: (b) => AppConfig.hideRedactedEvents = b,
                        storeKey: SettingKeys.hideRedactedEvents,
                        defaultValue: AppConfig.hideRedactedEvents,
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(
                          context,
                        ).hideInvalidOrUnknownMessageFormats,
                        onChanged: (b) => AppConfig.hideUnknownEvents = b,
                        storeKey: SettingKeys.hideUnknownEvents,
                        defaultValue: AppConfig.hideUnknownEvents,
                      ),
                      const ListDivider(),
                      if (PlatformInfos.isMobile) ...[
                        SettingsSwitchListTile.adaptive(
                          title: L10n.of(context).autoplayImages,
                          onChanged: (b) => AppConfig.autoplayImages = b,
                          storeKey: SettingKeys.autoplayImages,
                          defaultValue: AppConfig.autoplayImages,
                        ),
                        const ListDivider(),
                      ],
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).sendOnEnter,
                        onChanged: (b) => AppConfig.sendOnEnter = b,
                        storeKey: SettingKeys.sendOnEnter,
                        defaultValue:
                            AppConfig.sendOnEnter ?? !PlatformInfos.isMobile,
                      ),
                      const ListDivider(),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).swipeRightToLeftToReply,
                        onChanged: (b) => AppConfig.swipeRightToLeftToReply = b,
                        storeKey: SettingKeys.swipeRightToLeftToReply,
                        defaultValue: AppConfig.swipeRightToLeftToReply,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Material(
                  clipBehavior: .hardEdge,
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: borderRadius,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          L10n.of(context).customEmojisAndStickers,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(L10n.of(context).customEmojisAndStickers),
                        subtitle: Text(
                          L10n.of(context).customEmojisAndStickersBody,
                        ),
                        onTap: () => context.go('/rooms/settings/chat/emotes'),
                        trailing: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(Icons.chevron_right_outlined),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  clipBehavior: .hardEdge,
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: borderRadius,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          L10n.of(context).calls,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SettingsSwitchListTile.adaptive(
                        title: L10n.of(context).experimentalVideoCalls,
                        onChanged: (b) {
                          AppConfig.experimentalVoip = b;
                          Matrix.of(context).createVoipPlugin();
                          return;
                        },
                        storeKey: SettingKeys.experimentalVoip,
                        defaultValue: AppConfig.experimentalVoip,
                      ),
                      const ListDivider(),
                      if (PlatformInfos.isDesktop) ...[
                        SettingsSwitchListTile.adaptive(
                          title: L10n.of(context).pushToTalkHotkey,
                          subtitle: L10n.of(
                            context,
                          ).pushToTalkHotkeyDescription,
                          onChanged: (b) => AppConfig.pushToTalkHotkey = b,
                          storeKey: SettingKeys.pushToTalkHotkey,
                          defaultValue: AppConfig.pushToTalkHotkey,
                        ),
                        const ListDivider(),
                      ],
                      ListTile(
                        title: Text(L10n.of(context).ringtone),
                        subtitle: Text(L10n.of(context).ringtoneDescription),
                        trailing: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(Icons.chevron_right_outlined),
                        ),
                        onTap: () => context.push('/rooms/settings/ringtone'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
