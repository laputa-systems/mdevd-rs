Prefix: MDEV
Next: 2
### MDEV-1 · P2 · Linux verification stops because ripgrep is unavailable

- **Area:** Verification
- **Where:** tools/check-deps.sh:5; GitHub Actions run 43933357448 job 133531356302
- **Problem:** The build job passes pin checks then exits 127 at tools/check-deps.sh:5: rg: not found, before compiling the help change. The same dependency check passes locally with rg installed. This blocks PR 4 independently of source behavior.
- **Recommendation:** Provide ripgrep through the verification environment's existing dependency setup and rerun the unchanged dependency check and build gate. Do not weaken the dependency assertion.
- **Fix with:** root-cause
- **Effort:** S

