# dagger.nu

Nushell completions and utilities for the [Dagger](https://dagger.io) container workflow CLI.

## Features

- Tab completion for all Dagger subcommands with descriptions
- Flag completions for every command, including inherited global flags
- Contextual value completions for:
  - `--sdk` → `go`, `python`, `typescript`
  - `--progress` → `auto`, `plain`, `tty`, `dots`
  - `--model` → Claude, GPT, Gemini model IDs
  - `--license` → SPDX identifiers (Apache-2.0, MIT, …)
  - `--compat` → `latest`, `skip`
  - `dagger completion` → shell names
  - `dagger toolchain` → subcommands

## Coverage

| Command group | Commands |
|---|---|
| Cloud | `login`, `logout` |
| Module | `call`, `config`, `core`, `develop`, `functions`, `init`, `install`, `uninstall`, `update` |
| Execution | `query` (alias `q`), `run` |
| Toolchain | `toolchain install`, `toolchain list`, `toolchain uninstall`, `toolchain update` |
| Other | `completion`, `version` |

## Installation

### With [nupm](https://github.com/nushell/nupm)

```nushell
nupm install --path .
```

### Manual

Clone the repo, then add to `config.nu`:

```nushell
use /path/to/dagger.nu/completions/dagger.nu *
```

## Usage

After installation, tab completion is automatic:

```
dagger <Tab>               # all subcommands with descriptions
dagger init --sdk <Tab>    # go / python / typescript
dagger --progress <Tab>    # auto / plain / tty / dots
dagger --model <Tab>       # claude-sonnet-4-5 / gpt-4.1 / …
dagger toolchain <Tab>     # install / list / uninstall / update
```

## Requirements

- Nushell ≥ 0.110.0
- Dagger CLI installed (`dagger` in PATH)

## License

MIT
