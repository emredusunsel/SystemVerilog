#!/usr/bin/env python3

from pathlib import Path
import re


README = Path("README.md")
PROGRESS = Path("PROGRESS.md")

START = "<!-- PROGRESS:START -->"
END = "<!-- PROGRESS:END -->"


def calculate_percentage(completed, total):
    if total == 0:
        return 0

    return round((completed / total) * 100)


def progress_bar(value, width=20):
    filled = round(value / 100 * width)
    return "█" * filled + "░" * (width - filled)


def parse_modules(text):
    """
    Parse categories, modules, and checkboxes from PROGRESS.md.

    Expected structure:

    ## Combinational

    ### MUX

    - [x] RTL
    - [x] Testbench
    - [ ] README

    Both '-' and '*' list markers are supported.
    Both '[x]' and '[X]' are supported.
    """

    modules = {}

    current_category = None
    current_module = None

    for line in text.splitlines():

        # --------------------------------------------------
        # Category
        # Example:
        # ## Combinational
        # --------------------------------------------------

        category_match = re.match(
            r"^##\s+(.+?)\s*$",
            line,
        )

        if category_match:
            current_category = category_match.group(1).strip()
            current_module = None

            modules[current_category] = {}

            continue

        # --------------------------------------------------
        # Module
        # Example:
        # ### MUX
        # --------------------------------------------------

        module_match = re.match(
            r"^###\s+(.+?)\s*$",
            line,
        )

        if module_match and current_category:

            current_module = module_match.group(1).strip()

            modules[current_category][current_module] = {
                "completed": 0,
                "total": 0,
            }

            continue

        # --------------------------------------------------
        # Checkbox
        #
        # Supports:
        #
        # - [ ] RTL
        # - [x] RTL
        # - [X] RTL
        #
        # * [ ] RTL
        # * [x] RTL
        # * [X] RTL
        # --------------------------------------------------

        checkbox_match = re.match(
            r"^\s*[-*]\s+\[([ xX])\]\s+(.+?)\s*$",
            line,
        )

        if (
            checkbox_match
            and current_category
            and current_module
        ):

            checked = checkbox_match.group(1).lower() == "x"

            modules[current_category][current_module]["total"] += 1

            if checked:
                modules[current_category][current_module]["completed"] += 1

    return modules


def generate_progress(modules):

    overall_completed = 0
    overall_total = 0

    category_stats = {}

    # ======================================================
    # Calculate statistics
    # ======================================================

    for category, category_modules in modules.items():

        category_completed = 0
        category_total = 0

        for module, stats in category_modules.items():

            completed = stats["completed"]
            total = stats["total"]

            module_percentage = calculate_percentage(
                completed,
                total,
            )

            stats["percentage"] = module_percentage

            category_completed += completed
            category_total += total

            overall_completed += completed
            overall_total += total

        category_percentage = calculate_percentage(
            category_completed,
            category_total,
        )

        category_stats[category] = {
            "completed": category_completed,
            "total": category_total,
            "percentage": category_percentage,
        }

    overall_percentage = calculate_percentage(
        overall_completed,
        overall_total,
    )

    # ======================================================
    # Generate README section
    # ======================================================

    lines = []

    lines.append(START)
    lines.append("")

    # ------------------------------------------------------
    # Overall
    # ------------------------------------------------------

    lines.append(
        f"**Overall Progress: {overall_percentage}%**"
    )

    lines.append("")

    lines.append(
        f"`{progress_bar(overall_percentage)}` "
        f"{overall_percentage}%"
    )

    lines.append("")

    lines.append(
        f"**Total: {overall_completed} / "
        f"{overall_total} completed**"
    )

    # ------------------------------------------------------
    # Category Progress
    # ------------------------------------------------------

    lines.append("")
    lines.append("### Category Progress")
    lines.append("")

    for category, stats in category_stats.items():

        p = stats["percentage"]

        lines.append(
            f"- **{category}: {p}%** "
            f"({stats['completed']}/{stats['total']})"
        )

    # ------------------------------------------------------
    # Module Progress
    # ------------------------------------------------------

    lines.append("")
    lines.append("### Module Progress")
    lines.append("")

    for category, category_modules in modules.items():

        lines.append(f"#### {category}")
        lines.append("")

        for module, stats in category_modules.items():

            p = stats["percentage"]

            lines.append(
                f"- **{module}: {p}%** "
                f"({stats['completed']}/{stats['total']})"
            )

        lines.append("")

    lines.append(END)

    return "\n".join(lines)


def main():

    # ======================================================
    # Read files
    # ======================================================

    if not README.exists():
        raise RuntimeError("README.md not found.")

    if not PROGRESS.exists():
        raise RuntimeError("PROGRESS.md not found.")

    readme_text = README.read_text(encoding="utf-8")
    progress_text = PROGRESS.read_text(encoding="utf-8")

    # ======================================================
    # Find generated progress section
    # ======================================================

    progress_pattern = re.compile(
        rf"{re.escape(START)}.*?{re.escape(END)}",
        re.DOTALL,
    )

    if not progress_pattern.search(readme_text):
        raise RuntimeError(
            "Could not find PROGRESS:START / PROGRESS:END "
            "markers in README.md."
        )

    # ======================================================
    # Parse PROGRESS.md
    # ======================================================

    modules = parse_modules(progress_text)

    if not modules:
        raise RuntimeError(
            "No categories/modules were found in PROGRESS.md."
        )

    # ======================================================
    # Generate progress
    # ======================================================

    progress = generate_progress(modules)

    # ======================================================
    # Replace generated section in README.md
    # ======================================================

    new_text, replacements = progress_pattern.subn(
        progress,
        readme_text,
        count=1,
    )

    if replacements != 1:
        raise RuntimeError(
            "Expected exactly one progress section."
        )

    README.write_text(
        new_text,
        encoding="utf-8",
    )

    # ======================================================
    # Print debug information
    # ======================================================

    print("README progress updated successfully.")
    print()

    for category, category_modules in modules.items():

        category_completed = sum(
            stats["completed"]
            for stats in category_modules.values()
        )

        category_total = sum(
            stats["total"]
            for stats in category_modules.values()
        )

        category_percentage = calculate_percentage(
            category_completed,
            category_total,
        )

        print(
            f"{category}: "
            f"{category_completed}/{category_total} "
            f"({category_percentage}%)"
        )

        for module, stats in category_modules.items():

            print(
                f"  {module}: "
                f"{stats['completed']}/"
                f"{stats['total']} "
                f"({stats['percentage']}%)"
            )


if __name__ == "__main__":
    main()