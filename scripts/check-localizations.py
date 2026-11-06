#!/usr/bin/python3
"""检查简体中文本地化目录。

英文原文就是目录的 key。脚本会提取 SwiftUI 和 AppKit 的静态 key，补上 `.localized`
辅助方法收到的字面量 key，再与目录比对。
"""

from __future__ import annotations

import argparse
import collections
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


ENTRY = re.compile(r'^[ \t]*"((?:[^"\\]|\\.)*)"[ \t]*=[ \t]*"((?:[^"\\]|\\.)*)"[ \t]*;', re.MULTILINE)
LOCALIZED_CALL = re.compile(
    r'"((?:[^"\\]|\\.)*)"\s*\.localized(?:Format|MenuTitle|HistoryAction|ProjectTitle)?\b'
)
NS_LOCALIZED = re.compile(r'NSLocalizedString\(\s*"((?:[^"\\]|\\.)*)"')
FORMAT = re.compile(
    r'%(?:[0-9]+\$)?[-+#0\']*(?:[0-9]+|\*)?(?:\.(?:[0-9]+|\*))?'
    r'(hh|h|ll|l|q|L|z|j|t)?([@dDiuUxXoOfeEgGcsSpaA%])'
)
DYNAMIC_ARGUMENT = re.compile(r'%[0-9]*\$?arg')

# 有意保留英文的取值：产品名、格式名、单位和标点。
SAME_AS_KEY_ALLOWED = {
    "#", "%", "%@", "%@ %@", "%@%%", "%@°  %@", "%@…", "%lld", "%lld%%", "%lld°  %lld",
    "100%", "16:9", "1:1", "2.39:1", "3:4", "4:3", "9:16", "ASCII", "Alpha", "Bayer 2 × 2",
    "Bayer 4 × 4", "Bayer 8 × 8", "CMYK", "CMYK – %@", "Camera Raw…", "Compositor", "EXR",
    "Esc", "Floyd–Steinberg", "GIF", "HDR", "HSL", "JPEG", "PDF", "PNG", "RGB", "TIFF", "Tab",
    "sRGB", "·", "×",
}


@dataclass(frozen=True)
class Entry:
    key: str
    value: str
    line: int


@dataclass
class Report:
    errors: list[str]
    warnings: list[str]

    def __init__(self) -> None:
        self.errors = []
        self.warnings = []


def unescape_strings_literal(text: str) -> str:
    """解码 .strings 的 key 或值中可能出现的转义。"""
    result: list[str] = []
    index = 0
    escapes = {"n": "\n", "r": "\r", "t": "\t", '"': '"', "\\": "\\"}
    while index < len(text):
        character = text[index]
        if character != "\\" or index + 1 == len(text):
            result.append(character)
            index += 1
            continue
        escaped = text[index + 1]
        if escaped == "U" and index + 6 <= len(text):
            try:
                result.append(chr(int(text[index + 2:index + 6], 16)))
                index += 6
                continue
            except ValueError:
                pass
        result.append(escapes.get(escaped, escaped))
        index += 2
    return "".join(result)


def escape_strings_literal(text: str) -> str:
    return text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def parse_catalog(path: Path) -> list[Entry]:
    text = path.read_text(encoding="utf-8")
    return [
        Entry(unescape_strings_literal(key), unescape_strings_literal(value),
              text.count("\n", 0, match.start()) + 1)
        for match in ENTRY.finditer(text)
        for key, value in [match.groups()]
    ]


def format_kinds(text: str) -> collections.Counter[str]:
    """返回 printf 转换类型，忽略位置索引和显示宽度。"""
    return collections.Counter(
        (match.group(1) or "") + match.group(2)
        for match in FORMAT.finditer(text)
        if match.group(2) != "%"
    )


def is_dynamic_text(key: str) -> bool:
    """判断 xcstringstool 的 `%arg` key 是否仍含有需要翻译的文字。"""
    return "%arg" in key and re.search(r"[A-Za-z]", DYNAMIC_ARGUMENT.sub("", key)) is not None


def extracted_keys(source: Path, report: Report) -> set[str]:
    swift_files = sorted((source / "Compositor").rglob("*.swift"))
    if not swift_files:
        report.errors.append(f"找不到 Swift 源文件：{source / 'Compositor'}")
        return set()
    with tempfile.TemporaryDirectory(prefix="compositor-strings.") as temporary:
        result = subprocess.run(
            [
                "xcrun", "xcstringstool", "extract", "--SwiftUI", "--legacy-localizable-strings",
                "--output-directory", temporary, "--output-format", "strings", *map(str, swift_files),
            ],
            capture_output=True, text=True,
        )
        if result.returncode != 0:
            report.errors.append("xcstringstool 提取失败：\n" + result.stderr.strip())
            return set()
        keys: set[str] = set()
        for strings_file in Path(temporary).glob("*.strings"):
            keys.update(entry.key for entry in parse_catalog(strings_file))
        return keys


