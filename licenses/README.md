# Libraries built into these FFmpeg builds

FFmpeg itself: LGPL-2.1-or-later (`LICENSE.txt`). Linked in statically, from BtbN's toolchain image (`build.sh` names
its digest), each under its own permissive licence — the texts are in this folder:

| Library | Version | Licence | File |
|---|---|---|---|
| dav1d (AV1 decoder) | 1.5.4 | BSD-2-Clause | `dav1d.txt` |
| FreeType (drawtext) | 2.14 (libtool 26.6.20) | FreeType License (FTL) | `freetype.txt` |
| HarfBuzz (drawtext) | 14.5.0 | MIT ("Old MIT") | `harfbuzz.txt` |
| Opus | from git | BSD-3-Clause | `opus.txt` |
| OpenH264 (built from source) | 2.6.0 | BSD-2-Clause | `openh264.txt` |
| SVT-AV1 | 4.2.0 | BSD-3-Clause-Clear, AOMedia Patent License 1.0 | `svt-av1.txt`, `svt-av1-patents.txt` |
| zlib | 1.3.2.1 | zlib | `zlib.txt` |
| libva, libva-drm (Linux) | 2.25.0 | MIT | `libva.txt` |
| libdrm (Linux) | 2.4.134 | MIT | `libdrm.txt` |
| libvpl (Intel QSV) | 2.17 | MIT | `libvpl.txt` |
| libX11, libXau, libxcb (Linux, if pulled in by libva) | 1.8.13, 1.0.12, 1.17.0 | MIT/X11 | `libx11.txt`, `libxau.txt`, `libxcb.txt` |
| AMF headers | from git | MIT | `amf.txt` |
| nv-codec-headers | from git | MIT | `nv-codec-headers.txt` |

GCC's runtime (libstdc++, libatomic, libgomp) is linked under the GCC Runtime Library Exception.
