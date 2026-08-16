# Milky — Mac dev setup (non-admin account)

## Step 0 — check what you already have

Open Terminal and run:

```bash
git --version
xcode-select -p
uname -m          # arm64 = Apple Silicon, x86_64 = Intel
```

If `git --version` prints a version number, you already have git and can skip to
Path A step 2. If it pops up a "command line developer tools" dialog, you don't.

---

## Path A — recommended (needs the admin password *once*, ~5 minutes)

Homebrew only needs `sudo` while installing **itself**. It creates its prefix and
hands ownership to your user account. After that, every `brew install` runs with
no password at all. So you borrow the admin password once and are done forever.

**1. Xcode Command Line Tools** — this is what actually gives you `git`, `clang`,
`make`, and the macOS SDK headers. Everything else depends on it.

```bash
xcode-select --install
```

A GUI dialog appears; the admin enters their password there. ~2 GB download.

**2. Homebrew**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

It will ask for the admin password once, near the start. Then follow the two
"Next steps" lines it prints at the end — they add `brew` to your PATH. On Apple
Silicon that's:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**3. Everything after this needs no password**

```bash
brew install git-lfs cmake node python ripgrep fd jq
```

### The one ongoing catch

GUI apps installed as **casks** (`brew install --cask godot`, `--cask visual-studio-code`)
sometimes shell out to the macOS installer and re-prompt for admin. Workaround:
download those apps' `.zip`/`.dmg` directly and drag them to `~/Applications`
(your own Applications folder — create it if it doesn't exist). No admin needed,
and they work fine there.

---

## Path B — zero admin, ever

Use this if you genuinely cannot get the password even once.

**Do not** install Homebrew into your home folder. It technically works, but
Homebrew's prebuilt binaries ("bottles") are compiled for `/opt/homebrew`
specifically — in any other prefix, every package builds from source, which
needs a compiler you don't have without the Command Line Tools. It's a loop.

Use **pixi** instead. Single binary, installs to `~/.pixi`, no admin, and it
pulls from conda-forge which has ~30k packages including compilers.

```bash
curl -fsSL https://pixi.sh/install.sh | sh
exec $SHELL -l          # reload PATH

pixi global install git cmake node python ripgrep
```

Verify:

```bash
which git        # should point inside ~/.pixi
git --version
```

For per-project pinned toolchains (better than global for a game repo):

```bash
cd ~/Milky
pixi init
pixi add git cmake node
pixi shell       # drops you into a shell with exactly those tools
```

### Game engines without admin

Most Mac game engines ship as a plain `.app` you can drop into `~/Applications`
with no installer and no password:

- **Godot** — download the macOS `.zip` from godotengine.org, unzip, move the app.
- **Unity** — Unity Hub is a `.dmg`; drag-install to `~/Applications` usually works.
- **VS Code** — `.zip` download, drag to `~/Applications`.

---

## Setting up the repo once git works

```bash
cd ~/Milky
git init
git config user.name  "Brad Baker"
git config user.email "bradley.n.baker@gmail.com"
printf '.DS_Store\n' > .gitignore
git add -A && git commit -m "Initial commit"
```

Add engine-specific ignore rules before your first real commit — game projects
generate large import/cache folders (Godot's `.godot/`, Unity's `Library/`) that
should never be committed.
