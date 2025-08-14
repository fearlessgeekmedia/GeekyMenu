{
  description = "GeekyMenu - A fast, fuzzy-search application launcher for Linux with a terminal-based UI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        geekymenu = pkgs.buildNpmPackage rec {
          pname = "geekymenu";
          version = "1.2.0";

          src = ./.;

          npmDepsHash = "sha256-8/9gZkV86aT/E7OsXUO8XJXQSAYOy72TLB/iRkgpoL8=";

          dontNpmBuild = true;

          # Make the script executable
          postInstall = ''
            chmod +x $out/lib/node_modules/geekymenu/geekymenu.js
          '';

          meta = with pkgs.lib; {
            description = "A terminal-based application launcher for Linux";
            homepage = "https://github.com/fearlessgeek/geekymenu";
            license = licenses.mit;
            maintainers = [ ];
            platforms = platforms.linux;
            mainProgram = "geekymenu";
          };
        };
      in
      {
        packages = {
          default = geekymenu;
          geekymenu = geekymenu;

          # Test script for NixOS application discovery
          test-nixos-apps = pkgs.writeScriptBin "test-nixos-apps" ''
            #!${pkgs.nodejs_22}/bin/node

            import fs from "fs";
            import os from "os";
            import path from "path";

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
                    continue;
                  }
                }
              }
              return results;
            }

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
            console.log("=======================================================");
            console.log();

            console.log("📁 Scanning application directories:");
            for (const dir of appDirs) {
              const exists = fs.existsSync(dir);
              const status = exists ? "✓" : "✗";
              console.log("  " + status + " " + dir + (exists ? "" : " (not found)"));
            }
            console.log();

            console.log("🔍 Finding .desktop files...");
            const desktopFiles = findDesktopFiles();
            console.log("📊 Found " + desktopFiles.length + " .desktop files total");
            console.log();

            const byDir = {};
            for (const { file, dir } of desktopFiles) {
              if (!byDir[dir]) byDir[dir] = [];
              byDir[dir].push(file);
            }

            console.log("📂 Distribution by directory:");
            for (const [dir, files] of Object.entries(byDir)) {
              console.log("  " + dir + ": " + files.length + " files");
            }
            console.log();

            console.log("📱 Sample applications found:");
            const parsed = desktopFiles
              .slice(0, 10)
              .map(({ file }) => parseDesktopFile(file))
              .filter(Boolean)
              .slice(0, 5);

            for (const app of parsed) {
              console.log("  • " + app.name);
            }

            if (parsed.length === 0) {
              console.log("  ❌ No valid applications found!");
              console.log("  This indicates GeekyMenu won't show any applications.");
            } else {
              console.log("  ... and " + (desktopFiles.length - 5) + " more applications");
            }

            console.log();
            console.log("🎯 Summary:");
            console.log("  Total directories scanned: " + appDirs.length);
            console.log("  Directories that exist: " + Object.keys(byDir).length);
            console.log("  Total .desktop files: " + desktopFiles.length);
            console.log("  Valid applications: " + (parsed.length > 0 ? "Yes" : "No"));

            if (desktopFiles.length === 0) {
              console.log();
              console.log("🚨 ISSUE DETECTED:");
              console.log("  No .desktop files found in any scanned directories.");
              console.log("  GeekyMenu will show 'No matches' because there are no applications to display.");
              console.log();
              console.log("💡 Possible solutions:");
              console.log("  1. Install some applications with 'nix-env -iA nixpkgs.firefox' or similar");
              console.log("  2. Install applications system-wide in your NixOS configuration");
              console.log("  3. Check if applications are installed in other non-standard paths");
              process.exit(1);
            } else {
              console.log();
              console.log("✅ SUCCESS: GeekyMenu should work correctly on this NixOS system!");
              process.exit(0);
            }
          '';

          # Cross-platform compatibility test script
          test-compatibility = pkgs.writeScriptBin "test-compatibility" ''
            #!${pkgs.nodejs_22}/bin/node

            import fs from "fs";
            import os from "os";
            import path from "path";

            const home = os.homedir();
            const username = os.userInfo().username;

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
                      continue;
                    }
                  }
                } catch {
                  continue;
                }
              }
              return results;
            }

            console.log("🧪 GeekyMenu Cross-Platform Compatibility Test");
            console.log("=============================================");
            console.log();

            let totalFiles = 0;
            let totalApps = 0;

            for (const [category, info] of Object.entries(appDirs)) {
              console.log(`📂 ''${info.name}:`);
              let categoryApps = 0;
              for (const dir of info.paths) {
                const exists = fs.existsSync(dir);
                const status = exists ? "✓" : "✗";
                if (exists) {
                  const files = findDesktopFilesInDir(dir);
                  const apps = files.map(parseDesktopFile).filter(Boolean);
                  categoryApps += apps.length;
                  totalApps += apps.length;
                  totalFiles += files.length;
                  console.log(`   ''${status} ''${dir} (''${files.length} files, ''${apps.length} apps)`);
                } else {
                  console.log(`   ''${status} ''${dir} (not found)`);
                }
              }
              if (categoryApps > 0) {
                console.log(`   📊 Total: ''${categoryApps} applications`);
              }
              console.log();
            }

            console.log("📊 Summary:");
            console.log(`   Total applications found: ''${totalApps}`);
            console.log();

            if (totalApps > 0) {
              console.log("✅ GeekyMenu should work on this system!");
            } else {
              console.log("❌ No applications found - install some GUI apps first");
              process.exit(1);
            }
          '';
        };

        apps = {
          default = {
            type = "app";
            program = "${geekymenu}/bin/geekymenu";
          };
          geekymenu = {
            type = "app";
            program = "${geekymenu}/bin/geekymenu";
          };
          test-nixos-apps = {
            type = "app";
            program = "${self.packages.${system}.test-nixos-apps}/bin/test-nixos-apps";
          };
          test-compatibility = {
            type = "app";
            program = "${self.packages.${system}.test-compatibility}/bin/test-compatibility";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_22
            npm-check-updates
          ];

          shellHook = ''
            echo "GeekyMenu development environment"
            echo "Node.js version: $(node --version)"
            echo "npm version: $(npm --version)"
            echo ""
            echo "Available commands:"
            echo "  npm install    - Install dependencies"
            echo "  npm start      - Run the application"
            echo "  ncu            - Check for dependency updates"
          '';
        };

        # NixOS module for system-wide installation
        nixosModules.default = { config, lib, pkgs, ... }:
          with lib;
          let
            cfg = config.programs.geekymenu;
          in
          {
            options.programs.geekymenu = {
              enable = mkEnableOption "GeekyMenu application launcher";

              package = mkOption {
                type = types.package;
                default = self.packages.${system}.default;
                description = "The GeekyMenu package to use";
              };
            };

            config = mkIf cfg.enable {
              environment.systemPackages = [ cfg.package ];
            };
          };

        # Home Manager module for user installation
        homeManagerModules.default = { config, lib, pkgs, ... }:
          with lib;
          let
            cfg = config.programs.geekymenu;
          in
          {
            options.programs.geekymenu = {
              enable = mkEnableOption "GeekyMenu application launcher";

              package = mkOption {
                type = types.package;
                default = self.packages.${system}.default;
                description = "The GeekyMenu package to use";
              };

              keybinding = mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "Super+space";
                description = "Global keybinding to launch GeekyMenu (requires compatible window manager)";
              };
            };

            config = mkIf cfg.enable {
              home.packages = [ cfg.package ];

              # Add example configuration for i3/sway if keybinding is set
              home.file.".config/geekymenu/example-keybinding.txt" = mkIf (cfg.keybinding != null) {
                text = ''
                  To use the keybinding ${cfg.keybinding} with your window manager:

                  For i3wm, add to ~/.config/i3/config:
                  bindsym ${cfg.keybinding} exec --no-startup-id ${cfg.package}/bin/geekymenu

                  For sway, add to ~/.config/sway/config:
                  bindsym ${cfg.keybinding} exec ${cfg.package}/bin/geekymenu

                  For other window managers, consult their documentation.
                '';
              };
            };
          };
      });
}
