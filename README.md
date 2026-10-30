# BitSwag 0.8.0

Tweak rootless pour BitLife iOS.

## Inclus
- Menu flottant BitSwag.
- Préférence Enabled dans Réglages.
- Export du dump IL2CPP.
- Panneau Money avec champ de montant et diagnostic des classes.

## Limite connue
La modification effective du solde n’est pas activée dans cette version : le dump donne les signatures des méthodes, mais ne permet pas à lui seul d’identifier l’instance du personnage actif. Le bouton Money relance le dump diagnostic et ne modifie aucune sauvegarde.

Compilation : `make package` avec Theos et le SDK iOS configurés.
