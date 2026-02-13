# Paket bauen (ohne Binärdatei im Repository)

Dieses Repository enthält **keine ZIP-Datei**, damit PRs/Code-Hosts ohne Binärdatei-Support funktionieren.

## ZIP lokal erstellen

Im Projektordner ausführen:

```bash
zip -r funk-system.zip . -x '.git/*' 'funk-system.zip'
```

Optional Prüfsumme:

```bash
sha256sum funk-system.zip
```
