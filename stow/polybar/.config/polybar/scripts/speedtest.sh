#!/usr/bin/env python3
import argparse
import os
import sys
import time
from pathlib import Path

try:
    import speedtest  # type: ignore
except Exception:
    sys.exit(0)

def get_formatted_speed(bits_per_sec: float, bytes_mode: bool = False) -> str:
    value = bits_per_sec
    unit = ""
    if value > 1024 ** 3:
        value /= 1024 ** 3; unit = "G"
    elif value > 1024 ** 2:
        value /= 1024 ** 2; unit = "M"
    elif value > 1024:
        value /= 1024; unit = "K"
    return f"{(value/8):.2f} {unit}iB/s" if bytes_mode else f"{value:.2f} {unit}ib/s"

def cache_path(upload: bool) -> Path:
    cache_dir = Path(os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache"))) / "polybar"
    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir / ("speedtest_upload.txt" if upload else "speedtest_download.txt")

def main() -> int:
    p = argparse.ArgumentParser(add_help=False)
    p.add_argument("--upload", action="store_true")
    p.add_argument("--bytes", action="store_true")
    p.add_argument("-h", "--help", action="store_true")
    a = p.parse_args()
    if a.help:
        print("Usage: speedtest.sh [--upload] [--bytes]")
        return 0

    ttl = int(os.environ.get("SPEEDTEST_TTL_SECS", "600"))
    c = cache_path(a.upload)

    try:
        if (time.time() - c.stat().st_mtime) <= ttl:
            print(c.read_text(encoding="utf-8", errors="ignore").strip())
            return 0
    except FileNotFoundError:
        pass
    except Exception:
        pass

    try:
        s = speedtest.Speedtest()
        if a.upload:
            s.upload(pre_allocate=False)
            out = "▲ " + get_formatted_speed(s.results.upload, a.bytes)
        else:
            s.download()
            out = "▼ " + get_formatted_speed(s.results.download, a.bytes)
    except Exception:
        return 0

    try:
        c.write_text(out + "\n", encoding="utf-8")
    except Exception:
        pass

    print(out)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
