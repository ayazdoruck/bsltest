# Bslend

Aynı yerel ağdaki iOS ve Windows cihazları otomatik olarak bulup aralarında hızlı dosya aktarımı yapan, LocalSend tarzı, cross-platform bir Flutter uygulaması.

## Nasıl çalışır?

- Cihazlar UDP broadcast ile birbirini otomatik keşfeder (IP girmeye gerek yok).
- Dosya gönderimi iki aşamalıdır: önce alıcıya kabul/red sorulur, kabul edilirse dosya HTTP üzerinden akış halinde gönderilir.
- Aynı Flutter kod tabanı hem iOS hem Windows masaüstünde çalışır.

## Geliştirme

```
flutter pub get
flutter run -d windows   # PC tarafı
flutter run               # bağlı iOS cihazında
```
