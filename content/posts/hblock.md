+++
title = 'Local adblocking via hblock'
date = 2025-03-06
draft = false
+++

At home, I run two AdGuard instances that all network traffic is routed through. These catch the majority of ads, tracking attempts, and malware requests originating from my home network, including those from IoT devices like our smart TV. However, my laptop is often outside this network, and since it’s a company device, I’m unwilling to give it access to my tailnet which means I can't use an exit node within my home network. This leaves me needing a reliable ad-blocking solution for when I’m away.

As a Firefox user, I’m currently unaffected by the Manifest V3 changes being enforced on Chrome and its derivatives, so uBlock Origin effectively covers most of my needs. However, my workflow sometimes involves web scraping, which requires me to use headless Chrome sessions. In such cases, I’d prefer a solution that blocks ads and trackers at the system level, filtering all outgoing requests from my device.

### Enter hBlock

[hBlock](https://github.com/hectorm/hblock) provides a simple yet effective approach to system-wide ad and tracker blocking. It works by modifying the `/etc/hosts` file, redirecting requests to flagged domains to `localhost`, causing them to fail. hBlock compiles these domains from well-known block lists, including those used by uBlock Origin and AdGuard, deduplicates them, and then replaces the existing hosts file. The resulting hosts file is currently nearly 500,000 lines long.

This raised a concern: a quick Google search suggests that the hosts file is scanned sequentially rather than using a key-value lookup, which could impact response times. I plan to test whether this introduces any noticeable performance degradation.

### Installation and Automation

hBlock can be easily installed using `nix`, but by default, it does not automatically update the hosts file—you need to manually run `hblock` after your configuration is applied. Additionally, it does not keep the hosts file updated as new domains are added to block lists, requiring periodic rerunning.

To address this, I automated the process in a `nix-darwin` deployment by setting up a LaunchAgent to run `hblock` periodically. Here’s the configuration snippet:

```nix
{ config, pkgs, home-manager, ... }:

{
  home-manager = {
    # Install hblock using home-manager
    home.packages = with pkgs; [ hblock ];

    # Define a LaunchAgent to run hblock periodically
    launchd.agents.hblock = {
      enable = true;
      config = {
        Program = "${pkgs.hblock}/bin/hblock";
        StartInterval = 86400;  # Run once per day
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/hblock.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/hblock-error.log";
      };
    };
  };
}
```

This ensures that `hblock` runs automatically every day, keeping the hosts file up to date without manual intervention. If you're on NixOS, you can achieve the same result with a `systemd` service.

For anyone looking to implement system-wide ad-blocking without relying on browser extensions, hBlock offers a lightweight and effective solution.