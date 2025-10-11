# FluffyChat AppImage

FluffyChat is provided as AppImage too. To Download, visit fluffychat.im.

## Building

- Ensure you install `appimagetool`

```shell
flutter build linux

# copy binaries to appimage dir
cp -r build/linux/{x64,arm64}/release/bundle appimage/Extera.AppDir
cd appimage

# prepare AppImage files
cp FluffyChat.desktop Extera.AppDir/
mkdir -p Extera.AppDir/usr/share/icons
cp ../assets/logo.svg Extera.AppDir/fluffychat.svg
cp AppRun Extera.AppDir

# build the AppImage
appimagetool Extera.AppDir
```
