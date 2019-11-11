#!/bin/bash

OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')

if [ "$OSX_VERS" -eq 13 ]; then
    DMGURL="https://artifactory.saltstack.net/artifactory/macos-files/Command_Line_Tools_macOS_10.13_for_Xcode_10.1.dmg"
    TOOLS=clitools.dmg
    curl -u$ARTIFACTORY_USERNAME:$ARTIFACTORY_PASSWORD "$DMGURL" -o "$TOOLS"
    TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
    hdiutil attach "$TOOLS" -mountpoint "$TMPMOUNT"
    sudo installer -pkg "$(find $TMPMOUNT -name '*.pkg')" -target /
    hdiutil detach "$TMPMOUNT"
    rm -rf "$TMPMOUNT"
    rm "$TOOLS"
fi

echo "==> Installing homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
