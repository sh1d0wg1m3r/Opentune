import os
import subprocess
import sys
import ctypes
import re
from collections import defaultdict
from rich.console import Console
from rich.panel import Panel
from rich.table import Table, box
from rich.progress import Progress
from rich.prompt import Confirm, IntPrompt
from rich.syntax import Syntax
from rich.text import Text
from rich.theme import Theme
from rich.align import Align

# --- Configuration ---
TWEAKS_DIR = "tweaks"  # Subdirectory containing tweak categories
COMMENT_PREFIX = "REM" # Standard batch file comment prefix
DESCRIPTION_TAG = "Description:"
RISK_TAG = "Risk:"
REVERT_INFO_TAG = "RevertInfo:"

# Create Rich console with custom theme
custom_theme = Theme({
    "info": "cyan",
    "warning": "yellow",
    "danger": "bold red",
    "success": "bold green",
    "header": "bold blue",
    "category": "magenta",
    "logo": "bright_cyan",
})
console = Console(theme=custom_theme)

# ASCII Art Logo - Improved computer design
LOGO = """
[logo]
╔═════════════════════════╗
║   ▛▀▀▜▌   ▌  ▛▀▜ ▛▀▜▐▌  ║
║   ▌  ▐▙▄▖▐▌ ▌ ▌▐▙▖▌▀▘▌  ║
║   ▌  ▐▌ ▐▐▌ ▌ ▌▐  ▌  ▌  ║
║   ▙▄▟▀▘ ▀▘▘ ▛▀▜▐  ▀▄▄▀  ║
║                         ║
║ SYSTEM OPTIMIZER v1.0.2 ║
╚═════════════════════════╝
       ╔═════════╗
       ║ [][][]  ║
       ║  [][][]  ║
       ║ [][][]  ║
       ╚═════════╝
[/logo]
"""

# --- Helper Functions ---

def is_admin():
    """Checks if the script is running with administrative privileges."""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def request_admin():
    """Restarts the script with admin privileges by invoking UAC."""
    if is_admin():
        return True
    else:
        # Command to relaunch the script with elevated privileges
        try:
            console.print("[info]Requesting administrative privileges...[/info]")
            # The "runas" verb triggers the UAC prompt
            ctypes.windll.shell32.ShellExecuteW(
                None, "runas", sys.executable, " ".join(sys.argv), None, 1
            )
            # Exit the current non-elevated process
            sys.exit(0)
        except Exception as e:
            console.print(f"[danger]Failed to elevate privileges: {e}[/danger]")
            return False

def parse_tweak_metadata(file_path):
    """
    Parses metadata comments from the beginning of a batch file.
    Expected format:
    REM Description: A brief explanation of what the tweak does.
    REM Risk: Low/Medium/High - Potential risks or side effects. (Optional)
    REM RevertInfo: How to revert this tweak / Name of revert script. (Optional)
    """
    metadata = {
        'description': os.path.splitext(os.path.basename(file_path))[0].replace('_', ' ').title(), # Default description from filename
        'risk': 'Unknown',
        'revert_info': 'No specific revert script mentioned. Check the 99-Revert category or use System Restore.',
        'path': file_path
    }
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            # Limit parsing to the first few lines for efficiency
            lines_to_check = 10
            lines_read = 0
            for line in f:
                line = line.strip()
                if lines_read >= lines_to_check:
                    break
                lines_read += 1

                if line.upper().startswith(COMMENT_PREFIX):
                    content = line[len(COMMENT_PREFIX):].strip()
                    if content.upper().startswith(DESCRIPTION_TAG.upper()):
                        metadata['description'] = content[len(DESCRIPTION_TAG):].strip()
                    elif content.upper().startswith(RISK_TAG.upper()):
                        metadata['risk'] = content[len(RISK_TAG):].strip()
                    elif content.upper().startswith(REVERT_INFO_TAG.upper()):
                         metadata['revert_info'] = content[len(REVERT_INFO_TAG):].strip()
                # Stop parsing if a non-comment line (excluding @echo off) is found early
                elif not line.lower().startswith('@echo off') and line != "":
                    break
    except FileNotFoundError:
        console.print(f"[warning]Warning: File not found during metadata parsing: {file_path}[/warning]")
        return None
    except Exception as e:
        console.print(f"[warning]Warning: Error parsing metadata for {file_path}: {e}[/warning]")
        # Return metadata with defaults even if parsing fails partially
    return metadata


