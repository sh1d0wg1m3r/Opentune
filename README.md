# Opentune

![Opentune Logo](https://img.shields.io/badge/Opentune-Free%20Windows%20Optimizer-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## A Free & Open Source Windows System Optimizer

Opentune is a **completely free** Windows optimization tool designed to help users enhance system performance without paying for expensive third-party utilities that often offer little benefit beyond what's already available in Windows.

### Why Opentune Exists

Many commercial "optimization" tools charge substantial fees for basic Windows tweaks that are readily available for free. Opentune was created to:

- Provide a **free alternative** to paid optimization software
- Help users avoid being scammed by overpriced "system optimizers" 
- Make common Windows performance tweaks accessible to everyone
- Give users transparency about what changes are being made to their system

## ⚠️ Important Notice

**This is an early, rough version of the optimizer.** While functional, it's still under development, and some tweaks may need refinement. Always create a System Restore point before making system changes.

## Features

- **Interactive Console Interface**: Easy-to-navigate menu system with risk indicators
- **Categorized Tweaks**: Organized into logical groups for better usability
- **Risk Assessment**: Each tweak displays its risk level and potential impact
- **Revert Options**: Most tweaks include corresponding revert scripts
- **Transparency**: Open batch files show exactly what changes are being made
- **Administrator-Friendly**: Automatic privilege elevation when needed

## Categories of Optimizations

- **Network**: TCP/IP, DNS, and adapter optimizations
- **Power**: Performance-oriented power settings
- **Visuals**: Disable animations and visual effects for better responsiveness
- **Privacy & Telemetry**: Reduce data collection and tracking
- **System & Kernel**: System-level and memory management optimizations
- **Services & Tasks**: Disable unnecessary background processes
- **Input**: Reduce input lag for mouse and keyboard
- **GPU**: Graphics card optimizations for different vendors
- **Cleanup**: Remove temporary files and free up disk space
- **Debloat**: Remove unwanted built-in applications

## Installation

1. Clone this repository or download the ZIP
2. Extract to any location on your Windows system
3. Run `opentune_launcher.py` (requires Python 3.6+ with Rich library)

```bash
# Install required dependencies
pip install rich
```

## Usage

1. Run `opentune_launcher.py`
2. **CREATE A SYSTEM RESTORE POINT FIRST** (very important!)
3. Browse through categories and select tweaks to apply
4. Read the risk level and description before applying any tweak
5. Apply tweaks one at a time and test system stability
6. Use the revert scripts in the 99-Revert category if needed

## Risks and Warnings

- **ALWAYS create a System Restore point before using Opentune**
- Start with low-risk tweaks and test your system
- Some tweaks may not be suitable for all hardware configurations
- Certain tweaks (especially those marked High or Extreme Risk) could cause system instability
- Use at your own risk - we cannot guarantee compatibility with all systems

## Why Free Instead of Paid?

Many commercial optimizers:
- Charge for basic Windows functionality
- Use scare tactics to push unnecessary "fixes"
- Hide what they're actually doing to your system
- Often include bloatware or unwanted features

Opentune is completely transparent about all changes it makes to your system. You can read each batch file to understand exactly what will be modified before running it.

## Contributing

Contributions are welcome! If you have optimization tweaks to add or improvements to suggest:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with your changes
4. Include descriptions of what your tweaks do and their risk level

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

Opentune is provided as-is without warranty of any kind. The authors are not responsible for any damage that may occur from using these tweaks. Always ensure you have proper backups before modifying your system.

---

⭐ If you find this project helpful, please consider giving it a star on GitHub!
