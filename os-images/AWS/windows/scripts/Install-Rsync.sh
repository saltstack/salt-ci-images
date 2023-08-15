# From https://gist.github.com/hisplan/ee54e48f17b92c6609ac16f83073dde6?permalink_comment_id=3462247#gistcomment-3462247

RSYNC_VERSION="3.2.7-2"
ARCHIVE_FILENAME="rsync-${RSYNC_VERSION}-x86_64.pkg.tar.zst"

# Make a temporary directory
tempDir=$(mktemp -d)
# go into that dir
pushd "$tempDir"
# download the file using its original name
curl -O http://www2.futureware.at/~nickoe/msys2-mirror/msys/x86_64/${ARCHIVE_FILENAME}
# cd to Git Bash root directory (which is your Git directory, so you don't need to look it up or assume it's in %programfiles%)
cd /
# extract the files to their proper places (all of them, not just rsync.exe)
tar -xf "${tempDir}/${ARCHIVE_FILENAME}"
# get back to your original directory
popd
# clean up that temp directory and the downloaded .tar.xz file
rm -rf "$tempDir"
# see that rsync is in the path now
which rsync