def discover_tweaks(base_dir):
    """
    Discovers tweak categories (subfolders) and their corresponding .bat files.
    Returns a dictionary: {category_name: [tweak_metadata_dict, ...]}
    """
    categories = defaultdict(list)
    if not os.path.isdir(base_dir):
        console.print(f"[danger]Error: Tweak directory '{base_dir}' not found.[/danger]")
        return categories

    with Progress() as progress:
        task = progress.add_task("[cyan]Discovering tweaks...", total=None)
        
        if os.path.isdir(base_dir):
            # First count how many categories we have
            category_count = len([d for d in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, d))])
            progress.update(task, total=category_count)
            
            for category_name in sorted(os.listdir(base_dir)):
                category_path = os.path.join(base_dir, category_name)
                if os.path.isdir(category_path):
                    # Use regex to extract name without leading numbers like "01-"
                    match = re.match(r"^\d+-(.*)", category_name)
                    display_category_name = match.group(1) if match else category_name
                    display_category_name = display_category_name.replace('_', ' ').replace('-', ' ')

                    for item in sorted(os.listdir(category_path)):
                        if item.lower().endswith(".bat"):
                            tweak_path = os.path.join(category_path, item)
                            metadata = parse_tweak_metadata(tweak_path)
                            if metadata:
                                categories[display_category_name].append(metadata)
                    progress.update(task, advance=1, description=f"Scanning: {display_category_name}")

    return categories

def display_menu(title, options, is_main_menu=False):
    """Displays a numbered menu and returns the user's choice."""
    # Print a separator line instead of clearing the console (safer for elevated prompt)
    console.print("\n" + "="*70 + "\n")
    console.print(Align.center(LOGO))
    
    if is_main_menu:
        # Main menu with categories gets a special header
        console.print(Panel(f"[header]OPTIMIZATION CATEGORIES[/header]", expand=False))
    else:
        # Regular menu header
        console.print(Panel(f"[header]{title}[/header]", expand=False))
    
    if not options:
        console.print("[warning]No options available.[/warning]")
        return None

    # FIXED: Use box.SIMPLE instead of True for the box parameter
    table = Table(show_header=False, box=box.SIMPLE)
    table.add_column("Index", style="cyan", width=6)
    table.add_column("Option", style="white")
    
    for i, option in enumerate(options):
        table.add_row(f"{i + 1}", option)
    table.add_row("0", "[bold]Back / Exit[/bold]")
    
    console.print(table)
    
    if is_main_menu:
        console.print(Panel("[warning]IMPORTANT:[/warning] Create a System Restore point before applying tweaks."))

    while True:
        try:
            choice = IntPrompt.ask("Enter your choice", default=0)
            if 0 <= choice <= len(options):
                return choice
            else:
                console.print("[warning]Invalid choice. Please try again.[/warning]")
        except ValueError:
            console.print("[warning]Invalid input. Please enter a number.[/warning]")

def format_risk_level(risk):
    """Format risk level with appropriate color."""
    risk_lower = risk.lower()
    if 'high' in risk_lower or 'extreme' in risk_lower:
        return f"[danger]{risk}[/danger]"
    elif 'medium' in risk_lower:
        return f"[warning]{risk}[/warning]"
    elif 'low' in risk_lower:
        return f"[success]{risk}[/success]"
    else:
        return f"[info]{risk}[/info]"

def run_tweak(tweak_metadata):
    """Executes the selected batch file in a visible window."""
    # Print a separator line instead of clearing the console
    console.print("\n" + "="*70 + "\n")
    
    # FIXED: Use box.SIMPLE instead of True for the box parameter
    table = Table(show_header=False, box=box.SIMPLE, title="Tweak Details")
    table.add_column("Property", style="cyan")
    table.add_column("Value")
    
    table.add_row("Tweak", tweak_metadata['description'])
    table.add_row("Risk", Text.from_markup(format_risk_level(tweak_metadata['risk'])))
    table.add_row("Revert Info", tweak_metadata['revert_info'])
    table.add_row("File", os.path.basename(tweak_metadata['path']))
    
    console.print(table)

    if not Confirm.ask("Are you sure you want to run this tweak?", default=False):
        console.print("[info]Tweak cancelled.[/info]")
        console.input("\nPress Enter to continue...")
        return

    console.print(f"\n[info]Launching {os.path.basename(tweak_metadata['path'])} in a new window...[/info]")
    console.print("[info]Check the new window for details and progress. Close it manually when done.[/info]")
    
    try:
        # Simplified - just use os.system with start command
        # This is more reliable in elevated contexts than subprocess.Popen
        bat_path = tweak_metadata['path']
        window_title = f"Opentune - {os.path.basename(bat_path)}"
        
        # The /D parameter sets the initial directory to the batch file's location
        # /K keeps the window open after the batch file completes
        command = f'start "{window_title}" cmd /D "{os.path.dirname(bat_path)}" /K "{bat_path}"'
        os.system(command)
        
        console.print("[success]Tweak launched successfully in a new window.[/success]")
        console.print("[info]You can return to the main menu while the tweak runs in its own window.[/info]")
        
    except Exception as e:
        console.print(f"[danger]An unexpected error occurred while launching the tweak: {e}[/danger]")

    console.input("\nPress Enter to return to the menu...")

