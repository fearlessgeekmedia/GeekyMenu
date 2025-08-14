{
  description = "Example flake showing how to integrate GeekyMenu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Add GeekyMenu as an input
    geekymenu.url = "github:fearlessgeek/geekymenu";
    # Optional: pin to specific version
    # geekymenu.url = "github:fearlessgeek/geekymenu/v1.0.0";

    # For Home Manager integration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, geekymenu, home-manager }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Example 1: Include GeekyMenu in a custom package set
        packages = {
          my-desktop-tools = pkgs.symlinkJoin {
            name = "my-desktop-tools";
            paths = [
              geekymenu.packages.${system}.default
              pkgs.rofi
              pkgs.dmenu
              pkgs.fzf
              # other desktop tools...
            ];
          };

          # Custom wrapper with specific terminal
          geekymenu-terminal = pkgs.writeShellScriptBin "geekymenu-terminal" ''
            ${pkgs.alacritty}/bin/alacritty -e ${geekymenu.packages.${system}.default}/bin/geekymenu
          '';
        };

        # Example 2: Custom development shell with GeekyMenu
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            geekymenu.packages.${system}.default
            nodejs_22
            git
            vim
          ];

          shellHook = ''
            echo "Development environment with GeekyMenu"
            echo "GeekyMenu available at: $(which geekymenu)"
            echo "Try running: geekymenu"
          '';
        };

        # Example 3: App that launches GeekyMenu
        apps = {
          launcher = {
            type = "app";
            program = "${geekymenu.packages.${system}.default}/bin/geekymenu";
          };

          launcher-terminal = {
            type = "app";
            program = "${self.packages.${system}.geekymenu-terminal}/bin/geekymenu-terminal";
          };
        };
      })
    // {
      # Example 4: NixOS configuration using GeekyMenu module
      nixosConfigurations.example-system = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import GeekyMenu NixOS module
          geekymenu.nixosModules.default

          # Your system configuration
          ({ config, pkgs, ... }: {
            # Enable GeekyMenu system-wide
            programs.geekymenu.enable = true;

            # Example: Create a desktop entry for easy access
            environment.systemPackages = [
              (pkgs.makeDesktopItem {
                name = "geekymenu";
                desktopName = "GeekyMenu";
                comment = "Fast application launcher";
                exec = "${config.programs.geekymenu.package}/bin/geekymenu";
                categories = [ "System" "Utility" ];
                terminal = true;
                icon = "applications-system";
              })
            ];

            # Example window manager configurations
            services.xserver = {
              enable = true;

              # i3 configuration
              windowManager.i3 = {
                enable = true;
                extraConfig = ''
                  # Launch GeekyMenu with Super+Space
                  bindsym $mod+space exec --no-startup-id ${config.programs.geekymenu.package}/bin/geekymenu

                  # Alternative: Launch in specific terminal
                  bindsym $mod+shift+space exec --no-startup-id alacritty -e ${config.programs.geekymenu.package}/bin/geekymenu
                '';
              };
            };

            # Sway configuration (Wayland)
            programs.sway = {
              enable = true;
              extraConfig = ''
                # Launch GeekyMenu with Super+Space
                bindsym $mod+space exec ${config.programs.geekymenu.package}/bin/geekymenu
              '';
            };
          })
        ];
      };

      # Example 5: Home Manager configuration
      homeConfigurations.example-user = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          # Import GeekyMenu Home Manager module
          geekymenu.homeManagerModules.default

          # Your home configuration
          ({ config, pkgs, ... }: {
            programs.geekymenu = {
              enable = true;
              keybinding = "Super+space";
            };

            # Example: Integration with window managers
            xsession.windowManager.i3.config.keybindings = {
              "${config.xsession.windowManager.i3.config.modifier}+space" =
                "exec --no-startup-id ${config.programs.geekymenu.package}/bin/geekymenu";
            };

            wayland.windowManager.sway.config.keybindings = {
              "${config.wayland.windowManager.sway.config.modifier}+space" =
                "exec ${config.programs.geekymenu.package}/bin/geekymenu";
            };

            # Example: Create custom scripts
            home.packages = [
              (pkgs.writeShellScriptBin "launcher" ''
                # Custom launcher script
                case "$1" in
                  --terminal)
                    ${pkgs.alacritty}/bin/alacritty -e ${config.programs.geekymenu.package}/bin/geekymenu
                    ;;
                  *)
                    ${config.programs.geekymenu.package}/bin/geekymenu
                    ;;
                esac
              '')
            ];
          })
        ];
      };

      # Example 6: Overlay for adding GeekyMenu to nixpkgs
      overlays.default = final: prev: {
        geekymenu = geekymenu.packages.${final.system}.default;
      };

      # Example 7: Custom derivation that uses GeekyMenu
      packages.x86_64-linux.desktop-environment =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.symlinkJoin {
          name = "my-desktop-environment";
          paths = with pkgs; [
            geekymenu.packages.x86_64-linux.default
            i3
            alacritty
            rofi
            dunst
            picom
          ];

          postBuild = ''
            # Create a custom desktop session
            mkdir -p $out/share/xsessions
            cat > $out/share/xsessions/my-desktop.desktop << EOF
            [Desktop Entry]
            Name=My Desktop Environment
            Comment=Custom desktop with GeekyMenu
            Exec=$out/bin/start-desktop
            Type=Application
            EOF

            # Create startup script
            mkdir -p $out/bin
            cat > $out/bin/start-desktop << EOF
            #!/bin/bash
            exec ${i3}/bin/i3
            EOF
            chmod +x $out/bin/start-desktop
          '';
        };
    };
}
