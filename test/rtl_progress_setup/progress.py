#!/usr/bin/env python3

from pathlib import Path
import re

README = Path("README.md")

START = "<!-- PROGRESS:START -->"
END = "<!-- PROGRESS:END -->"


def main():
    text = README.read_text(encoding="utf-8")

    section_pattern = re.compile(
        rf"{re.escape(START)}.*?{re.escape(END)}",
        re.DOTALL,
    )

    # Only count checkboxes outside the generated progress section.
    text_without_progress = section_pattern.sub("", text)

    completed = len(re.findall(r"(?m)^\s*-\s*\[[xX]\]\s+", text_without_progress))
    total = len(re.findall(r"(?m)^\s*-\s*\[[ xX]\]\s+", text_without_progress))

    percentage = round((completed / total) * 100) if total else 0

    filled = percentage // 5
    bar = "█" * filled + "░" * (20 - filled)

    progress = f"""<!-- PROGRESS:START -->
**Overall Progress: {percentage}%**

`{bar}` {percentage}%

- Total: {completed} / {total} completed
<!-- PROGRESS:END -->"""

    new_text, replacements = section_pattern.subn(progress, text, count=1)

    if replacements != 1:
        raise RuntimeError(
            "Could not find exactly one PROGRESS:START / PROGRESS:END section."
        )

    README.write_text(new_text, encoding="utf-8")

    print(f"Progress: {completed}/{total} = {percentage}%")


if __name__ == "__main__":
    main()
