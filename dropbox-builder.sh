#!/bin/sh

APP=dropbox
mkdir tmp
cd ./tmp
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage -O appimagetool
chmod a+x ./appimagetool

DL=$(echo "https://aur.andontie.net/x86_64/$(wget -q https://aur.andontie.net/x86_64/ -O - | grep dropbox | head -1 | grep -o -P '(?<=href=").*(?=">dropbox)')")
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

ARCH=x86_64 ./appimagetool -n ./$APP.AppDir
cd ..
mv ./tmp/*.AppImage ./Dropbox-$VERSION-x86_64.AppImage