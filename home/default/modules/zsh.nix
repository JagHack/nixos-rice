{ config, pkgs, ... }:
# ZSH — declarative shell configuration via Home Manager programs.zsh.
# oh-my-zsh is managed by nix; custom prompt/alias/env files via home.file.
{
  programs.zsh = {
    enable = true;

    history = {
      size = 1000;
      save = 1000;
      path = "${config.home.homeDirectory}/.histfile";
    };

    oh-my-zsh = {
      enable = true;
      theme   = "robbyrussell";
      plugins = [ "git" ];
    };

    initContent = ''
      # Custom configurations
      source ~/.zshcustom/aliases.zsh
      source ~/.zshcustom/env.zsh
      source ~/.zshcustom/appearance.zsh

      # zoxide smart cd
      eval "$(zoxide init zsh)"

      # Show fastfetch on new terminal
      fastfetch

      # Extra PATH entries
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"

      # Editor for SSH sessions
      if [[ -n $SSH_CONNECTION ]]; then
        export EDITOR='nvim'
      fi
    '';

  };
  # Aliases live in ~/.zshcustom/aliases.zsh which is sourced above.

  # zsh custom helper files
  home.file = {
    ".zshcustom/aliases.zsh".source   = ../dotfiles/zsh/aliases.zsh;
    ".zshcustom/env.zsh".source       = ../dotfiles/zsh/env.zsh;
    ".zshcustom/appearance.zsh".source = ../dotfiles/zsh/appearance.zsh;
  };
}
