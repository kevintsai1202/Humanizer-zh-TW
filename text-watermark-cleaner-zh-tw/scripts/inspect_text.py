#!/usr/bin/env python3
"""Inspect text for invisible Unicode / space homoglyphs (Layer A) and optional stylometry."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

# Allow running as script from any cwd
sys.path.insert(0, str(Path(__file__).resolve().parent))

from common import emit_json, read_text_input
from score_stylometry import print_human_stylometry_report, score_text_stylometry
from text_unicode import human_report, inspect_text


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("path", nargs="?", default="-", help="Text file path, or - for stdin")
    p.add_argument("--json", action="store_true", help="JSON report")
    p.add_argument(
        "--aggressive",
        action="store_true",
        help="Also flag Latin confusable / fullwidth lookalikes",
    )
    p.add_argument(
        "--strip-emoji-glue",
        action="store_true",
        help="Paranoid: flag all load-bearing invisibles too (emoji glue, script joiners, flag tags, same-script fillers/selectors, orthographic Cf)",
    )
    p.add_argument(
        "--stylometry",
        action="store_true",
        help="Also run zero-LLM statistical and stylometric AI cadence scoring",
    )
    p.add_argument(
        "--threshold",
        type=float,
        default=0.65,
        help="Score threshold for --stylometry exit code (default: 0.65)",
    )
    p.add_argument(
        "--force-text",
        action="store_true",
        help="Scan even when the input looks like a binary container",
    )
    args = p.parse_args()

    text = read_text_input(args.path, allow_binary=args.force_text)
    if text is None:
        return 2

    report = inspect_text(
        text,
        aggressive=args.aggressive,
        strip_emoji_glue=args.strip_emoji_glue,
    )

    stylometry_report = None
    if args.stylometry:
        input_label = "<stdin>" if args.path == "-" else args.path
        stylometry_report = score_text_stylometry(text, path=input_label)

    if args.json:
        data = report.to_dict()
        if stylometry_report:
            data["stylometry"] = stylometry_report.to_dict()
        emit_json(data)
    else:
        print(human_report(report))
        if stylometry_report:
            print("\n" + "=" * 50 + "\n")
            print_human_stylometry_report(stylometry_report, explain=True)

    exit_code = 0
    if report.suspicious_total > 0:
        exit_code = 1
    if stylometry_report and stylometry_report.score >= args.threshold:
        exit_code = 1

    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
