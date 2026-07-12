// Saf yardimcilar: bir yerel IPv4 adresinden /24 varsayimiyla yayin adresi
// ve tarama adaylari uretir. I/O yok - soket/HTTP islemleri her app'in kendi
// platform katmaninda yapilir.

export function directedBroadcastAddress(localIp: string): string | null {
  const parts = localIp.split('.');
  if (parts.length !== 4) return null;
  return `${parts[0]}.${parts[1]}.${parts[2]}.255`;
}

export function subnetPrefix(localIp: string): string | null {
  const parts = localIp.split('.');
  if (parts.length !== 4) return null;
  return `${parts[0]}.${parts[1]}.${parts[2]}`;
}

// Bir /24 alt agindaki 254 aday IP'yi (kendi adreslerimiz haric) uretir.
export function subnetScanCandidates(
  localIps: string[],
): string[] {
  const own = new Set(localIps);
  const prefixes = new Set<string>();
  for (const ip of localIps) {
    const p = subnetPrefix(ip);
    if (p) prefixes.add(p);
  }

  const candidates: string[] = [];
  for (const prefix of prefixes) {
    for (let i = 1; i <= 254; i++) {
      const ip = `${prefix}.${i}`;
      if (!own.has(ip)) candidates.push(ip);
    }
  }
  return candidates;
}

// candidates dizisini concurrency boyutunda gruplara boler (sirali batch
// isleme icin - her app kendi platformunun HTTP istemcisiyle kullanir).
export function chunk<T>(items: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    out.push(items.slice(i, i + size));
  }
  return out;
}
