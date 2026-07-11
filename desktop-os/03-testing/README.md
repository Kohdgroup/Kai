# KOHD Desktop OS Automated Certification

Run all tests from the repository root:

```bash
./desktop-os/03-testing/run-certification.sh
```

Or provide the profile root explicitly:

```bash
./desktop-os/03-testing/run-certification.sh ./hermes/profiles
```

Run one profile:

```bash
./desktop-os/03-testing/profiles/test-profile.sh ./profiles/usr-neil-riley
```

Reports are written to `desktop-os/03-testing/results/` as JSON. A non-zero exit code means certification failed or the suite could not execute.
