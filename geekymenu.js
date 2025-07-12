#!/usr/bin/env node

import fs from "fs";
import os from "os";
import path from "path";
import { spawn } from "child_process";
import React from "react";
import { render, Box, Text, useInput, useApp } from "ink";

// Directories to scan for .desktop files
const home = os.homedir();
const appDirs = [
  "/usr/share/applications",
  "/usr/local/share/applications",
  path.join(home, ".local/share", "applications"),
  // Flatpak application directories
  "/var/lib/flatpak/exports/share/applications",
  path.join(home, ".local/share/flatpak/exports/share/applications"),
];

// Recursively find all .desktop files
function findDesktopFiles() {
  let results = [];
  for (const dir of appDirs) {
    if (!fs.existsSync(dir)) continue;
    const stack = [dir];
    while (stack.length) {
      const current = stack.pop();
      const files = fs.readdirSync(current);
      for (const file of files) {
        const full = path.join(current, file);
        if (fs.statSync(full).isDirectory()) {
          stack.push(full);
        } else if (file.endsWith(".desktop")) {
          results.push(full);
        }
      }
    }
  }
  return results;
}

// Parse name, comment, exec from .desktop file
function parseDesktopFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, "utf8");
    const name = content.match(/^Name=(.+)$/m)?.[1] || null;
    const comment = content.match(/^Comment=(.+)$/m)?.[1] || "";
    const execRaw = content.match(/^Exec=(.+)$/m)?.[1] || null;
    const execClean = execRaw?.replace(/ *%[fFuUdDnNickvm]/g, "") || null;
    const terminal = /Terminal=true/.test(content);
    return name && execClean
      ? { name, comment, exec: execClean, terminal, file: filePath }
      : null;
  } catch {
    return null;
  }
}

// Fuzzy match score
function fuzzyMatchScore(input, target) {
  input = input.toLowerCase();
  target = target.toLowerCase();

  let score = 0;
  let j = 0;
  for (let i = 0; i < input.length; i++) {
    const c = input[i];
    let found = false;
    while (j < target.length) {
      if (target[j] === c) {
        score++;
        found = true;
        j++;
        break;
      }
      j++;
    }
    if (!found) return 0;
  }
  return score;
}

// Main App Component
function App() {
  const { exit, size } = useApp();
  const [query, setQuery] = React.useState("");
  const [selectedIndex, setSelectedIndex] = React.useState(0);
  const [allEntries] = React.useState(() => 
    findDesktopFiles()
      .map(parseDesktopFile)
      .filter(Boolean)
      .sort((a, b) => a.name.localeCompare(b.name))
  );

  const filteredEntries = React.useMemo(() => {
    if (query === "") {
      return allEntries;
    } else {
      return allEntries
        .map((e) => ({
          entry: e,
          score: fuzzyMatchScore(query, e.name),
        }))
        .filter((e) => e.score > 0)
        .sort((a, b) => b.score - a.score)
        .map((e) => e.entry);
    }
  }, [allEntries, query]);

  const selectedApp = filteredEntries[selectedIndex];

  // Calculate available height for the list (subtract search bar, status line and borders)
  const terminalHeight = size?.height || process.stdout.rows || 20;
  const terminalWidth = size?.width || process.stdout.columns || 80;
  const availableHeight = Math.max(0, terminalHeight - 8);
  const visibleItems = Math.min(filteredEntries.length, availableHeight);

  // Calculate which items to show (with scrolling support)
  const startIndex = Math.max(0, Math.min(selectedIndex - Math.floor(visibleItems / 2), filteredEntries.length - visibleItems));
  const endIndex = Math.min(startIndex + visibleItems, filteredEntries.length);
  const visibleEntries = filteredEntries.slice(startIndex, endIndex);

  useInput((input, key) => {
    if (key.escape || key.ctrl && input === 'c') {
      exit();
      return;
    }

    if (key.return) {
      if (selectedApp) {
        spawn("sh", ["-c", selectedApp.exec], {
          detached: true,
          stdio: "ignore",
        }).unref();
        exit();
      }
      return;
    }

    if (key.upArrow) {
      setSelectedIndex(prev => Math.max(0, prev - 1));
      return;
    }

    if (key.downArrow) {
      setSelectedIndex(prev => Math.min(filteredEntries.length - 1, prev + 1));
      return;
    }

    if (key.pageUp) {
      setSelectedIndex(prev => Math.max(0, prev - 10));
      return;
    }

    if (key.pageDown) {
      setSelectedIndex(prev => Math.min(filteredEntries.length - 1, prev + 10));
      return;
    }

    // Handle regular text input
    if (input && !key.ctrl && !key.meta) {
      setQuery(prev => prev + input);
      setSelectedIndex(0);
    }

    // Handle backspace
    if (key.backspace || key.delete) {
      setQuery(prev => prev.slice(0, -1));
      setSelectedIndex(0);
    }
  });

  return React.createElement(Box, { 
    flexDirection: "column", 
    height: terminalHeight,
    width: terminalWidth
  }, [
    // Search Input
    React.createElement(Box, { 
      key: "search", 
      borderStyle: "single", 
      borderColor: "green",
      height: 3,
      width: "100%"
    },
      React.createElement(Text, {paddingX: 1}, `Search: ${query}`)
    ),

    React.createElement(Box, { 
      key: "main", 
      flexDirection: "row", 
      flexGrow: 1,
      height: availableHeight + 2
    }, [
      // Applications List
      React.createElement(Box, {
        key: "list",
        borderStyle: "single",
        width: "50%",
        flexDirection: "column",
        borderColor: "gray",
        height: availableHeight + 2
      }, [
        React.createElement(Box, { 
          key: "list-header", 
          borderStyle: "single", 
          borderColor: "gray",
          height: 3
        }, React.createElement(Text, null, " Applications ")),
        
        React.createElement(Box, { 
          key: "list-content", 
          flexDirection: "column", 
          flexGrow: 1,
          height: availableHeight - 1
        }, visibleEntries.map((app, index) => {
          const globalIndex = startIndex + index;
          const isSelected = globalIndex === selectedIndex;
          
          return React.createElement(Box, {
            key: app.file,
            paddingX: 1,
            height: 1
          }, React.createElement(Text, { 
            backgroundColor: isSelected ? "blue" : undefined,
            color: "white",
            bold: false
          }, app.name));
        }).concat(
          filteredEntries.length === 0 ? 
            React.createElement(Box, { 
              key: "no-matches", 
              paddingX: 1,
              height: 1
            }, React.createElement(Text, { color: "red" }, "No matches")) : 
            []
        ))
      ]),

      // Description Preview
      React.createElement(Box, {
        key: "preview",
        borderStyle: "single",
        width: "50%",
        flexDirection: "column",
        borderColor: "gray",
        height: availableHeight + 2
      }, [
        React.createElement(Box, { 
          key: "preview-header", 
          borderStyle: "single", 
          borderColor: "gray",
          height: 3
        }, React.createElement(Text, null, " Description ")),
        
        React.createElement(Box, { 
          key: "preview-content", 
          paddingX: 1, 
          flexGrow: 1,
          height: availableHeight - 1
        }, React.createElement(Text, null, 
          selectedApp ? (selectedApp.comment || "(No description)") : "(No selection)"
        ))
      ])
    ])
  ]);
}

// Render the app
render(React.createElement(App));

