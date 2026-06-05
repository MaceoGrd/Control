# Control

Mini-jeu 2D Godot 4 pour game jam : gardez une balle en équilibre sur une planche inclinable.

## Contrôles

- **A** / **Flèche gauche** : incliner la planche à gauche
- **D** / **Flèche droite** : incliner la planche à droite
- **R** : recommencer

## Lancer le jeu

1. Installer [Godot 4.x](https://godotengine.org/download).
2. Ouvrir Godot et choisir **Import**.
3. Sélectionner le fichier `project.godot` à la racine de ce dépôt.
4. Appuyer sur **F5** (ou le bouton Play) pour lancer `scenes/Main.tscn`.

## Structure

```
scenes/     Scènes du jeu (Main, Ball, Plank, UI)
scripts/    Logique GDScript
assets/     Assets futurs (vide pour l'instant)
export/     Notes et builds d'export itch.io
```

## Export itch.io

Voir `export/ITCHIO.md`.
