# Local OCR comparison tools

Small local runners for comparing Apple Vision, Tesseract, and Granite Docling on macOS. Private inputs and generated OCR results are intentionally ignored by Git.

## Requirements

- macOS with the Apple Vision framework and Swift compiler
- Tesseract installed with `brew install tesseract`
- Ollama running locally with `ollama pull ibm/granite-docling`

Keep Ollama bound to `127.0.0.1` when processing private documents.

## Build

```sh
mkdir -p ocr-comparison/bin ocr-comparison/work/clang-cache ocr-comparison/work/swift-cache

CLANG_MODULE_CACHE_PATH="$PWD/ocr-comparison/work/clang-cache" \
SWIFT_MODULECACHE_PATH="$PWD/ocr-comparison/work/swift-cache" \
xcrun swiftc ocr-comparison/vision_ocr.swift \
  -o ocr-comparison/bin/vision_ocr

CLANG_MODULE_CACHE_PATH="$PWD/ocr-comparison/work/clang-cache" \
SWIFT_MODULECACHE_PATH="$PWD/ocr-comparison/work/swift-cache" \
xcrun swiftc -parse-as-library ocr-comparison/granite_ocr.swift \
  -o ocr-comparison/bin/granite_ocr
```

## Run

```sh
ocr-comparison/bin/vision_ocr /path/to/page.jpg

ocr-comparison/bin/granite_ocr \
  /path/to/page.jpg \
  /path/to/granite-output.txt

tesseract /path/to/page.jpg stdout -l eng --psm 4
```

The Granite runner sends the base64-encoded image only to Ollama's local `127.0.0.1:11434` API. It uses the official `Convert this page to docling.` prompt, temperature zero, and a maximum of 8192 generated tokens.
