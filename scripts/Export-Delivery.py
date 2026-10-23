"""Package project sources, compact evidence and the verified demo APK."""
from pathlib import Path
import hashlib
import zipfile

root = Path(__file__).resolve().parent.parent
dist = root / "dist"
dist.mkdir(exist_ok=True)
apk = dist / "TinyPrice-demo.apk"
if not apk.is_file():
    raise SystemExit("Build the demo APK before exporting the delivery.")

root_files = [
    ".gitignore", "README.md", "build.gradle.kts", "settings.gradle.kts",
    "gradle.properties", "gradlew", "gradlew.bat", "package.json", "package-lock.json",
    "app/build.gradle.kts",
]
source_directories = ["app/src", "gradle", "supabase", "scripts", "docs", ".agents"]
excluded_parts = {".git", ".gradle", ".kotlin", ".idea", "node_modules", "build", ".temp", ".branches", "tools", "__pycache__"}


def permitted(path: Path) -> bool:
    relative = path.relative_to(root)
    if any(part in excluded_parts for part in relative.parts):
        return False
    if path.name in {"local.properties", "runtime-classpath.txt", "test-classpath.init.gradle"} or path.suffix in {".log", ".local", ".pyc"}:
        return False
    if path.name.startswith(".env") and path.name != ".env.example":
        return False
    return True


files = [root / name for name in root_files]
for directory in source_directories:
    files.extend(path for path in (root / directory).rglob("*") if path.is_file() and permitted(path))

archive = dist / "TinyPrice-practica.zip"
with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as output:
    for path in sorted(set(files)):
        output.write(path, str(Path("IATinyFish") / path.relative_to(root)))
    output.write(apk, "IATinyFish/dist/TinyPrice-demo.apk")

checksums = []
for path in [apk, archive]:
    checksums.append(f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}")
(dist / "SHA256SUMS.txt").write_text("\n".join(checksums) + "\n", encoding="ascii")
print(f"Delivery: {archive}")
print(f"Source/evidence files: {len(set(files))}; demo APK included")
print(f"Archive bytes: {archive.stat().st_size}")
