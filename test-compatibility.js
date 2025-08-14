#!/usr/bin/env node

import fs from "fs";
import os from "os";
import path from "path";

// Cross-platform application directory test for GeekyMenu
// Tests compatibility across traditional Linux, NixOS, Flatpak, and Snap

const home = os.homedir();
const username = os.userInfo().username;

// All application directories that GeekyMenu scans
const appDirs = {
  traditional: {
    name: "Traditional Linux (FHS)",
    paths: [
      "/usr/share/applications",
      "/usr/local/share/applications",
      path.join(home, ".local/share", "applications"),
    ],
  },
  flatpak: {
    name: "Flatpak Applications",
    paths: [
      "/var/lib/flatpak/exports/share/applications",
      path.join(home, ".local/share/flatpak/exports/share/applications"),
    ],
  },
  snap: {
    name: "Snap Applications",
    paths: [
      "/snap/bin",
      "/var/lib/snapd/desktop/applications",
      path.join(home, ".local/share/applications/snap"),
    ],
  },
  nixos: {
    name: "NixOS/Nix Packages",
    paths: [
      "/run/current-system/sw/share/applications",
      "/etc/profiles/per-user/" + username + "/share/applications",
      path.join(home, ".nix-profile/share/applications"),
      path.join(home, ".local/state/nix/profiles/profile/share/applications"),
      "/nix/var/nix/profiles/default/share/applications",
      "/run/wrappers/bin/../share/applications",
    ],
  },
};

// Parse a desktop file to extract basic info
function parseDesktopFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, "utf8");
    const name = content.match(/^Name=(.+)$/m)?.[1] || null;
    const comment = content.match(/^Comment=(.+)$/m)?.[1] || "";
    const execRaw = content.match(/^Exec=(.+)$/m)?.[1] || null;
    const execClean = execRaw?.replace(/ *%[fFuUdDnNickvm]/g, "") || null;
    return name && execClean ? { name, comment, exec: execClean } : null;
  } catch {
    return null;
  }
}

// Find .desktop files in a directory recursively
function findDesktopFilesInDir(dir) {
  if (!fs.existsSync(dir)) return [];

  let results = [];
  const stack = [dir];

  while (stack.length) {
    const current = stack.pop();
    try {
      const files = fs.readdirSync(current);
      for (const file of files) {
        const full = path.join(current, file);
        try {
          if (fs.statSync(full).isDirectory()) {
            stack.push(full);
          } else if (file.endsWith(".desktop")) {
            results.push(full);
          }
        } catch {
          // Skip files we can't stat
          continue;
        }
      }
    } catch {
      // Skip directories we can't read
      continue;
    }
  }

  return results;
}

// Detect the current platform/distribution
function detectPlatform() {
  const platform = { name: "Unknown", features: [] };

  // Check for NixOS
  if (fs.existsSync("/etc/nixos") || fs.existsSync("/run/current-system")) {
    platform.name = "NixOS";
    platform.features.push("nix");
  } else if (fs.existsSync("/etc/debian_version")) {
    platform.name = "Debian/Ubuntu";
    platform.features.push("apt");
  } else if (fs.existsSync("/etc/redhat-release")) {
    platform.name = "Red Hat/Fedora";
    platform.features.push("rpm");
  } else if (fs.existsSync("/etc/arch-release")) {
    platform.name = "Arch Linux";
    platform.features.push("pacman");
  } else {
    platform.name = "Generic Linux";
  }

  // Check for package managers
  if (fs.existsSync("/var/lib/flatpak") || fs.existsSync(path.join(home, ".local/share/flatpak"))) {
    platform.features.push("flatpak");
  }
  if (fs.existsSync("/var/lib/snapd") || fs.existsSync("/snap")) {
    platform.features.push("snap");
  }
  if (fs.existsSync("/nix")) {
    platform.features.push("nix");
  }

  return platform;
}

