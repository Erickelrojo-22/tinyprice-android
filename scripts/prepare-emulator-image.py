"""Download the official API 23 x86_64 test image with checksum verification.

No accounts or application credentials are read. Existing SDK packages are kept.
"""
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
import hashlib
import os
import time
import urllib.request
import zipfile

URL = "https://dl.google.com/android/repository/sys-img/android/x86_64-23_r10.zip"
SIZE = 365_009_313
SHA1 = "7cbc291483ca07dc67b71268c5f08a5755f50f51"
CHUNK = 8 * 1024 * 1024
cache = Path(os.environ["LOCALAPPDATA"]) / "TinyPriceTools" / "image-api23"
cache.mkdir(parents=True, exist_ok=True)


def download_part(index: int) -> Path:
    start, end = index * CHUNK, min((index + 1) * CHUNK, SIZE) - 1
    path = cache / f"{index:03d}.part"
    if path.exists() and path.stat().st_size == end - start + 1:
        return path
    for attempt in range(3):
        try:
            req = urllib.request.Request(URL, headers={"Range": f"bytes={start}-{end}"})
            with urllib.request.urlopen(req, timeout=60) as response:
                expected_range = f"bytes {start}-{end}/{SIZE}"
                if response.status != 206 or response.headers.get("Content-Range") != expected_range:
                    raise RuntimeError("Server did not honor the requested byte range")
                body = response.read()
            if len(body) != end - start + 1:
                raise RuntimeError("Incomplete download")
            path.write_bytes(body)
            return path
        except Exception:
            if attempt == 2:
                raise
            time.sleep(2)
    raise RuntimeError("Unreachable")


if __name__ == "__main__":
    parts = (SIZE + CHUNK - 1) // CHUNK
    with ThreadPoolExecutor(max_workers=10) as pool:
        pending = [pool.submit(download_part, index) for index in range(parts)]
        for count, future in enumerate(as_completed(pending), 1):
            future.result()
            print(f"Official emulator image: {count}/{parts} parts", flush=True)
    archive = cache / "x86_64-23_r10.zip"
    digest = hashlib.sha1()
    with archive.open("wb") as output:
        for index in range(parts):
            body = (cache / f"{index:03d}.part").read_bytes()
            digest.update(body)
            output.write(body)
    if digest.hexdigest() != SHA1:
        raise RuntimeError("Official image checksum did not match; nothing installed")
    sdk = Path(os.environ.get("ANDROID_HOME", str(Path(os.environ["LOCALAPPDATA"]) / "Android" / "Sdk")))
    destination = sdk / "system-images" / "android-23" / "default"
    destination.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as zipped:
        for member in zipped.infolist():
            (destination / member.filename).resolve().relative_to(destination.resolve())
        zipped.extractall(destination)
    print(f"Verified official system image installed: {destination}", flush=True)
