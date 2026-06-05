# Export itch.io (Godot 4)

## Prérequis

1. Ouvrir le projet dans Godot 4.x.
2. Aller dans **Project > Export...**
3. Ajouter un preset selon la cible souhaitée.

## Web (recommandé pour itch.io)

1. Preset **Web**.
2. Cocher **Runnable** si disponible.
3. Export Path : `export/build/index.html`
4. Exporter, puis zipper le dossier `export/build/` pour itch.io.

## Desktop (Windows / macOS / Linux)

1. Créer un preset par plateforme.
2. Exporter vers `export/build/`.
3. Zipper le binaire + fichiers associés pour itch.io.

## Notes

- Les fichiers `export_presets.cfg` et `export_credentials.cfg` peuvent être ajoutés plus tard.
- Ne pas versionner de builds finaux lourds dans git si ce n'est pas nécessaire.
