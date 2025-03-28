
#!/bin/sh

APP=dropbox
mkdir tmp
cd ./tmp
wget -q https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
chmod a+x ./appimagetool

DL=$(echo "https://aur.andontie.net/x86_64/$(curl -Ls https://aur.andontie.net/x86_64/ | grep dropbox | head -1 | grep -o -P '(?<=href=").*(?=">dropbox)')")
VERSION=$(echo $DL | grep -o -P '(?<=dropbox-).*(?=-x86)')
wget $DL
tar xf ./*.tar.zst
mkdir $APP.AppDir
mv ./opt ./$APP.AppDir
mv ./usr ./$APP.AppDir
cp ./$APP.AppDir/usr/share/applications/*desktop ./$APP.AppDir
cp ./$APP.AppDir/usr/share/pixmaps/*svg ./$APP.AppDir

cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh 
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}/usr/lib/systemd/system/:${HERE}/usr/lib/systemd/user/:${HERE}/opt/dropbox/:${HERE}/opt/dropbox/resources/:${HERE}/opt/dropbox/plugins/platforms/:${HERE}/opt/dropbox/images/hicolor/16x16/status/:${HERE}/opt/dropbox/images/emblems/${PATH:+:$PATH}"
export LD_LIBRARY_PATH="${HERE}/opt/dropbox/:${HERE}/opt/dropbox/plugins/platforms/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="${HERE}/usr/share/${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
exec "${HERE}"/opt/dropbox/dropbox "$@"
EOF
chmod a+x ./$APP.AppDir/AppRun

ARCH=x86_64 ./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 20 \
	-u "gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|Dropbox-appimage|continuous|*x86_64.AppImage.zsync" \
	./"$APP".AppDir Dropbox-"$VERSION"-x86_64.AppImage || exit 1

cd .. && mv ./tmp/*AppImage* ./
