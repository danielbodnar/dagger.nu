#!/usr/bin/env nu
# tests/completions.test.nu — Test suite for dagger.nu completions
#
# Run:
#   nu tests/completions.test.nu
#   nu tests/completions.test.nu --verbose
#   nu tests/completions.test.nu --test sdks

use std/assert
use ../completions/dagger.nu *

# ============================================================================
# Helpers
# ============================================================================

# Assert a list contains an entry with the given value field
def assert-has-value [list: list, expected: string] {
    let found = $list | where value == $expected
    assert ($found | is-not-empty) $"Expected value '($expected)' not found in completions"
}

# Assert every entry in a completion list has non-empty value and description
def assert-well-formed [list: list] {
    assert ($list | is-not-empty) "Completion list must not be empty"
    for entry in $list {
        assert (($entry.value | str length) > 0) $"Empty value in entry: ($entry | to nuon)"
        assert (($entry.description | str length) > 0) $"Empty description for value '($entry.value)'"
    }
}

# ============================================================================
# Tests
# ============================================================================

def "test subcommands" [] {
    let result = nu-complete dagger subcommands
    assert-well-formed $result

    for cmd in [login logout call config core develop functions init install uninstall update query run completion toolchain version help] {
        assert-has-value $result $cmd
    }
}

def "test sdks" [] {
    let result = nu-complete dagger sdks
    assert-well-formed $result
    assert (($result | length) == 3)

    assert-has-value $result "go"
    assert-has-value $result "python"
    assert-has-value $result "typescript"
}

def "test progress formats" [] {
    let result = nu-complete dagger progress
    assert-well-formed $result
    assert (($result | length) == 4)

    for fmt in [auto plain tty dots] {
        assert-has-value $result $fmt
    }
}

def "test models" [] {
    let result = nu-complete dagger models
    assert-well-formed $result
    assert (($result | length) >= 4)

    # Spot-check a few well-known model IDs
    assert-has-value $result "claude-sonnet-4-5"
    assert-has-value $result "gpt-4.1"
    assert-has-value $result "gemini-2.0-flash"
}

def "test licenses" [] {
    let result = nu-complete dagger licenses
    assert-well-formed $result

    for lic in ["Apache-2.0" "MIT" "GPL-3.0" "BSD-3-Clause" "MPL-2.0" "UNLICENSED"] {
        assert-has-value $result $lic
    }
}

def "test shells" [] {
    let result = nu-complete dagger shells
    assert (($result | length) == 4)

    for sh in [bash zsh fish powershell] {
        assert ($sh in $result) $"Shell '($sh)' missing from completions"
    }
}

def "test compat values" [] {
    let result = nu-complete dagger compat
    assert-well-formed $result
    assert (($result | length) == 2)

    assert-has-value $result "latest"
    assert-has-value $result "skip"
}

def "test toolchain subcommands" [] {
    let result = nu-complete dagger toolchain subcommands
    assert-well-formed $result
    assert (($result | length) == 4)

    for sub in [install list uninstall update] {
        assert-has-value $result $sub
    }
}

def "test subcommands are unique" [] {
    let result = nu-complete dagger subcommands
    let unique_count = $result | get value | uniq | length
    assert ($unique_count == ($result | length)) "Subcommands list has duplicates"
}

def "test models are unique" [] {
    let result = nu-complete dagger models
    let unique_count = $result | get value | uniq | length
    assert ($unique_count == ($result | length)) "Models list has duplicates"
}

def "test licenses are unique" [] {
    let result = nu-complete dagger licenses
    let unique_count = $result | get value | uniq | length
    assert ($unique_count == ($result | length)) "Licenses list has duplicates"
}

def "test registered commands" [] {
    # Verify that extern commands are registered in scope after `use`
    let cmds = scope commands | where name =~ "^dagger" | get name

    for expected in [
        "dagger"
        "dagger call"
        "dagger config"
        "dagger develop"
        "dagger functions"
        "dagger init"
        "dagger install"
        "dagger login"
        "dagger logout"
        "dagger query"
        "dagger run"
        "dagger toolchain"
        "dagger toolchain install"
        "dagger toolchain list"
        "dagger toolchain uninstall"
        "dagger toolchain update"
        "dagger version"
    ] {
        assert ($expected in $cmds) $"Command '($expected)' not registered"
    }
}

# ============================================================================
# Runner
# ============================================================================

def main [
    --verbose (-v)     # Print each test name before running
    --test (-t): string # Run only tests matching this substring
] {
    let all_tests = [
        "subcommands"
        "sdks"
        "progress formats"
        "models"
        "licenses"
        "shells"
        "compat values"
        "toolchain subcommands"
        "subcommands are unique"
        "models are unique"
        "licenses are unique"
        "registered commands"
    ]

    let tests = if $test != null {
        $all_tests | where { $in =~ $test }
    } else {
        $all_tests
    }

    print $"Running ($tests | length) tests...\n"

    let results = $tests | each { |name|
        if $verbose { print -n $"  test ($name)... " }
        let outcome = try {
            match $name {
                "subcommands"             => { test subcommands }
                "sdks"                    => { test sdks }
                "progress formats"        => { test progress formats }
                "models"                  => { test models }
                "licenses"                => { test licenses }
                "shells"                  => { test shells }
                "compat values"           => { test compat values }
                "toolchain subcommands"   => { test toolchain subcommands }
                "subcommands are unique"  => { test subcommands are unique }
                "models are unique"       => { test models are unique }
                "licenses are unique"     => { test licenses are unique }
                "registered commands"     => { test registered commands }
            }
            if $verbose { print "✓" }
            {name: $name, passed: true, error: ""}
        } catch { |err|
            if not $verbose { print -n $"  test ($name)... " }
            print $"✗  ($err.msg)"
            {name: $name, passed: false, error: $err.msg}
        }
        $outcome
    }

    let passed = $results | where passed == true | length
    let failed = $results | where passed == false | length

    print $"\n($passed) passed, ($failed) failed"

    if $failed > 0 { exit 1 }
}
