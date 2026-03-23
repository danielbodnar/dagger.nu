# dagger.nu - Nushell completions for Dagger CLI
#
# Dagger is a tool to run composable workflows in containers.
# https://dagger.io
#
# Author: Daniel Bodnar
# Created: 2026-02-28

# ============================================================================
# Completion Helpers
# ============================================================================

export def "nu-complete dagger subcommands" [] {
    [
        [value description];
        [login         "Log in to Dagger Cloud"]
        [logout        "Log out from Dagger Cloud"]
        [call          "Call one or more functions, interconnected into a pipeline"]
        [config        "Get or set module configuration"]
        [core          "Call a core function"]
        [develop       "Prepare a local module for development"]
        [functions     "List available functions"]
        [init          "Initialize a new module"]
        [install       "Install a dependency"]
        [uninstall     "Uninstall a dependency"]
        [update        "Update a module's dependencies"]
        [query         "Send API queries to a dagger engine"]
        [run           "Run a command in a Dagger session"]
        [completion    "Generate the autocompletion script for a shell"]
        [toolchain     "Manage toolchains (experimental)"]
        [version       "Print dagger version"]
        [help          "Help about any command"]
    ]
}

export def "nu-complete dagger sdks" [] {
    [
        [value description];
        [go         "Go SDK"]
        [python     "Python SDK"]
        [typescript "TypeScript SDK"]
    ]
}

export def "nu-complete dagger progress" [] {
    [
        [value description];
        [auto  "Automatically detect output format (default)"]
        [plain "Plain text output"]
        [tty   "TTY-aware output"]
        [dots  "Dot progress indicator"]
    ]
}

export def "nu-complete dagger models" [] {
    [
        [value description];
        [claude-sonnet-4-5   "Anthropic Claude Sonnet 4.5"]
        [claude-opus-4       "Anthropic Claude Opus 4"]
        [claude-haiku-4-5    "Anthropic Claude Haiku 4.5"]
        [gpt-4.1             "OpenAI GPT-4.1"]
        [gpt-4o              "OpenAI GPT-4o"]
        [gemini-2.0-flash    "Google Gemini 2.0 Flash"]
        [gemini-2.5-pro      "Google Gemini 2.5 Pro"]
    ]
}

export def "nu-complete dagger licenses" [] {
    [
        [value description];
        [Apache-2.0   "Apache License 2.0 (default)"]
        [MIT          "MIT License"]
        [GPL-3.0      "GNU General Public License v3.0"]
        [BSD-3-Clause "BSD 3-Clause License"]
        [MPL-2.0      "Mozilla Public License 2.0"]
        [AGPL-3.0     "GNU Affero General Public License v3.0"]
        [UNLICENSED   "No license"]
    ]
}

export def "nu-complete dagger shells" [] {
    [bash zsh fish powershell]
}

export def "nu-complete dagger compat" [] {
    [
        [value description];
        [latest "Use the latest engine API version (default)"]
        [skip   "Skip compatibility check"]
    ]
}

export def "nu-complete dagger toolchain subcommands" [] {
    [
        [value description];
        [install   "Install a toolchain to the current module"]
        [list      "List all toolchains"]
        [uninstall "Uninstall a toolchain"]
        [update    "Update toolchains"]
    ]
}

# ============================================================================
# Shared inherited flags (used across all subcommands)
# ============================================================================
# These appear as INHERITED OPTIONS in dagger --help output

# ============================================================================
# Top-level command
# ============================================================================

export extern main [
    subcommand?: string@"nu-complete dagger subcommands"
    --allow-llm: string           # URLs of remote modules allowed to access LLM APIs, or 'all'
    --auto-apply(-y)              # Automatically apply changes when a changeset is returned
    --command(-c): string         # Execute a dagger shell command
    --debug(-d)                   # Show debug logs and full verbosity
    --eager-runtime               # Load module runtime eagerly
    --interactive(-i)             # Spawn a terminal on container exec failure
    --interactive-command: string # Change the default command for interactive mode
    --mod(-m): string             # Module reference (local path or remote git repo)
    --model: string@"nu-complete dagger models" # LLM model to use
    --no-exit(-E)                 # Leave the TUI running after completion
    --no-mod(-M)                  # Don't automatically load a module
    --progress: string@"nu-complete dagger progress" # Progress output format
    --quiet(-q)                   # Reduce verbosity
    --silent(-s)                  # Do not show progress at all
    --verbose(-v)                 # Increase verbosity (-vv or -vvv for more)
    --web(-w)                     # Open trace URL in a web browser
    --help(-h)                    # Show help
]

# ============================================================================
# Cloud Commands
# ============================================================================

