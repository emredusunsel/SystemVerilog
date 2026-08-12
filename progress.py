#!/usr/bin/env python3

from pathlib import Path
import re


README = Path("README.md")

START = "<!-- PROGRESS:START -->"
END = "<!-- PROGRESS:END -->"


def percentage(completed, total):
    if total == 0:
        return 0

    return round((completed / total) * 100)


def progress_bar(value, width=20):
    filled = round(value / 100 * width)
    return "█" * filled + "░" * (width - filled)


def parse_modules(text):
    """
    Parse the README structure:

    ## Folder

    ### Module

    - [ ] RTL
    - [x] Testbench
    - [ ] README
    """

    folders = {}

    current_folder = None
    current_module = None

    for line in text.splitlines():

        # Folder heading: ## Combinational
        folder_match = re.match(r"^## (.+?)\s*$", line)

        if folder_match:
            folder = folder_match.group(1).strip()

            # Ignore non-progress sections.
            if folder in {
                "Progress",
                "Repository Structure",
                "Verification",
                "Design Principles",
                "Tools",
                "Automatic Progress",
                "License",
            }:
                current_folder = None
                current_module = None
                continue

            current_folder = folder
            current_module = None

            folders[current_folder] = {}

            continue

        # Module heading: ### ALU
        module_match = re.match(r"^### (.+?)\s*$", line)

        if module_match and current_folder:
            current_module = module_match.group(1).strip()

            folders[current_folder][current_module] = {
                "completed": 0,
                "total": 0,
            }

            continue

        # Checkbox
        checkbox_match = re.match(
            r"^\s*-\s*\[([ xX])\]\s+(.+?)\s*$",
            line,
        )

        if checkbox_match and current_folder and current_module:

            checked = checkbox_match.group(1).lower() == "x"

            folders[current_folder][current_module]["total"] += 1

            if checked:
                folders[current_folder][current_module]["completed"] += 1

    return folders


def generate_progress(folders):
    total_completed = 0
    total_tasks = 0

    folder_stats = {}

    for folder, modules in folders.items():

        folder_completed = 0
        folder_total = 0

        for module, stats in modules.items():

            completed = stats["completed"]
            total = stats["total"]

            module_percentage = percentage(completed, total)

            stats["percentage"] = module_percentage

            folder_completed += completed
            folder_total += total

            total_completed += completed
            total_tasks += total

        folder_percentage = percentage(
            folder_completed,
            folder_total,
        )

        folder_stats[folder] = {
            "completed": folder_completed,
            "total": folder_total,
            "percentage": folder_percentage,
        }

    overall_percentage = percentage(
        total_completed,
        total_tasks,
    )

    lines = []

    lines.append(START)
    lines.append("")
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
        f"**Total: {total_completed} / {total_tasks} completed**"
    )
    lines.append("")

    lines.append("### Category Progress")
    lines.append("")

    for folder, stats in folder_stats.items():

        p = stats["percentage"]

        lines.append(
            f"- **{folder}: {p}%** "
            f"({stats['completed']}/{stats['total']})"
        )

    lines.append("")

    lines.append("### Module Progress")
    lines.append("")

    for folder, modules in folders.items():

        lines.append(f"#### {folder}")
        lines.append("")

        for module, stats in modules.items():

            p = stats["percentage"]

            lines.append(
                f"- **{module}: {p}%** "
                f"({stats['completed']}/{stats['total']})"
            )

        lines.append("")

    lines.append(END)

    return "\n".join(lines)


def main():

    text = README.read_text(encoding="utf-8")

    section_pattern = re.compile(
        rf"{re.escape(START)}.*?{re.escape(END)}",
        re.DOTALL,
    )

    if not section_pattern.search(text):
        raise RuntimeError(
            "Could not find PROGRESS:START / PROGRESS:END "
            "markers in README.md."
        )

    # Remove the generated progress section before parsing.
    text_without_progress = section_pattern.sub(
        "",
        text,
    )

    folders = parse_modules(text_without_progress)

    progress = generate_progress(folders)

    new_text, replacements = section_pattern.subn(
        progress,
        text,
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

    print("README progress updated successfully.")


if __name__ == "__main__":
    main()