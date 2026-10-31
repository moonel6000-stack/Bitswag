# BitSwag 0.9.4 — Theos rootless source

Le workflow ne demande plus `ldid` à APT. Ubuntu 24.04 ne fournit pas ce paquet dans les dépôts utilisés. Il installe ldid depuis Procursus via l'action GitHub épinglée au commit `d5ab465f3a66a4d60a59882b935eb30e18e8d043` (release `v2.1.5-procursus7`).

Dobby reste une dépendance externe obligatoire : fournir une build iOS arm64/arm64e dans `$THEOS/vendor/include/dobby.h` et `$THEOS/vendor/lib/libdobby.a`.

Archive source uniquement : aucun `.deb` n'a été compilé ici. Les hooks, signatures IL2CPP et la compatibilité PAC arm64e restent à valider.
