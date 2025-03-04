+++
title = 'Git Configuration of Git Developers'
date = 2025-03-04
draft = false
+++

The following article "How Core Git Developers Configure Git" ([link](https://blog.gitbutler.com/how-git-core-devs-configure-git/)) delves into various Git configuration settings that can enhance the user experience over the default install. Interestingly, these configurations are favoured by the majority core Git developers. This suggests that these changes should be considered as default and may even become so long term. Conversely, you could argue that they benefit power users of `git`, but I personally think they improve my experience a lot, and I certainly wouldn't self classify in that group. For example, I don't think anyone ever doesn't want to create an upstream branch when pushing.

 The author breaks down each suggested setting in detail, outlining the difference with the default behaviour. While I haven't taken all of the suggestions, especially those in the "personal preference" category, the majority make my configuration. The most notable differences revolve around my use of `difftastic`, an external tool, rather than the configuration changes suggested. `difftastic` improves upon Git's default diff tools by being syntax-aware, meaning it understands the structure of code (e.g., functions, loops, and expressions) rather than treating it as plain text. This allows it to highlight meaningful changes—like renamed variables or reordered parameters—while ignoring irrelevant whitespace and formatting differences, making code reviews and debugging more efficient.

### Implementing the Git Configuration in NixOS:

To apply the discussed Git configurations in NixOS, you can define them within the `git` attribute of your NixOS configuration file (`configuration.nix`). Here's how you can incorporate these settings:

```nix
{
  programs = {
    git = {
      enable = true;  # Enables Git support in the system configuration.

      ignores = [      # Specifies global Git ignore patterns.
        "*.swp"        # Ignore Vim swap files.
        ".DS_Store"    # Ignore macOS Finder metadata files.
        ".vscode"      # Ignore VS Code project settings.
        "__pycache__/" # Ignore Python bytecode cache directories.
        "venv/"        # Ignore Python virtual environment directories.
        ".env"         # Ignore environment files (e.g., containing secrets).
      ];

      lfs.enable = true;  # Enables Git Large File Storage (LFS) for handling large files efficiently.
      difftastic.enable = true;  # Enables Difftastic, a syntax-aware diff tool.

      extraConfig = {  # Additional Git configuration settings.
        init.defaultBranch = "main";  # Sets "main" as the default branch name instead of "master".
        merge.conflictstyle = "zdiff3";  # Uses "zdiff3" for merge conflicts, providing more context.
        push.default = "current";  # Pushes the current branch by default instead of requiring explicit naming.
        push.autoSetupRemote = true;  # Automatically sets up tracking branches when pushing for the first time.
        branch.sort = "committerdate";  # Sorts branches by the last commit date.
        rebase.autosquash = true;  # Automatically squashes fixup! and squash! commits during rebase.
        rebase.autostash = true;  # Stashes local changes before rebase and restores them afterward.
        rebase.updateRefs = true;  # Updates remote references when rebasing.
        column.ui = "auto";  # Enables column-based output formatting for certain Git commands when useful.
        fetch.prune = true;  # Automatically prunes deleted remote branches when fetching.
        fetch.all = true;  # Fetches updates from all remotes by default.
        help.autocorrect = "prompt";  # Suggests the closest matching command when a typo is detected.
        core.excludesfile = "[$HOME]/.config/git/ignore";  # Specifies a custom global Git ignore file.
      };
    };
  };
}
```

**Notes:**

- One needs to explicitly state `core.excludesfile` within extraConfig otherwise items listed in `git.ignores` are, ironically, not ignored.
- Enabling `difftastic` in this configuration will automatically install the package.

If you're interested in a fully configured NixOS setup which for a linux desktop and MacOS laptop, with the above optimised Git settings, you can check out my full configuration [here](https://github.com/Alicimo/nixos-desktop).