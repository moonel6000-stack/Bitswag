# BitSwag 0.9.0 — prototype Theos rootless

Projet source, **non compilé et non testé**. Comprend `Makefile`, `control`, filtre d'injection, `Tweak.x`, menu UIKit et workflow CI.

## Installation des dépendances
Theos rootless + SDK iOS, Dobby compatible avec arm64e/PAC : `dobby.h` dans `$(THEOS)/vendor/include` et `libdobby` dans `$(THEOS)/vendor/lib`.

## Construction
`make clean package THEOS_PACKAGE_SCHEME=rootless`

## Sécurité
Vérifie `com.wtfapps.apollo16` et `CFBundleShortVersionString == 3.25.3` avant de poser les hooks. Les VA sont appliquées à la base du Mach-O UnityFramework trouvée au runtime. La version ne vérifie **pas** l'empreinte SHA du Mach-O. Tous les toggles sont OFF par défaut. Le hook `VehicleValue` est désactivé (type de retour float). Les méthodes sans signatures suffisamment certaines ne sont pas installées. Il faut vérifier les signatures et les VA avant un test réel. Aucune méthode d'achat intégré n'est ciblée.

La présence de `ARCHS=arm64e` ne garantit pas à elle seule la sûreté PAC ; la bibliothèque Dobby liée doit être validée sur l'appareil cible.
