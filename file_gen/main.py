from pathlib import Path
import os


OUTPUT_DIR = Path(__file__).parent / "generated_files"

FILES = {
    "1kb.bin": 1 * 1024,
    "10kb.bin": 10 * 1024,
    "100kb.bin": 100 * 1024,
    "1mb.bin": 1 * 1024 * 1024,
    "10mb.bin": 10 * 1024 * 1024,
    "100mb.bin": 100 * 1024 * 1024,
}


def generate_file(filename: str, size: int):
    filepath = OUTPUT_DIR / filename

    print(f"Generating {filename} ({size:,} bytes)...")

    chunk_size = 1024 * 1024  # 1 MB

    with open(filepath, "wb") as f:
        remaining = size

        while remaining > 0:
            current_chunk = min(chunk_size, remaining)
            f.write(os.urandom(current_chunk))
            remaining -= current_chunk

    print(f"Created: {filepath}")


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for filename, size in FILES.items():
        generate_file(filename, size)

    print("\nAll files generated successfully!")
    print(f"Location: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()