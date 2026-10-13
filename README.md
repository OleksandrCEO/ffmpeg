# FFmpeg builds

LGPL builds of [FFmpeg](https://ffmpeg.org) that applications download at run time, with everything needed to know
what is in them and to build them again: FFmpeg's release source, the build script, and the licences of the libraries
built in.

## Releases

| Release | FFmpeg | Platforms | Licence |
|---|---|---|---|
| `8.1.3-lgpl` | 8.1.3 (release tarball) | linux64, win64 | LGPL-2.1-or-later |

Each release holds the builds (one archive per platform), `ffmpeg-<version>.tar.xz` (the source, as ffmpeg.org
publishes it) and `SHA256SUMS`.

## What is in a build

Only what a video editor's render needs, every library named (`build.sh`, `--disable-autodetect`):
FFmpeg's own decoders, encoders and filters; dav1d, Opus, SVT-AV1, OpenH264; FreeType and HarfBuzz for `drawtext`;
zlib; NVIDIA (NVENC/NVDEC/CUDA), AMD (AMF), Intel (oneVPL/QSV) hardware codecs, VAAPI on Linux, D3D11VA, DXVA2 and
Media Foundation on Windows. No GPL or non-free parts (no x264, no x265), no `--enable-version3`.

`ffmpeg` and `ffprobe` are in `bin/`, FFmpeg's shared libraries in `lib/` (Linux) or `bin/` (Windows); the
third-party libraries are linked into them statically — all under permissive licences, their texts in `licenses/`.

## Building

`./build.sh linux64` or `./build.sh win64` with docker and `ffmpeg-8.1.3.tar.xz` from https://ffmpeg.org/releases/
beside it: it compiles FFmpeg in BtbN's toolchain image ([BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds),
pinned by digest), which holds those libraries prebuilt.

## Licence

FFmpeg is licensed under the GNU Lesser General Public License version 2.1 or later — see [`LICENSE`](LICENSE) and the
`LICENSE.txt` in each archive; the libraries built in are under their own licences (`licenses/`). The builds are
separate programs, run as their own processes, not modified and not renamed. "This software uses code of
[FFmpeg](https://ffmpeg.org) licensed under the [LGPLv2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)
and its source can be downloaded from this repository's releases."

FFmpeg is a trademark of Fabrice Bellard, originator of the FFmpeg project. Patent licensing of the codecs is not
granted by FFmpeg or by this repository.

