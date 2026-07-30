# dotfiles

Personal configuration for macOS and Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Table of Contents

- [Architecture](#architecture)
- [Package Layout](#package-layout)
- [How Stowing Works](#how-stowing-works)
- [setup.sh Usage](#setupsh-usage)
- [Adding a Common Config](#adding-a-common-config)
- [Adding a Platform-Specific Config](#adding-a-platform-specific-config)
- [XDG Compliance](#xdg-compliance)
- [Corporate Machines](#corporate-machines)
---

## Architecture

This repo uses stow packages to separate configuration along two axes: what's shared
everywhere, and what's specific to a platform or environment. Each package is a
self-contained directory tree that mirrors its target layout relative to `$HOME`.
Stow creates symlinks from `$HOME` into this repo; nothing is copied.

```
~/dotfiles/
├── packages/
│   ├── common/     # shared across every machine
│   ├── darwin/     # macOS only
│   ├── linux/      # Linux only
│   ├── ssh/        # personal machines only (Mac + Linux)
│   └── yubikey/    # personal macOS only
├── setup.sh        # orchestrates which packages get stowed
├── .stow-local-ignore
└── .gitignore
```

`setup.sh` is the single entry point. It detects the current platform via `$OSTYPE`
and stows the correct combination of packages. No manual `stow` invocations are
needed for day-to-day use.

---

## Package Layout

| Package   | Stowed on              | Contents                                                            |
|-----------|-------------------------|-----------------------------------------------------------------------|
| `common`  | every machine           | nvim, tmux, zsh core, functions, base git config                     |
| `darwin`  | every macOS machine     | Homebrew paths, `pbcopy`, BSD `ls`, macOS-only zsh functions          |
| `linux`   | personal Linux only     | `~/.ssh/rc` (agent-forwarding symlink refresh)                       |
| `ssh`     | personal machines only  | SSH config, `allowed_signers`, signing key, `SSH_AUTH_SOCK` export    |
| `yubikey` | personal macOS only     | `sk-askpass`, `sk-helper-wrapper`, launchd agent plist                |

The stow matrix, concretely:

| Package | Personal Mac | Personal Linux | Corp Mac | Corp Linux |
|---------|:---:|:---:|:---:|:---:|
| common  | ✓ | ✓ | ✓ | ✓ |
| darwin  | ✓ | – | ✓ | – |
| linux   | – | ✓ | – | – |
| ssh     | ✓ | ✓ | – | – |
| yubikey | ✓ | – | – | – |

---

## How Stowing Works

Stow mirrors a package's internal directory structure onto `$HOME`. If a package
contains:

```
packages/common/.config/nvim/init.lua
```

Stowing `common` creates:

```
~/.config/nvim/init.lua → ~/dotfiles/packages/common/.config/nvim/init.lua
```

Two things matter for adding new configs correctly:

1. **Packages are flat.** Never nest a platform name as a directory inside a
   package (e.g. `packages/yubikey/darwin/...`). Stow has no concept of platforms;
   a `darwin/` directory at a package root just becomes `~/darwin/` on disk. Platform
   separation happens by choosing which top-level package to stow, not by structure
   inside a package.
2. **Multiple packages can contribute to the same directory.** For example, both
   `common` and `darwin` have a `.config/zsh/functions/` directory. Stow merges the
   individual files from both into `~/.config/zsh/functions/` correctly, as long as
   no two packages define a file with the same name.
---

## setup.sh Usage

```bash
./setup.sh                    # personal machine, auto-detects platform
./setup.sh --corp             # corporate machine (skips ssh, yubikey, linux)
./setup.sh --dry-run          # simulate, no filesystem changes
./setup.sh --clean            # remove all dotfiles-owned symlinks
./setup.sh --clean --corp     # remove only what --corp would have installed
./setup.sh --clean --dry-run  # simulate removal
```

Flags compose. `--dry-run` and `--corp`/`--clean` can be combined freely.

`setup.sh` also runs any required post-install steps after stowing (e.g. reloading
the macOS launchd agent, verifying `~/.ssh/rc` landed correctly on Linux). These are
platform-specific functions inside the script; see `post_install_darwin_personal()`
and `post_install_linux_personal()`.

---

## Adding a Common Config

Use this path for anything that should apply identically on every machine,
regardless of platform or personal/corp status.

1. Create the file under `packages/common/`, at the path it should appear relative
   to `$HOME`. For example, a new zsh function:
```bash
   cat > ~/dotfiles/packages/common/.config/zsh/functions/my-function << 'EOF'
   #!/usr/bin/env zsh
   #autoload
   my-function() {
       echo "hello"
   }
   EOF
```

2. Restow:
```bash
   cd ~/dotfiles
   ./setup.sh
```

3. Verify the symlink landed and the function is available in a new shell:
```bash
   ls -la ~/.config/zsh/functions/my-function
   which my-function
```

For non-zsh config (nvim, tmux, etc.), the process is identical: place the file at
its target-relative path inside `packages/common/`, then restow.

---

## Adding a Platform-Specific Config

Use this path when a config should only apply on one platform (macOS or Linux).

1. Decide which package: `packages/darwin/` or `packages/linux/`.
2. Create the file at its target-relative path inside that package. For example, a
   macOS-only zsh function:
```bash
   cat > ~/dotfiles/packages/darwin/.config/zsh/functions/bundleid << 'EOF'
   #!/usr/bin/env zsh
   #autoload
   bundleid() {
       if [[ -z "$1" ]]; then
           echo "Usage: bundleid <App Name>" >&2
           return 1
       fi
       osascript -e "id of app \"$1\""
   }
   EOF
```

3. Restow:
```bash
   cd ~/dotfiles
   ./setup.sh
```

   Only the package matching the current `$OSTYPE` gets stowed. A file placed in
   `packages/darwin/` never appears on a Linux machine, and vice versa.
 
**If the config needs to exist in both places but with different content** (rather
than existing on one platform only), put a shared entry point in `common` and
branch on `$OSTYPE` inside it, or place platform-specific files under each
package's `zsh.conf.d/` directory, which is sourced automatically:

```
packages/darwin/.config/zsh/zsh.conf.d/01-platform.zsh
packages/linux/.config/zsh/zsh.conf.d/01-platform.zsh
```

Both are sourced by the same loop in `common`'s `.zshrc`:

```bash
for f in "$XDG_CONFIG_HOME/zsh/zsh.conf.d/"*.zsh(N); do
    [[ -r "$f" ]] && source "$f"
done
```

Whichever platform package is stowed determines which `01-platform.zsh` is present.

---

## XDG Compliance

This repo follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/)
consistently:

| Variable | Default | Used for |
|----------|---------|----------|
| `XDG_CONFIG_HOME` | `~/.config` | Configuration files (tracked in this repo) |
| `XDG_DATA_HOME` | `~/.local/share` | Persistent data: plugin manager clones, plugin source (not tracked) |
| `XDG_CACHE_HOME` | `~/.cache` | Regeneratable artifacts, e.g. the generated zsh plugin bundle (not tracked) |
| `XDG_STATE_HOME` | `~/.local/state` | Persistent state, e.g. shell history (not tracked) |

When adding a new tool's configuration, follow the same split: config goes in this
repo under the relevant package; anything generated, cloned, or cached goes outside
the repo at the matching XDG path and is excluded via `.gitignore`.

---

## Corporate Machines

Corporate machines run `./setup.sh --corp`, which stows `common` and the platform
package only. It intentionally skips `ssh`, `yubikey`, and `linux`, since those
carry personal SSH/YubiKey configuration that has no place on an IT-managed machine.

The `resolve_packages()` function in `setup.sh` is the single source of truth for
this split. Both installing and cleaning read from it, so `--clean --corp` always
removes exactly what `--corp` would have installed, no more and no less.

If you're adding a new package and want it excluded from corp machines, add it to
the non-corp branch of `resolve_packages()`:

```bash
resolve_packages() {
    local packages=("common")
    case "$OSTYPE" in
        darwin*)
            packages+=("darwin")
            if ! $CORP; then packages+=("ssh" "yubikey" "my-new-package"); fi
            ;;
        linux-gnu*)
            if ! $CORP; then packages+=("ssh" "linux"); fi
            ;;
    esac
    echo "${packages[@]}"
}
``` 
