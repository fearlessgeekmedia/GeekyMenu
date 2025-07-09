# GeekyMenu

A fast, fuzzy-search application launcher for Linux with a terminal-based UI. Quickly find and launch applications from your system's `.desktop` files. Perfect for window managers that need a lightweight application launcher.

## Features

- 🔍 **Fuzzy Search**: Type to instantly filter applications
- ⚡ **Fast Navigation**: Use arrow keys to browse results
- 📱 **Terminal UI**: Beautiful blessed-based interface
- 🚀 **Quick Launch**: Press Enter to launch applications
- 📂 **Auto-discovery**: Scans system application directories

## Screenshots

The launcher provides a split-pane interface:
- **Top**: Search input field
- **Left**: Filtered application list
- **Right**: Application description preview

## Installation

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Setup

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd geekymenu
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Run the launcher:
   ```bash
   node geekymenu.js
   ```

## Usage

### Running the Launcher

```bash
# Run with Node.js
node geekymenu.js

# Or run the compiled binary (after building)
./dist/geekymenu

# For window managers, use with terminal emulator
terminal -e geekymenu
```

### Controls

- **Type**: Start typing to filter applications
- **↑/↓**: Navigate through results
- **Page Up/Page Down**: Jump by 10 items
- **Enter**: Launch selected application
- **Escape**: Exit the launcher
- **Ctrl+C**: Force quit

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `↑` | Move up in list |
| `↓` | Move down in list |
| `Page Up` | Jump up 10 items |
| `Page Down` | Jump down 10 items |
| `Enter` | Launch application |
| `Escape` | Exit launcher |
| `Ctrl+C` | Force quit |

## Building a Binary

### Using pkg (Recommended)

1. Install pkg globally (if not already):
   ```bash
   npm install -g pkg
   ```

2. Build the static binary with blessed assets:
   ```bash
   pkg . --targets node18-linuxstatic-x64
   ```

   The binary will be created as `dist/geekymenu`.

> **Note:** The `dist/` directory is gitignored and will not be committed to version control.

### Cross-platform Building

To build for multiple platforms:

```bash
pkg . --targets node18-linuxstatic-x64,node18-macos-x64,node18-win-x64
```

### Including Blessed Assets

The build process includes blessed's terminfo files automatically (see `package.json`'s `pkg.assets`). If you add more assets, update the `assets` array accordingly.

## Development

### Project Structure

```
geekymenu/
├── geekymenu.js      # Main application code
├── package.json      # Dependencies and scripts
├── README.md         # This file
├── .gitignore        # Git ignore rules
└── dist/             # Compiled binaries (gitignored)
```

### Dependencies

- **blessed**: Terminal UI library
- **glob**: File pattern matching

### Adding Features

The launcher is modular and easy to extend:

1. **Add new search directories**: Modify the `appDirs` array in `geekymenu.js`
2. **Customize UI**: Modify the blessed widget configurations
3. **Add keyboard shortcuts**: Extend the keypress handlers

## Troubleshooting

### Common Issues

1. **"Cannot find module 'blessed'"**
   - Run `npm install` to install dependencies

2. **Binary not working**
   - Ensure you're using a supported Node.js version (18+)
   - Try rebuilding with `pkg . --targets node18-linuxstatic-x64`

3. **No applications found**
   - Check that your system has `.desktop` files in standard locations
   - Verify the directories in `appDirs` exist on your system

4. **Terminfo/asset errors in binary**
   - Ensure blessed assets are included in the build (see `pkg.assets` in `package.json`)

### Debug Mode

To run with additional logging:

```bash
DEBUG=blessed* node geekymenu.js
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source. Feel free to modify and distribute as needed.

## Acknowledgments

- Built with [blessed](https://github.com/chjj/blessed) for the terminal UI
- Inspired by modern application launchers like dmenu and rofi 