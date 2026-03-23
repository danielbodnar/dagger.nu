#!/usr/bin/env nu
# tests/completions.test.nu — Test suite for dagger.nu completions
#
# Run:
#   nu tests/completions.test.nu
#   nu tests/completions.test.nu --verbose
#   nu tests/completions.test.nu --test "sdk"

use std/assert

# Top-level use — brings externs and helpers into parser scope so
# scope commands reflects them and helper calls resolve without a subshell.
use ../completions/dagger.nu *

# ============================================================================
# Helpers
# ============================================================================

def assert-has-value [list: list, expected: string] {
    let found = $list | where value == $expected
    assert ($found | is-not-empty) $"Expected value '($expected)' not found"
}

def assert-unique-values [list: list, label: string] {
    let dupes = $list | get value | uniq -d
    assert ($dupes | is-empty) $"($label) has duplicate values: ($dupes | to nuon)"
}

# ============================================================================
# Helper function tests — completion values
# ============================================================================

def "test sdks" [] {
    let result = nu-complete dagger sdks
    assert (($result | length) == 3)
    for v in ["go" "python" "typescript"] { assert-has-value $result $v }
    assert-unique-values $result "sdks"
}

def "test progress formats" [] {
    let result = nu-complete dagger progress
    assert (($result | length) == 4)
    for v in ["auto" "plain" "tty" "dots"] { assert-has-value $result $v }
    assert-unique-values $result "progress"
}

def "test compat values" [] {
    let result = nu-complete dagger compat
    assert (($result | length) == 2)
    for v in ["latest" "skip"] { assert-has-value $result $v }
}

def "test shell names" [] {
    let result = nu-complete dagger shells
    assert (($result | length) == 4)
    for v in ["bash" "zsh" "fish" "powershell"] {
        assert ($v in $result) $"Shell '($v)' missing"
    }
}

def "test license spdx identifiers" [] {
    let result = nu-complete dagger licenses
    for v in ["Apache-2.0" "MIT" "GPL-3.0" "BSD-3-Clause" "MPL-2.0"] {
        assert-has-value $result $v
    }
    assert-unique-values $result "licenses"
}

def "test model ids" [] {
    let result = nu-complete dagger models
    assert (($result | length) >= 4)
    for v in ["claude-sonnet-4-5" "gpt-4.1" "gemini-2.0-flash"] {
        assert-has-value $result $v
    }
    assert-unique-values $result "models"
}

def "test subcommands" [] {
    let result = nu-complete dagger subcommands
    for v in ["init" "develop" "call" "config" "install" "uninstall" "update"
              "query" "run" "login" "logout" "version" "toolchain" "completion"] {
        assert-has-value $result $v
    }
    assert-unique-values $result "subcommands"
}

def "test toolchain subcommands" [] {
    let result = nu-complete dagger toolchain subcommands
    assert (($result | length) == 4)
    for v in ["install" "list" "uninstall" "update"] { assert-has-value $result $v }
    assert-unique-values $result "toolchain subcommands"
}

def "test helpers have descriptions" [] {
    # Every table-form helper should have non-empty descriptions
    let helpers = [
        (nu-complete dagger subcommands)
        (nu-complete dagger sdks)
        (nu-complete dagger progress)
        (nu-complete dagger models)
        (nu-complete dagger licenses)
        (nu-complete dagger compat)
        (nu-complete dagger toolchain subcommands)
    ]
    for list in $helpers {
        for entry in $list {
            assert (($entry.description | str length) > 0) $"Empty description for '($entry.value)'"
        }
    }
}

# ============================================================================
# Extern registration tests — observable module surface
# ============================================================================

def "test top-level commands registered" [] {
    let cmds = scope commands | where name =~ "^dagger" | get name
    for expected in [
        "dagger" "dagger call" "dagger config" "dagger core"
        "dagger develop" "dagger functions" "dagger init"
        "dagger install" "dagger uninstall" "dagger update"
        "dagger login" "dagger logout"
        "dagger query" "dagger q" "dagger run"
        "dagger completion" "dagger version"
    ] {
        assert ($expected in $cmds) $"'($expected)' not registered after use"
    }
}

def "test toolchain commands registered" [] {
    let cmds = scope commands | where name =~ "^dagger toolchain" | get name
    for expected in [
        "dagger toolchain"
        "dagger toolchain install"
        "dagger toolchain list"
        "dagger toolchain uninstall"
        "dagger toolchain update"
    ] {
        assert ($expected in $cmds) $"'($expected)' not registered after use"
    }
}

def "test no duplicate externs" [] {
    let cmds = scope commands | where name =~ "^dagger" | get name
    let dupes = $cmds | uniq -d
    assert ($dupes | is-empty) $"Duplicate externs: ($dupes | to nuon)"
}

# ============================================================================
# mod.nu integration test
# ============================================================================

def "test mod.nu entry point" [] {
    # Verify the root mod.nu re-exports everything from completions/
    # We load it in a subshell to get an isolated scope reading
    let mod_path = ([$env.FILE_PWD ".." "mod.nu"] | path join | path expand)
    let out = ^nu --no-config-file -c $"
        use '($mod_path)' *
        scope commands | where name =~ '^dagger' | get name | to json
    " | from json
    assert ($out | is-not-empty) "mod.nu must re-export dagger commands"
    assert ("dagger" in $out) "'dagger' extern must be reachable via mod.nu"
    assert ("dagger init" in $out) "'dagger init' must be reachable via mod.nu"
}

# ============================================================================
# Runner
# ============================================================================

def main [
    --verbose (-v)      # Print each test name as it runs
    --test (-t): string # Run only tests whose name contains this substring
] {
    let all_tests = [
        "sdks"
        "progress formats"
        "compat values"
        "shell names"
        "license spdx identifiers"
        "model ids"
        "subcommands"
        "toolchain subcommands"
        "helpers have descriptions"
        "top-level commands registered"
        "toolchain commands registered"
        "no duplicate externs"
        "mod.nu entry point"
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
                "sdks"                        => { test sdks }
                "progress formats"            => { test progress formats }
                "compat values"               => { test compat values }
                "shell names"                 => { test shell names }
                "license spdx identifiers"    => { test license spdx identifiers }
                "model ids"                   => { test model ids }
                "subcommands"                 => { test subcommands }
                "toolchain subcommands"       => { test toolchain subcommands }
                "helpers have descriptions"   => { test helpers have descriptions }
                "top-level commands registered" => { test top-level commands registered }
                "toolchain commands registered" => { test toolchain commands registered }
                "no duplicate externs"        => { test no duplicate externs }
                "mod.nu entry point"          => { test mod.nu entry point }
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
