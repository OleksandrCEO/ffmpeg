#!/bin/bash
# Builds the macOS LGPL-2.1 FFmpeg published here, natively on a Mac of that architecture (.github/workflows/macos.yml
# runs it on GitHub's runners). The same FFmpeg source and libraries as build.sh, but each library is compiled here
# from its release source, pinned by SHA-256 below, and linked in statically; Apple's VideoToolbox and AudioToolbox
# take the place of the NVIDIA, AMD, Intel and VAAPI hardware codecs. Nothing is autodetected.
#
#   ./build-macos.sh arm64|x86_64   → out/ffmpeg-<version>-macos-<arch>-lgpl-shared.tar.xz
#
# Needs Xcode's command line tools, meson, ninja, cmake, pkg-config, nasm (x86_64) and the network for the sources.
set -euo pipefail
cd "$(dirname "$0")"

VERSION=8.1.3
ARCH="${1:?usage: build-macos.sh arm64|x86_64}"
[[ $ARCH == arm64 || $ARCH == x86_64 ]] || { echo "unknown arch $ARCH" >&2; exit 1; }
[[ $(uname -m) == "$ARCH" ]] || { echo "build $ARCH on an $ARCH Mac" >&2; exit 1; }
# Electron, which runs it, needs macOS 12 too
export MACOSX_DEPLOYMENT_TARGET=12.0

NAME="ffmpeg-$VERSION-macos-$ARCH-lgpl-shared"
WORK="$PWD/work/macos-$ARCH"
SRC="$WORK/src"
DEPS="$WORK/deps"
rm -rf "$WORK" && mkdir -p "$SRC" "$DEPS" out
# Only the libraries built here, never Homebrew's
export PKG_CONFIG_LIBDIR="$DEPS/lib/pkgconfig" PKG_CONFIG_PATH=
JOBS=$(sysctl -n hw.ncpu)

# Downloads a release source, checks it and unpacks it into $SRC/<dir>
fetch() { # dir sha256 url
	curl -fsSL --retry 3 -o "$SRC/$1.tar" "$3"
	echo "$2  $SRC/$1.tar" | shasum -a 256 -c -
	mkdir "$SRC/$1" && tar -xf "$SRC/$1.tar" -C "$SRC/$1" --strip-components=1
}
fetch ffmpeg 7138d28c96d9d3e3af4ee3d8cad72741f8ffb40da90c1112235dea3ecd3178a3 https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.xz
fetch zlib d7a0654783a4da529d1bb793b7ad9c3318020af77667bcae35f95d0e42a792f3 https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.xz
fetch freetype dc49de6b01a266eef4876a4dd34d9842c475d3e28ff2eff63bd2fb760ab56261 https://github.com/freetype/freetype/archive/refs/tags/VER-2-14-3.tar.gz
fetch harfbuzz b7132e148358a45185c9feafd049dbaf243649d3c44414b3534d9c95d18592b9 https://github.com/harfbuzz/harfbuzz/releases/download/14.5.0/harfbuzz-14.5.0.tar.xz
fetch dav1d a1d5b63d2d38ec9bd03acf643caa51fa22edd1e89c5a109c4807717216bbec07 https://github.com/videolan/dav1d/archive/refs/tags/1.5.4.tar.gz
fetch opus 6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1 https://downloads.xiph.org/releases/opus/opus-1.6.1.tar.gz
fetch svt-av1 d9cb8d5fccbed565d038ae304cb00c5610f1f62388868102ca22132e7844921b https://github.com/AOMediaCodec/SVT-AV1/archive/refs/tags/v4.2.0.tar.gz
fetch openh264 558544ad358283a7ab2930d69a9ceddf913f4a51ee9bf1bfb9e377322af81a69 https://github.com/cisco/openh264/archive/refs/tags/v2.6.0.tar.gz

meson_build() { # dir, options
	local dir="$1"; shift
	meson setup "$SRC/$dir/build" "$SRC/$dir" --prefix="$DEPS" --libdir=lib --buildtype=release \
		--default-library=static --wrap-mode=nodownload "$@"
	meson install -C "$SRC/$dir/build"
}

set -x
(cd "$SRC/zlib" && ./configure --static --prefix="$DEPS" && make -j"$JOBS" && make install)
meson_build freetype -Dbrotli=disabled -Dbzip2=disabled -Dharfbuzz=disabled -Dpng=disabled -Dzlib=disabled \
	-Dtests=disabled
meson_build harfbuzz -Dauto_features=disabled -Dfreetype=enabled -Dtests=disabled -Dutilities=disabled \
	-Dsubset=disabled -Draster=disabled -Dvector=disabled
meson_build dav1d -Denable_tools=false -Denable_tests=false
meson_build opus -Dtests=disabled -Ddocs=disabled -Dextra-programs=disabled
meson_build openh264 -Dtests=disabled
cmake -S "$SRC/svt-av1" -B "$SRC/svt-av1/build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$DEPS" \
	-DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=OFF -DBUILD_APPS=OFF -DBUILD_TESTING=OFF -DSVT_AV1_LTO=OFF
cmake --build "$SRC/svt-av1/build" --target install

# The programs find FFmpeg's libraries beside them: lib/ next to bin/. HarfBuzz and OpenH264 are C++ (Apple's libc++).
(cd "$SRC/ffmpeg" && ./configure --prefix="$WORK/prefix" --pkg-config-flags=--static \
	--disable-debug --enable-shared --disable-static --disable-doc --disable-ffplay \
	--disable-autodetect --enable-zlib \
	--enable-libfreetype --enable-libharfbuzz \
	--enable-libdav1d --enable-libopus --enable-libsvtav1 --enable-libopenh264 \
	--enable-videotoolbox --enable-audiotoolbox \
	--extra-cflags="-I$DEPS/include" --extra-ldflags="-L$DEPS/lib" --extra-libs=-lc++ \
	--install-name-dir=@rpath --extra-ldexeflags=-Wl,-rpath,@loader_path/../lib \
	|| { tail -50 ffbuild/config.log; exit 1; })
make -C "$SRC/ffmpeg" -j"$JOBS"
make -C "$SRC/ffmpeg" install
set +x

mkdir -p "$WORK/$NAME"
cp -R "$WORK/prefix/bin" "$WORK/prefix/lib" "$WORK/prefix/include" "$WORK/$NAME/"
rm -rf "$WORK/$NAME/lib/pkgconfig"
cp "$SRC/ffmpeg/COPYING.LGPLv2.1" "$WORK/$NAME/LICENSE.txt"
cp -R licenses "$WORK/$NAME/licenses"
# No AppleDouble ._ files in the archive
COPYFILE_DISABLE=1 tar -C "$WORK" -cJf "out/$NAME.tar.xz" "$NAME"
echo "out/$NAME.tar.xz"
