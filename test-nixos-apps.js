#!/usr/bin/env node

import fs from "fs";
import os from "os";
import path from "path";

// Same directories as in geekymenu.js
const home = os.homedir();
const username = os.userInfo().username;
const appDirs = [
  // Traditional FHS paths (works on all Linux distributions)
  "/usr/share/applications",
  "/usr/local/share/applications",
  path.join(home, ".local/share", "applications"),

  // Flatpak paths (system-wide and user-specific)
  "/var/lib/flatpak/exports/share/applications",
  path.join(home, ".local/share/flatpak/exports/share/applications"),

  // NixOS system paths
  "/run/current-system/sw/share/applications",
  "/etc/profiles/per-user/" + username + "/share/applications",

  // Nix user profile paths
  path.join(home, ".nix-profile/share/applications"),
  path.join(home, ".local/state/nix/profiles/profile/share/applications"),

  // Additional Nix paths that might exist
  "/nix/var/nix/profiles/default/share/applications",
  "/run/wrappers/bin/../share/applications",

  // Snap paths (for Ubuntu and other distributions)
  "/snap/bin",
  "/var/lib/snapd/desktop/applications",
  path.join(home, ".local/share/applications/snap"),
];

// Recursively find all .desktop files
function findDesktopFiles() {
  let results = [];
  for (const dir of appDirs) {
    if (!fs.existsSync(dir)) continue;
    const stack = [dir];
    while (stack.length) {
      const current = stack.pop();
      try {
        const files = fs.readdirSync(current);
        for (const file of files) {
          const full = path.join(current, file);
          if (fs.statSync(full).isDirectory()) {
            stack.push(full);
          } else if (file.endsWith(".desktop")) {
            results.push({ file: full, dir });
          }
        }
      } catch (err) {
        // Skip directories we can't read
        continue;
      }
    }
  }
  return results;
}

// Parse name from .desktop file
function parseDesktopFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, "utf8");
    const name = content.match(/^Name=(.+)$/m)?.[1] || null;
    const execRaw = content.match(/^Exec=(.+)$/m)?.[1] || null;
    return name && execRaw ? { name, exec: execRaw } : null;
  } catch {
    return null;
  }
}

console.log("🔍 Testing GeekyMenu Application Discovery on NixOS");
console.log("=".repeat(55));
console.log();

console.log("📁 Scanning application directories:");
for (const dir of appDirs) {
  const exists = fs.existsSync(dir);
  const status = exists ? "✓" : "✗";
  console.log(`${status} ${dir}${exists ? "" : " (not found)"}`);
}
console.log();

console.log("🔍 Finding .desktop files...");
const desktopFiles = findDesktopFiles();

console.log(`📊 Found ${desktopFiles.length} .desktop files total`);
console.log();

// Group by directory
const byDir = {};
for (const { file, dir } of desktopFiles) {
  if (!byDir[dir]) byDir[dir] = [];
  byDir[dir].push(file);
}

console.log("📂 Distribution by directory:");
for (const [dir, files] of Object.entries(byDir)) {
  console.log(`  ${dir}: ${files.length} files`);
}
console.log();

// Parse and show some examples
console.log("📱 Sample applications found:");
const parsed = desktopFiles
  .slice(0, 10)
  .map(({ file }) => parseDesktopFile(file))
  .filter(Boolean)
  .slice(0, 5);

for (const app of parsed) {
  console.log(`  • ${app.name}`);
}

if (parsed.length === 0) {
  console.log("  ❌ No valid applications found!");
  console.log("  This indicates GeekyMenu won't show any applications.");
} else {
  console.log(`  ... and ${desktopFiles.length - 5} more applications`);
}

console.log();
console.log("🎯 Summary:");
console.log(`  Total directories scanned: ${appDirs.length}`);
console.log(`  Directories that exist: ${Object.keys(byDir).length}`);
console.log(`  Total .desktop files: ${desktopFiles.length}`);
console.log(`  Valid applications: ${parsed.length > 0 ? "Yes" : "No"}`);

if (desktopFiles.length === 0) {
  console.log();
  console.log("🚨 ISSUE DETECTED:");
  console.log("  No .desktop files found in any scanned directories.");
  console.log(
    "  GeekyMenu will show 'No matches' because there are no applications to display.",
  );
  console.log();
  console.log("💡 Possible solutions:");
  console.log(
    "  1. Install some applications with 'nix-env -iA nixpkgs.firefox' or similar",
  );
  console.log(
    "  2. Install applications system-wide in your NixOS configuration",
  );
  console.log(
    "  3. Check if applications are installed in other non-standard paths",
  );
  process.exit(1);
} else {
  console.log();
  console.log(
    "✅ SUCCESS: GeekyMenu should work correctly on this NixOS system!",
  );
  process.exit(0);
}
