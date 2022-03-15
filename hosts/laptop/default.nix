#
#  Specific system configuration settings for desktop
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./laptop
#   │        ├─ default.nix *
#   │        └─ hardware-configuration.nix       
#   └─ ./modules
#       └─ ./desktop
#           └─ ./qemu
#               └─ default.nix
#

{ config, pkgs, ... }:

{
  imports =                                 # For now, if applying to other system, swap files
    [(import ./hardware-configuration.nix)] ++            # Current system hardware config @ /etc/nixos/hardware-configuration.nix
    [(import ../../modules/desktop/virtualisation)] ++    # Virtual Machines
    (import ../../modules/hardware);                      # Hardware devices


  boot = {                                  # Boot options
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {                              # EFI Boot
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {                              # Most of grub is set up for dual boot
        enable = true;
        version = 2;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;                 # Find all boot options
        configurationLimit = 2;
      };
      timeout = 1;                          # Grub auto select time
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    interfaces = {
      enp0s25 = {
        # useDHCTP = true;
        ipv4.addresses = [ {
            address = "192.168.0.51";
            prefixLength = 24;
          } ];
        };
      };
      wlo1 = {
        # useDHCP = true;
        ipv4.addresses = [ {                # Ip settings: *.0.51 for laptop
          address = "192.168.0.51";
          prefixLength = 24;
        } ];  
      };
    };
    defaultGateway = "192.168.0.1";
    nameserver = [ "1.1.1.1" ];
  };

  programs = {                              # No xbacklight, this is the alterantive
    dconf.enable = true;
    light.enable = true;
  };

  services = {
    tlp.enable = true;                      # TLP and auto-cpufreq for power management
    auto-cpufreq.enable = true;
    blueman.enable = true;
    xrdp = {
      enable = true;
      defaultWindowManager = "${pkgs.bspwm}/bin/bspwm";
      port = 3390;
      openFirewall = true;
    };
    xserver = {
      libinput = {                          # Trackpad support & gestures
        touchpad = {
          tapping = true;
          scrollMethod = "twofinger";
          naturalScrolling = true;            # The correct way of scrolling
          accelProfile = "adaptive";          # Speed settings
          #accelSpeed = "-0.5";
          disableWhileTyping = true;
        };
      };
      resolutions = [
        { x = 1600; y = 920; }
        { x = 1280; y = 720; }
        { x = 1920; y = 1080; }
      ];
    };
  };
}
