# Bslend

Aynı yerel ağdaki iOS ve Windows cihazları otomatik olarak bulup aralarında hızlı dosya aktarımı yapan, LocalSend tarzı, cross-platform bir uygulama.

> **Not**: Proje Flutter'dan React/TypeScript'e taşınıyor (mobilde Expo dev-client ile hot-reload geliştirme için). Eski, tamamen çalışan Flutter sürümü `flutter-legacy` branch'inde ve `flutter-v1-backup` tag'inde korunuyor.

## Nasıl çalışır?

- Cihazlar UDP broadcast ile birbirini otomatik keşfeder (IP girmeye gerek yok); bazı ağlarda broadcast engellendiği için unicast `/api/whoami` alt ağ taraması yedek olarak da çalışır.
- Dosya gönderimi iki aşamalıdır: önce alıcıya `/prepare` ile kabul/red sorulur, kabul edilirse dosya `/receive/:sessionId` üzerinden HTTP akışı halinde gönderilir.

## Monorepo yapısı

```
packages/core/    # Paylaşılan TS: sabitler, tipler, saf yardımcı fonksiyonlar (I/O yok, build adımı yok)
apps/mobile/      # Expo (React Native) - iOS, dev-client ile hot-reload
apps/desktop/     # Electron + React - Windows
```

## Geliştirme

```
npm install                              # kökten, tüm workspace'leri kurar

npm run desktop                          # Electron'u dev modda başlatır (Windows)
npm run mobile                           # Expo/Metro'yu başlatır (iOS, dev-client gerekir)
```