def literal_helper_keys(source: Path) -> set[str]:
    keys: set[str] = set()
    for path in (source / "Compositor").rglob("*.swift"):
        text = path.read_text(encoding="utf-8")
        keys.update(unescape_strings_literal(match.group(1)) for match in LOCALIZED_CALL.finditer(text))
        keys.update(unescape_strings_literal(match.group(1)) for match in NS_LOCALIZED.finditer(text))
    return keys


def check_catalog(path: Path, report: Report) -> list[Entry]:
    if not path.exists():
        report.errors.append(f"缺少本地化目录：{path}")
        return []
    entries = parse_catalog(path)
    seen: dict[str, int] = {}
    for entry in entries:
        if entry.key == "":
            report.errors.append(f"{path}:{entry.line}：空 key")
        if entry.value.strip() == "":
            report.errors.append(f"{path}:{entry.line}：{entry.key!r} 的翻译为空")
        if entry.key in seen:
            report.errors.append(f"{path}:{entry.line}：重复 key {entry.key!r}（首次在第 {seen[entry.key]} 行）")
        else:
            seen[entry.key] = entry.line
        source_specs = format_kinds(entry.key)
        translated_specs = format_kinds(entry.value)
        if source_specs != translated_specs:
            report.errors.append(
                f"{path}:{entry.line}：{entry.key!r} 的格式占位符不一致："
                f"{dict(source_specs)} != {dict(translated_specs)}"
            )
        if entry.value == entry.key and entry.key not in SAME_AS_KEY_ALLOWED \
                and re.search(r"[A-Za-z]", entry.key):
            report.warnings.append(f"{path}:{entry.line}：{entry.key!r} 尚未翻译")
    return entries


def write_missing(path: Path, keys: list[str]) -> None:
    if not keys:
        return
    with path.open("a", encoding="utf-8") as catalog:
        catalog.write("\n/* TODO: 上游新增，待翻译。 */\n")
        for key in keys:
            catalog.write(f'"{escape_strings_literal(key)}" = "{escape_strings_literal(key)}";\n')


def main() -> int:
    parser = argparse.ArgumentParser(description="检查 Compositor 的简体中文本地化。")
    parser.add_argument("--source", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--catalog", type=Path)
    parser.add_argument("--extracted", type=Path, help="已有的 xcstringstool 输出目录，便于调试")
    parser.add_argument("--write", action="store_true", help="把缺失的静态 key 以英文占位追加到目录")
    parser.add_argument("--strict", action="store_true", help="存在未翻译警告时也返回失败")
    arguments = parser.parse_args()

    source = arguments.source.resolve()
    catalog_path = arguments.catalog or source / "Compositor/zh-Hans.lproj/Localizable.strings"
    report = Report()

    entries = check_catalog(catalog_path, report)
    info_path = catalog_path.with_name("InfoPlist.strings")
    if info_path.exists():
        check_catalog(info_path, report)
    catalogue_keys = {entry.key for entry in entries}

    if arguments.extracted:
        extracted = set()
        extracted_path = arguments.extracted
        files = [extracted_path] if extracted_path.is_file() else sorted(extracted_path.glob("*.strings"))
        for path in files:
            extracted.update(entry.key for entry in parse_catalog(path))
    else:
        extracted = extracted_keys(source, report)

    dynamic = sorted(key for key in extracted if is_dynamic_text(key))
    for key in dynamic:
        report.errors.append(
            f"动态插值字符串 {key!r} 需要翻译，但不能作为稳定的 .strings key；"
            "请改用 `\"… %@ …\".localizedFormat(…)`"
        )
    source_keys = {
        key for key in extracted | literal_helper_keys(source)
        if key and not DYNAMIC_ARGUMENT.search(key)
    }
    missing = sorted(source_keys - catalogue_keys)

    if arguments.write and missing:
        write_missing(catalog_path, missing)
        print(f"已追加 {len(missing)} 条待翻译词条到 {catalog_path}")
        missing = []

    for key in missing:
        report.errors.append(f"源码使用但目录中缺少 key：{key!r}")

    if report.errors:
        print("本地化检查失败：")
        for error in report.errors:
            print(f"  - {error}")
    if report.warnings:
        print("本地化注意事项：")
        for warning in report.warnings:
            print(f"  - {warning}")
    if not report.errors and not report.warnings:
        print(f"本地化检查通过：{catalog_path}（{len(entries)} 条）")
    elif not report.errors:
        print(f"本地化结构检查通过：{catalog_path}（{len(entries)} 条，{len(report.warnings)} 条提醒）")

    if report.errors or (arguments.strict and report.warnings):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
