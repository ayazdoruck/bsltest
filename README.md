# BSL TCP Test — Windows'ta yazilan, bulutta derlenen iOS test uygulamasi

Ayni Wi-Fi'deki bilgisayarinda calisan sunucuya (varsayilan `192.168.0.16:9339`)
ham TCP soketiyle baglanan, byte gonderip alan minik bir Flutter uygulamasi.
Deney/ogrenme amacli.

## Nasil calisir

```
Windows'ta kod (bu repo)  ->  GitHub Actions (macOS) imzasiz .ipa derler  ->  Sideloadly imzalar  ->  iPhone
```

Windows'a Flutter kurmana GEREK YOK. Derleme bulutta olur.

## Adimlar

### 1) GitHub'a yukle
- github.com'da yeni bir repo ac (private olabilir).
- Bu klasoru (`bsltest-ios`) o repoya push et:
  ```
  git init
  git add .
  git commit -m "bsl tcp test"
  git branch -M main
  git remote add origin https://github.com/<kullanici>/<repo>.git
  git push -u origin main
  ```

### 2) Derlemeyi bekle / indir
- Repo'da **Actions** sekmesine git. `Build iOS (unsigned IPA)` otomatik calisir
  (calismazsa `Run workflow` ile elle tetikle).
- Bitince en altta **Artifacts > bsltest-unsigned-ipa** dosyasini indir, zip'ten
  `bsltest-unsigned.ipa`'yi cikar.

### 3) Sideload et
- `bsltest-unsigned.ipa`'yi **Sideloadly**'ye surukle, ucretsiz Apple ID'nle imzala, kur.

### 4) Test et
- Sunucuyu calistir (PC'de): `python Core.py` (0.0.0.0:9339 dinler).
- iPhone'u ayni Wi-Fi'ye bagla.
- Uygulamayi ac -> **BAGLAN**.
- iOS ilk seferde **"Yerel Ag" izni** ister -> **izin ver** (yoksa baglanti kurulamaz).
- Baglanti kurulunca log'da `BAGLANDI` gorursun. **GONDER** ile byte yollarsin.

## Notlar

- Bu uygulama Brawl Stars **degildir** — sadece senin sunucuna baglanip byte
  gonderip alan bir test araci. Supercell protokolunu (7 byte header, sifreleme)
  eklemek istersen `ci/main.dart` icinde `_send`/RX kismini gelistirebilirsin.
- IP degisirse uygulama icindeki Host alanindan degistir (yeniden derlemeye gerek yok).
- BSDS sunucusu gelen "merhaba sunucu" byte'larini kendi protokolu sanip hata
  verebilir; onemli olan **TCP baglantisinin kurulmasi** (LAN erisimi kaniti).
  Duz bir echo testi istersen PC'de basit bir echo server da calistirabilirsin.

## Dosyalar
- `ci/main.dart` — uygulama kodu (TCP istemci + arayuz).
- `.github/workflows/build-ios.yml` — bulutta imzasiz .ipa ureten is akisi.