export extern "dagger login" [
    --debug(-d)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger logout" [
    --debug(-d)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

# ============================================================================
# Module Commands
# ============================================================================

export extern "dagger call" [
    ...args: string               # Function pipeline to call
    --allow-llm: string           # URLs of remote modules allowed to access LLM APIs
    --auto-apply(-y)              # Automatically apply changes
    --debug(-d)
    --eager-runtime
    --interactive(-i)
    --interactive-command: string
    --mod(-m): string
    --no-exit(-E)
    --no-mod(-M)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger config" [
    --allow-llm: string
    --debug(-d)
    --eager-runtime
    --json                        # Output in JSON format
    --mod(-m): string
    --no-exit(-E)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger core" [
    ...args: string               # Core function to call
    --allow-llm: string
    --auto-apply(-y)
    --debug(-d)
    --eager-runtime
    --interactive(-i)
    --interactive-command: string
    --mod(-m): string
    --no-exit(-E)
    --no-mod(-M)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger develop" [
    --allow-llm: string
    --compat: string@"nu-complete dagger compat" # Engine API version to target
    --debug(-d)
    --eager-runtime
    --interactive(-i)
    --interactive-command: string
    --license: string@"nu-complete dagger licenses" # SPDX license identifier
    --mod(-m): string
    --no-exit(-E)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --recursive(-r)               # Develop recursively into local dependencies
    --sdk: string@"nu-complete dagger sdks" # Dagger SDK to install
    --silent(-s)
    --source: string              # Source directory used by the installed SDK
    --verbose(-v)
    --web(-w)
    --with-self-calls             # Enable self-calls capability (experimental)
    --without-self-calls          # Disable self-calls capability
    --help(-h)
]

export extern "dagger functions" [
    ...args: string               # Filter functions
    --allow-llm: string
    --debug(-d)
    --eager-runtime
    --json                        # Output in JSON format
    --mod(-m): string
    --no-exit(-E)
    --no-mod(-M)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger init" [
    path?: path                   # Directory to initialize the module in
    --allow-llm: string
    --blueprint: string           # Reference another module as blueprint
    --debug(-d)
    --eager-runtime
    --include: string             # Paths to include when loading the module
    --interactive(-i)
    --interactive-command: string
    --license: string@"nu-complete dagger licenses"
    --mod(-m): string
    --name: string                # Name of the new module
    --no-exit(-E)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --sdk: string@"nu-complete dagger sdks"
    --silent(-s)
    --source: string              # Source directory used by the installed SDK
    --verbose(-v)
    --web(-w)
    --with-self-calls             # Enable self-calls capability (experimental)
    --help(-h)
]

export extern "dagger install" [
    module: string                # Module reference to install (e.g. github.com/org/repo@v1.0)
    --allow-llm: string
    --compat: string@"nu-complete dagger compat"
    --debug(-d)
    --eager-runtime
    --interactive(-i)
    --interactive-command: string
    --mod(-m): string
    --name(-n): string            # Name to use for the dependency
    --no-exit(-E)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger uninstall" [
    module: string                # Module name to uninstall
    --allow-llm: string
    --debug(-d)
    --eager-runtime
    --interactive(-i)
    --interactive-command: string
    --mod(-m): string
    --no-exit(-E)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger update" [
    ...modules: string            # Modules to update (defaults to all)
    --allow-llm: string
    --compat: string@"nu-complete dagger compat"
    --debug(-d)
    --eager-runtime
    --interactive(-i)
    --interactive-command: string
    --mod(-m): string
    --no-exit(-E)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

# ============================================================================
# Execution Commands
# ============================================================================

export extern "dagger query" [
    operation?: string            # GraphQL operation name
    --allow-llm: string
    --debug(-d)
    --doc: path                   # Read query from file
    --eager-runtime
    --interactive(-i)
    --interactive-command: string
    --mod(-m): string
    --no-exit(-E)
    --no-mod(-M)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --var: string                 # Query variable in key=value format
    --var-json: string            # Query variables in JSON format
    --verbose(-v)
    --web(-w)
    --help(-h)
]

# Alias: dagger q
export extern "dagger q" [
    operation?: string
    --allow-llm: string
    --debug(-d)
    --doc: path
    --eager-runtime
    --mod(-m): string
    --no-mod(-M)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --var: string
    --var-json: string
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger run" [
    ...args: string               # Command to run in a Dagger session
    --allow-llm: string
    --debug(-d)
    --eager-runtime
    --interactive(-i)
    --interactive-command: string
    --mod(-m): string
    --no-exit(-E)
    --no-mod(-M)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

# ============================================================================
# Additional Commands
# ============================================================================

export extern "dagger completion" [
    shell: string@"nu-complete dagger shells" # Shell to generate completion for
    --help(-h)
]

export extern "dagger version" [
    --help(-h)
]

# ============================================================================
# Toolchain (experimental)
# ============================================================================

export extern "dagger toolchain" [
    subcommand?: string@"nu-complete dagger toolchain subcommands"
    --debug(-d)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger toolchain install" [
    toolchain: string             # Toolchain to install
    --debug(-d)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger toolchain list" [
    --debug(-d)
    --json                        # Output in JSON format
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger toolchain uninstall" [
    toolchain: string             # Toolchain to uninstall
    --debug(-d)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]

export extern "dagger toolchain update" [
    ...toolchains: string         # Toolchains to update (defaults to all)
    --debug(-d)
    --progress: string@"nu-complete dagger progress"
    --quiet(-q)
    --silent(-s)
    --verbose(-v)
    --web(-w)
    --help(-h)
]
