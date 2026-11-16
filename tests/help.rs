use std::process::Command;

#[test]
fn built_help_is_complete_offline_and_has_one_footer() {
    let bin = env!("CARGO_BIN_EXE_mdevd");
    let mut reference = None;
    for args in [&["-h"][..], &["--help"][..], &["-nCh"][..], &["-v", "bad", "--help"][..]] {
        let output = Command::new(bin).args(args).env_clear().output().unwrap();
        assert_eq!(output.status.code(), Some(0));
        assert!(output.stderr.is_empty());
        let help = String::from_utf8(output.stdout).unwrap();
        if let Some(ref expected) = reference { assert_eq!(&help, expected); }
        else { reference = Some(help); }
    }
    let help = reference.unwrap();
    assert!(help.starts_with("Usage: mdevd [OPTIONS]\n"));
    for option in ["-v verbosity", "-D notif", "-I intake", "-o outputfd", "-O nlgroups", "-b kbufsz", "-f conffile", "-n", "-N", "-s slashsys", "-d slashdev", "-F fwbase", "-C", "-h, --help"] {
        assert!(help.contains(option), "missing {option}");
    }
    assert!(help.contains("MDEVD_COLDPLUG_HELPER"));
    assert!(help.contains("Examples:\n  mdevd -O 4 -f /etc/mdev.conf -C\n"));
    assert_eq!(help.matches("Maintained by Joshua Li:").count(), 1);
    assert!(help.ends_with("Procedure: https://github.com/joshuarli/usr/blob/main/dotfiles/base/.agents/instructions/owned-tools.md\n"));
    assert!(help.contains("Bugs and features: TODO.md in that repository (follow its AGENTS.md).\n"));
}

#[test]
fn invalid_option_keeps_existing_usage_error() {
    let output = Command::new(env!("CARGO_BIN_EXE_mdevd"))
        .arg("--badflag")
        .output().unwrap();
    assert_eq!(output.status.code(), Some(100));
    assert!(output.stdout.is_empty());
    let error = String::from_utf8(output.stderr).unwrap();
    assert!(error.starts_with("mdevd: usage: mdevd "));
    assert!(!error.contains("Maintained by Joshua Li:"));
}
