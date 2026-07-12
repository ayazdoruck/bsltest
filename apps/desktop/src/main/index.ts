import { app, shell, BrowserWindow } from 'electron';
import { join } from 'path';
import { randomUUID } from 'crypto';
import { electronApp, optimizer, is } from '@electron-toolkit/utils';
import { defaultDeviceName } from '@bslend/core';
import { DiscoveryService } from './discovery';

function createWindow(): void {
  const mainWindow = new BrowserWindow({
    width: 1000,
    height: 700,
    show: false,
    autoHideMenuBar: true,
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      sandbox: false,
    },
  });

  mainWindow.on('ready-to-show', () => {
    mainWindow.show();
  });

  mainWindow.webContents.setWindowOpenHandler((details) => {
    shell.openExternal(details.url);
    return { action: 'deny' };
  });

  if (is.dev && process.env['ELECTRON_RENDERER_URL']) {
    mainWindow.loadURL(process.env['ELECTRON_RENDERER_URL']);
  } else {
    mainWindow.loadFile(join(__dirname, '../renderer/index.html'));
  }
}

app.whenReady().then(() => {
  electronApp.setAppUserModelId('com.example.bslend');

  app.on('browser-window-created', (_, window) => {
    optimizer.watchWindowShortcuts(window);
  });

  // Faz 1 spike: kalici kimlik henuz yok (Faz 4'te electron-store ile
  // eklenecek), simdilik her baslangicta yeni bir id/isim uretiliyor -
  // sadece UDP kesfinin gercekten calistigini dogrulamak icin yeterli.
  const myId = randomUUID();
  const myName = defaultDeviceName(myId, 'windows');
  const discovery = new DiscoveryService(myId, myName, 'windows', (peers) => {
    console.log('[Discovery] Peer listesi guncellendi:', peers);
  });
  discovery.start();

  app.on('before-quit', () => discovery.stop());

  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
