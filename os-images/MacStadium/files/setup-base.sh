#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')
echo "====> OSX Version: ${OSX_VERS}"

if [ "$OSX_VERS" -eq 13 ]; then
    #DMGURL="https://artifactory.saltstack.net/artifactory/macos-files/Command_Line_Tools_macOS_10.13_for_Xcode_10.1.dmg"
    #TOOLS=clitools.dmg
    #curl -u$ARTIFACTORY_USERNAME:$ARTIFACTORY_PASSWORD "$DMGURL" -o "$TOOLS"
    #TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
    #hdiutil attach "$TOOLS" -mountpoint "$TMPMOUNT"
    #sudo installer -allowUntrusted -pkg "$(find $TMPMOUNT -name '*.pkg')" -target /
    #hdiutil detach "$TMPMOUNT"
    #rm -rf "$TMPMOUNT"
    #rm "$TOOLS"
    /usr/bin/sudo /usr/bin/xcode-select --print-path
    /usr/bin/sudo /usr/bin/touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    #/usr/bin/sudo /usr/sbin/softwareupdate -i Command\ Line\ Tools\ (macOS\ Highsiera\ version\ 10.13)\ for\ Xcode-10.1
    /usr/bin/sudo /usr/sbin/softwareupdate -i Command\ Line\ Tools\ \(macOS\ High\ Sierra\ version\ 10.13\)\ for\ Xcode-10.1
    /usr/bin/sudo /bin/rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    /usr/bin/sudo /usr/bin/xcode-select --print-path
    /usr/bin/sudo /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
fi

echo "====> Installing homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
