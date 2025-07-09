#!/usr/bin/env node

const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawn } = require("child_process");

// Workaround for blessed library in packaged environments
process.on('uncaughtException', (err) => {
  if (err.message.includes('Cannot read properties of undefined (reading \'isAlt\')')) {
    // Silently handle the blessed program.isAlt error
    return;
  }
  // Re-throw other errors
  throw err;
});

const blessed = require("blessed");

// Directories to scan for .desktop files
const home = os.homedir();
const appDirs = [
  "/usr/share/applications",
  "/usr/local/share/applications",
  path.join(home, ".local/share", "applications"),
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

// Main UI
function launchAppLauncher() {
  const allEntries = findDesktopFiles()
    .map(parseDesktopFile)
    .filter(Boolean)
    .sort((a, b) => a.name.localeCompare(b.name));

  let filteredEntries = [...allEntries];
  let currentSelection = 0;

  const screen = blessed.screen({
    smartCSR: true,
    title: "GeekyMenu",
  });

  const input = blessed.textbox({
    parent: screen,
    top: 0,
    height: 3,
    inputOnFocus: true,
    border: "line",
    padding: { left: 1 },
    style: {
      fg: "white",
      bg: "black",
      border: { fg: "gray" },
      focus: { border: { fg: "green" } },
    },
  });

  const list = blessed.list({
    parent: screen,
    top: 3,
    left: 0,
    width: "50%",
    bottom: 0,
    keys: true,
    vi: true,
    mouse: true,
    border: "line",
    label: " Applications ",
    style: {
      selected: { bg: "blue" },
      border: { fg: "gray" },
      focus: { border: { fg: "green" } },
    },
    items: [],
  });

  const preview = blessed.box({
    parent: screen,
    top: 3,
    left: "50%",
    width: "50%",
    bottom: 0,
    border: "line",
    label: " Description ",
    style: {
      fg: "white",
      border: { fg: "gray" },
      focus: { border: { fg: "green" } },
    },
    content: "",
  });

  function refreshList(query = "") {
    if (query === "") {
      filteredEntries = allEntries;
    } else {
      filteredEntries = allEntries
        .map((e) => ({
          entry: e,
          score: fuzzyMatchScore(query, e.name),
        }))
        .filter((e) => e.score > 0)
        .sort((a, b) => b.score - a.score)
        .map((e) => e.entry);
    }

    list.setItems(filteredEntries.map((e) => e.name));
    if (filteredEntries.length > 0) {
      currentSelection = Math.min(currentSelection, filteredEntries.length - 1);
      list.select(currentSelection);
      preview.setContent(filteredEntries[currentSelection].comment || "(No description)");
    } else {
      currentSelection = 0;
      list.select(0);
      preview.setContent("(No matches)");
    }
    screen.render();
  }

  input.on("keypress", (_, key) => {
    const value = input.getValue();
    refreshList(value);

    // Handle navigation keys in input field
    if (["down", "up", "pageup", "pagedown"].includes(key.name)) {
      // Prevent default input behavior for these keys
      if (key.name === "down" && filteredEntries.length > 0) {
        currentSelection = Math.min(currentSelection + 1, filteredEntries.length - 1);
        list.select(currentSelection);
        preview.setContent(filteredEntries[currentSelection].comment || "(No description)");
      } else if (key.name === "up" && filteredEntries.length > 0) {
        currentSelection = Math.max(currentSelection - 1, 0);
        list.select(currentSelection);
        preview.setContent(filteredEntries[currentSelection].comment || "(No description)");
      } else if (key.name === "pageup" && filteredEntries.length > 0) {
        currentSelection = Math.max(currentSelection - 10, 0);
        list.select(currentSelection);
        preview.setContent(filteredEntries[currentSelection].comment || "(No description)");
      } else if (key.name === "pagedown" && filteredEntries.length > 0) {
        currentSelection = Math.min(currentSelection + 10, filteredEntries.length - 1);
        list.select(currentSelection);
        preview.setContent(filteredEntries[currentSelection].comment || "(No description)");
      }
      screen.render();
      return;
    }

    if (key.name === "escape") {
      screen.destroy();
      process.exit(0);
    }
  });

  input.on("submit", () => {
    // Launch the currently selected app when Enter is pressed in input
    if (currentSelection >= 0 && currentSelection < filteredEntries.length) {
      const app = filteredEntries[currentSelection];
      screen.destroy();
      spawn("sh", ["-c", app.exec], {
        detached: true,
        stdio: "ignore",
      }).unref();
    }
  });

  // Handle list navigation properly
  list.on("keypress", (_, key) => {
    if (key.name === "escape") {
      screen.destroy();
      process.exit(0);
    } else if (key.name === "down" && filteredEntries.length > 0) {
      currentSelection = Math.min(currentSelection + 1, filteredEntries.length - 1);
      list.select(currentSelection);
      preview.setContent(filteredEntries[currentSelection].comment || "(No description)");
      screen.render();
    } else if (key.name === "up" && filteredEntries.length > 0) {
      currentSelection = Math.max(currentSelection - 1, 0);
      list.select(currentSelection);
      preview.setContent(filteredEntries[currentSelection].comment || "(No description)");
      screen.render();
    }
  });

  list.on("select", (_, idx) => {
    currentSelection = idx;
    // Launch the selected app
    if (idx >= 0 && idx < filteredEntries.length) {
      const app = filteredEntries[idx];
      screen.destroy();
      spawn("sh", ["-c", app.exec], {
        detached: true,
        stdio: "ignore",
      }).unref();
    }
  });

  list.on("select item", (_, idx) => {
    if (idx >= 0 && idx < filteredEntries.length) {
      const app = filteredEntries[idx];
      preview.setContent(app.comment || "(No description)");
      screen.render();
    }
  });

  screen.key(["C-c", "q"], () => {
    screen.destroy();
    process.exit(0);
  });

  input.focus();
  refreshList("");
  screen.render();
}

launchAppLauncher();

