# FFmpeg builds

Pinned LGPL builds of [FFmpeg](https://ffmpeg.org) that applications download at run time, with the exact source
they were built from. The builds are [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds) "lgpl-shared"
builds, mirrored here unchanged so that a version stays available once its upstream release is pruned.

## Releases

Each release holds, for one FFmpeg version:

- the builds, one archive per platform, exactly as BtbN published them (their `SHA256SUMS` line is the check);
- `ffmpeg-<version>-source.tar.gz` — the FFmpeg source at the commit the builds report (`ffmpeg -version`);
- `btbn-ffmpeg-builds-<commit>.tar.gz` — BtbN's build scripts at the commit that made them: the configure line, the
  libraries built in and their versions;
- `SHA256SUMS`.

| Release | FFmpeg | Platforms | Built |
|---|---|---|---|
| `n8.1.3-18-g46d899d7a0` | n8.1.3-18-g46d899d7a0 (release/8.1 branch) | linux64, win64 | BtbN autobuild 2026-10-13 |

## Licence

FFmpeg is licensed under the GNU Lesser General Public License; these builds are configured with `--enable-version3`
and without GPL or non-free parts (no `--enable-gpl`, no `--enable-nonfree`: no x264, no x265), so they are
**LGPL-3.0-or-later** — see [`LICENSE`](LICENSE) and the `LICENSE.txt` in each archive. The libraries built in carry
their own licences, listed by BtbN's scripts.

These builds are separate programs, run as their own processes; they are not modified, and they are not renamed.
"This software uses code of [FFmpeg](https://ffmpeg.org) licensed under the
[LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.html) and its source can be downloaded from this repository's releases."

FFmpeg is a trademark of Fabrice Bellard, originator of the FFmpeg project. Patent licensing of the codecs is not
granted by FFmpeg or by this repository.