def display_about_info():
    """Displays information about the Opentune program."""
    # Print a separator line instead of clearing the console
    console.print("\n" + "="*70 + "\n")
    console.print(Align.center(LOGO))
    
    about_content = """
# About Opentune

## Overview
Opentune is a Windows system optimization tool that provides various tweaks 
to improve performance, reduce overhead, and customize your Windows experience.

## Features
- Categorized tweaks organized into logical groups
- Risk assessment for each optimization
- Revert scripts for most tweaks
- Open source and transparent optimization techniques

## Usage Tips
- Always create a System Restore point before applying tweaks
- Start with low-risk tweaks and test your system
- High-risk tweaks should only be applied if you understand the consequences
- Use the revert scripts in the 99-Revert category if needed

## Support
For help and contributions, check the project repository
https://github.com/sh1d0wg1m3r/Opentune
"""
    
    console.print(Panel(about_content, title="About Opentune", expand=False))
    console.input("\nPress Enter to return to the main menu...")


# --- Main Execution ---

if __name__ == "__main__":
    try:
        # Print a separator line instead of clearing the console
        console.print("\n" + "="*70 + "\n")
        console.print(Align.center(LOGO))
        
        console.print(Panel(
            "[warning]IMPORTANT: Use these tweaks at your own risk.\n"
            "ALWAYS create a System Restore point before applying significant changes.\n"
            "Ensure you understand what each tweak does before running it.[/warning]",
            border_style="yellow",
            expand=False
        ))

        # Check and request admin if needed
        if not is_admin():
            console.print("[warning]Administrative privileges are required to run these tweaks.[/warning]")
            request_admin()
            # If we're still here, elevation failed
            console.print("[danger]Failed to obtain administrative privileges. Exiting...[/danger]")
            console.input("Press Enter to exit.")
            sys.exit(1)
        
        # Discover available tweaks
        console.print("[info]Discovering tweaks...[/info]")
        available_tweaks = discover_tweaks(TWEAKS_DIR)

        if not available_tweaks:
            console.print(f"[warning]No tweaks found in the '{TWEAKS_DIR}' directory or its subdirectories.[/warning]")
            console.input("Press Enter to exit.")
            sys.exit(1)

        categories = list(available_tweaks.keys())
        
        # Add "About" option to the main menu
        categories.append("About Opentune")

        while True: # Main loop for categories
            category_choice = display_menu("Select Category", categories, is_main_menu=True)

            if category_choice is None or category_choice == 0:
                # Print a separator line instead of clearing the console
                console.print("\n" + "="*70 + "\n")
                console.print(Align.center(LOGO))
                console.print(Panel("[info]Thank you for using Opentune![/info]"))
                console.print("[info]Exiting Opentune Launcher.[/info]")
                break # Exit main loop
            
            # Handle "About" option
            if category_choice == len(categories):
                display_about_info()
                continue

            selected_category_name = categories[category_choice - 1]
            tweaks_in_category = available_tweaks[selected_category_name]
            tweak_descriptions = [t['description'] for t in tweaks_in_category]

            while True: # Loop for tweaks within a category
                tweak_choice = display_menu(f"Tweaks in '{selected_category_name}'", tweak_descriptions)

                if tweak_choice is None or tweak_choice == 0:
                    break # Go back to category menu

                selected_tweak_metadata = tweaks_in_category[tweak_choice - 1]
                run_tweak(selected_tweak_metadata)
                # After running a tweak, stay in the same category menu
    
    except Exception as e:
        # Global error handler to prevent crashes in elevated context
        console.print(f"[danger]An unexpected error occurred: {str(e)}[/danger]")
        import traceback
        console.print(traceback.format_exc())
        console.input("\nPress Enter to exit...")
        sys.exit(1)