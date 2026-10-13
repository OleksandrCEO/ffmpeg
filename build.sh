#!/bin/bash
# Builds the LGPL-2.1 FFmpeg published here: FFmpeg's release source with only the libraries an editor's render needs,
# compiled in BtbN's toolchain image (github.com/BtbN/FFmpeg-Builds) pinned by digest. Nothing is autodetected: every
# library linked is named below, all of them permissive (BSD, MIT, FTL, zlib), so the build is LGPL-2.1-or-later.
#
#   ./build.sh linux64|win64      → out/ffmpeg-<version>-<target>-lgpl-shared.(tar.xz|zip)
#
# Needs docker and ffmpeg-<version>.tar.xz from https://ffmpeg.org/releases/ beside this script.
set -euo pipefail
cd "$(dirname "$0")"

VERSION=8.1.3
SOURCE_SHA256=7138d28c96d9d3e3af4ee3d8cad72741f8ffb40da90c1112235dea3ecd3178a3
TARGET="${1:?usage: build.sh linux64|win64}"
case "$TARGET" in
linux64) IMAGE=ghcr.io/btbn/ffmpeg-builds/linux64-lgpl-shared-8.1@sha256:20fe0c2ed912ceca14c915ad4e9b58ab688a68a82dde7c5f6a4c0f02d2cf4492 ;;
win64) IMAGE=ghcr.io/btbn/ffmpeg-builds/win64-lgpl-shared-8.1@sha256:d77c499dec437b09fcde2259254a265074c85ec04f43e0d669851703c54ef25e ;;
*) echo "unknown target $TARGET" >&2; exit 1 ;;
esac

echo "$SOURCE_SHA256  ffmpeg-$VERSION.tar.xz" | sha256sum -c -
NAME="ffmpeg-$VERSION-$TARGET-lgpl-shared"
WORK="work/$TARGET"
rm -rf "$WORK" && mkdir -p "$WORK" out
tar -xf "ffmpeg-$VERSION.tar.xz" -C "$WORK"

# Hardware encoders and decoders (NVIDIA, AMD, Intel, VAAPI; Windows' own) load the vendor's driver at run time
if [[ $TARGET == win* ]]; then
	PLATFORM="--enable-d3d11va --enable-dxva2 --enable-mediafoundation"
	RPATH=''
else
	PLATFORM="--enable-vaapi --enable-libdrm"
	# The programs find their libraries beside them: lib/ next to bin/ (as BtbN's build.sh writes it)
	RPATH=' -Wl,-rpath,\\\$\$ORIGIN/../lib'
fi

docker run --rm -i -u "$(id -u):$(id -g)" -v "$PWD/$WORK":/build -w "/build/ffmpeg-$VERSION" "$IMAGE" bash -s <<EOF
set -xe
./configure --prefix=/build/prefix --pkg-config-flags=--static \$FFBUILD_TARGET_FLAGS \
	--disable-debug --enable-shared --disable-static --disable-doc --disable-ffplay \
	--disable-autodetect --enable-zlib \
	--enable-libfreetype --enable-libharfbuzz \
	--enable-libdav1d --enable-libopus --enable-libsvtav1 --enable-libopenh264 \
	--enable-ffnvcodec --enable-cuda-llvm --enable-nvenc --enable-nvdec --enable-cuvid --enable-amf --enable-libvpl \
	$PLATFORM \
	--extra-ldflags="\$FF_LDFLAGS" --extra-libs="\$FF_LIBS" \
	--extra-ldexeflags='$RPATH' \
	--cc="\$CC" --cxx="\$CXX" --ar="\$AR" --ranlib="\$RANLIB" --nm="\$NM" \
	|| { tail -50 ffbuild/config.log; exit 1; }
make -j\$(nproc)
make install
EOF

mkdir -p "$WORK/$NAME"
cp -r "$WORK/prefix/bin" "$WORK/prefix/include" "$WORK/$NAME/"
[[ -d "$WORK/prefix/lib" ]] && cp -r "$WORK/prefix/lib" "$WORK/$NAME/"
rm -rf "$WORK/$NAME/lib/pkgconfig"
cp "$WORK/ffmpeg-$VERSION/COPYING.LGPLv2.1" "$WORK/$NAME/LICENSE.txt"
cp -r licenses "$WORK/$NAME/licenses"
if [[ $TARGET == win* ]]; then
	rm -f "out/$NAME.zip"
	docker run --rm -u "$(id -u):$(id -g)" -v "$PWD/$WORK":/w -v "$PWD/out":/out -w /w "$IMAGE" zip -qr9 "/out/$NAME.zip" "$NAME"
else
	tar -C "$WORK" -cJf "out/$NAME.tar.xz" "$NAME"
fi
echo "out/$NAME"