// Main test function
function runCompatibilityTest() {
  console.log("🧪 GeekyMenu Cross-Platform Compatibility Test");
  console.log("=============================================");
  console.log();

  const platform = detectPlatform();
  console.log(`🖥️  Platform: ${platform.name}`);
  console.log(`📦 Package managers: ${platform.features.join(", ") || "none detected"}`);
  console.log();

  let totalFiles = 0;
  let totalApps = 0;
  const results = {};

  // Test each category
  for (const [category, info] of Object.entries(appDirs)) {
    console.log(`📂 ${info.name}:`);
    let categoryFiles = 0;
    let categoryApps = 0;
    const foundPaths = [];

    for (const dir of info.paths) {
      const exists = fs.existsSync(dir);
      const status = exists ? "✓" : "✗";

      if (exists) {
        const files = findDesktopFilesInDir(dir);
        const apps = files.map(parseDesktopFile).filter(Boolean);
        categoryFiles += files.length;
        categoryApps += apps.length;
        foundPaths.push({ dir, files: files.length, apps: apps.length });
        console.log(`   ${status} ${dir} (${files.length} files, ${apps.length} apps)`);
      } else {
        console.log(`   ${status} ${dir} (not found)`);
      }
    }

    results[category] = { files: categoryFiles, apps: categoryApps, paths: foundPaths };
    totalFiles += categoryFiles;
    totalApps += categoryApps;

    if (categoryApps > 0) {
      console.log(`   📊 Total: ${categoryFiles} files, ${categoryApps} applications`);
    }
    console.log();
  }

  // Summary
  console.log("📊 Summary:");
  console.log(`   Total .desktop files found: ${totalFiles}`);
  console.log(`   Total valid applications: ${totalApps}`);
  console.log();

  // Platform-specific recommendations
  console.log("💡 Recommendations:");

  if (totalApps === 0) {
    console.log("   ❌ No applications found! GeekyMenu will show 'No matches'");
    console.log();
    console.log("   Install some applications:");

    if (platform.features.includes("nix")) {
      console.log("   • Nix: nix-env -iA nixpkgs.firefox nixpkgs.chromium");
    }
    if (platform.features.includes("flatpak")) {
      console.log("   • Flatpak: flatpak install org.mozilla.firefox");
    }
    if (platform.features.includes("snap")) {
      console.log("   • Snap: snap install firefox");
    }
    if (platform.name.includes("Ubuntu") || platform.name.includes("Debian")) {
      console.log("   • APT: sudo apt install firefox chromium-browser");
    }
    if (platform.name.includes("Fedora") || platform.name.includes("Red Hat")) {
      console.log("   • DNF: sudo dnf install firefox chromium");
    }
    if (platform.name.includes("Arch")) {
      console.log("   • Pacman: sudo pacman -S firefox chromium");
    }
  } else {
    console.log(`   ✅ Found ${totalApps} applications - GeekyMenu should work great!`);

    // Show breakdown by source
    console.log();
    console.log("   📋 Applications by source:");
    for (const [category, data] of Object.entries(results)) {
      if (data.apps > 0) {
        console.log(`   • ${appDirs[category].name}: ${data.apps} apps`);
      }
    }
  }

  console.log();

  // Sample applications from each category
  console.log("🎯 Sample Applications Found:");
  let samplesShown = 0;

  for (const [category, data] of Object.entries(results)) {
    if (data.apps === 0) continue;

    console.log(`   ${appDirs[category].name}:`);

    for (const pathInfo of data.paths) {
      if (pathInfo.apps === 0) continue;

      const files = findDesktopFilesInDir(pathInfo.dir);
      const apps = files.map(parseDesktopFile).filter(Boolean).slice(0, 3);

      for (const app of apps) {
        console.log(`     • ${app.name}${app.comment ? " - " + app.comment : ""}`);
        samplesShown++;
        if (samplesShown >= 10) break;
      }
      if (samplesShown >= 10) break;
    }
    if (samplesShown >= 10) break;
  }

  if (samplesShown === 0) {
    console.log("   (No applications to display)");
  } else if (totalApps > samplesShown) {
    console.log(`   ... and ${totalApps - samplesShown} more applications`);
  }

  console.log();

  // Compatibility verdict
  console.log("🏁 Compatibility Verdict:");

  const hasTraditional = results.traditional.apps > 0;
  const hasFlatpak = results.flatpak.apps > 0;
  const hasSnap = results.snap.apps > 0;
  const hasNixOS = results.nixos.apps > 0;

  console.log(`   Traditional Linux support: ${hasTraditional ? "✅ Working" : "⚠️  No apps found"}`);
  console.log(`   Flatpak support: ${hasFlatpak ? "✅ Working" : "⚠️  No apps found"}`);
  console.log(`   Snap support: ${hasSnap ? "✅ Working" : "⚠️  No apps found"}`);
  console.log(`   NixOS support: ${hasNixOS ? "✅ Working" : "⚠️  No apps found"}`);

  console.log();

  if (totalApps > 0) {
    console.log("🎉 GeekyMenu is compatible with your system!");
    console.log(`   Launch with: geekymenu`);
    console.log(`   Debug with: geekymenu --debug`);
  } else {
    console.log("⚠️  GeekyMenu needs applications to be useful.");
    console.log("   Install some GUI applications and run this test again.");
  }

  return totalApps > 0 ? 0 : 1;
}

// Run the test
process.exit(runCompatibilityTest());
