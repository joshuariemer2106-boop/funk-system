# Local packaging (no binary files in repo)

This repository intentionally does **not** commit `funk-system.zip` or checksum files,
so PR systems that reject binary artifacts can still be used.

## Build ZIP locally

Run in the project root:

```bash
zip -r funk-system.zip . -x '.git/*' 'funk-system.zip'
```

## Optional checksum

```bash
sha256sum funk-system.zip
```
