import type { Platform } from './types';

// Varsayilan cihaz adini id'nin ilk 4 karakterinden uretir - eski Flutter
// surumundeki DeviceIdentityService ile ayni desen.
export function defaultDeviceName(id: string, platform: Platform): string {
  const suffix = id.slice(0, 4);
  switch (platform) {
    case 'windows':
      return `Windows PC (${suffix})`;
    case 'ios':
      return `iPhone (${suffix})`;
    case 'android':
      return `Android (${suffix})`;
    case 'macos':
      return `Mac (${suffix})`;
    default:
      return `Device (${suffix})`;
  }
}
