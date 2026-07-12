import { resolve } from 'path';
import { defineConfig, externalizeDepsPlugin } from 'electron-vite';
import react from '@vitejs/plugin-react';

// @bslend/core'un build adimi yok (ham TS kaynagi paylasilir, hot-reload'i
// bozmamak icin) - main/preload surecleri Node'un CJS require'iyla calistigi
// icin bunu "externalize" etmek yerine Vite'in kendisine derletiyoruz.
export default defineConfig({
  main: {
    plugins: [externalizeDepsPlugin({ exclude: ['@bslend/core'] })],
  },
  preload: {
    plugins: [externalizeDepsPlugin({ exclude: ['@bslend/core'] })],
  },
  renderer: {
    resolve: {
      alias: {
        '@renderer': resolve('src/renderer/src'),
      },
    },
    plugins: [react()],
  },
});
