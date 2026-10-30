# BitSwag 0.9.2 — source Theos rootless

Correction du workflow CI : le runner est désormais Ubuntu 24.04 et les dépendances Linux sont installées avec `apt-get` (plus aucune commande `brew`).

## Dépendances
Le projet source continue de lier Dobby. Le workflow vérifie donc la présence de `dobby.h` et d'une `libdobby.a` compilée pour iOS arm64/arm64e dans `$THEOS/vendor`. Cette dépendance n'est pas téléchargée automatiquement et doit être fournie par le mainteneur.

Le workflow télécharge aussi le dépôt officiel Theos SDKs et installe le SDK iPhoneOS disponible.

## Lancer
GitHub → Actions → Build BitSwag → Run workflow.

## Important
Archive source uniquement. Aucun `.deb` n'a été compilé ni testé ici. Le contrôle de version et les offsets restent expérimentaux. L'architecture arm64e ne garantit pas à elle seule la sûreté PAC. Aucun hook IAP n'est ajouté.
