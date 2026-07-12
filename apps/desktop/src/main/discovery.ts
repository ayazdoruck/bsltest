import dgram from 'dgram';
import os from 'os';
import {
  DISCOVERY_UDP_PORT,
  TRANSFER_HTTP_PORT,
  BROADCAST_INTERVAL_MS,
  STALENESS_SWEEP_INTERVAL_MS,
  directedBroadcastAddress,
  sweepStalePeers,
  type AnnouncePacket,
  type Peer,
  type Platform,
} from '@bslend/core';

// Ayni yerel agdaki diger cihazlari UDP broadcast ile bulur. Eski Dart
// surumundeki lib/services/discovery_service.dart'in Node/dgram karsiligi -
// ozellikle multi-NIC (Ethernet+WiFi ayni anda) durumundaki, daha once
// gercek kullanici aginda bulunup duzeltilmis bug'i tekrar yasamamak icin
// her yerel adrese ayri, o adrese baglanmis bir gonderim soketi kullaniyor.
export class DiscoveryService {
  private socket: dgram.Socket | null = null;
  private broadcastTimer: NodeJS.Timeout | null = null;
  private sweepTimer: NodeJS.Timeout | null = null;
  private stopped = false;

  private readonly peers = new Map<string, Peer>();

  constructor(
    private readonly myId: string,
    private readonly myName: string,
    private readonly myPlatform: Platform,
    private readonly onPeersChanged: (peers: Peer[]) => void,
  ) {}

  start(): void {
    this.stopped = false;
    this.socket = dgram.createSocket({ type: 'udp4', reuseAddr: true });

    this.socket.on('message', (msg, rinfo) => this.onMessage(msg, rinfo));
    this.socket.on('error', (err) => {
      console.error('[Discovery] soket hatasi:', err.message);
    });

    this.socket.bind(DISCOVERY_UDP_PORT, '0.0.0.0', () => {
      this.socket?.setBroadcast(true);
      console.log(
        `[Discovery] UDP soket ${DISCOVERY_UDP_PORT} portunda dinliyor (id: ${this.myId}, ad: ${this.myName}).`,
      );
    });

    this.broadcastAnnounce();
    this.broadcastTimer = setInterval(() => this.broadcastAnnounce(), BROADCAST_INTERVAL_MS);
    this.sweepTimer = setInterval(() => this.sweepStale(), STALENESS_SWEEP_INTERVAL_MS);
  }

  stop(): void {
    this.stopped = true;
    if (this.broadcastTimer) clearInterval(this.broadcastTimer);
    if (this.sweepTimer) clearInterval(this.sweepTimer);
    this.broadcastTimer = null;
    this.sweepTimer = null;
    this.socket?.close();
    this.socket = null;
  }

  private getLocalIPv4Addresses(): string[] {
    const interfaces = os.networkInterfaces();
    const addresses: string[] = [];
    for (const name of Object.keys(interfaces)) {
      for (const iface of interfaces[name] ?? []) {
        if (iface.family === 'IPv4' && !iface.internal) {
          addresses.push(iface.address);
        }
      }
    }
    return addresses;
  }

  private onMessage(msg: Buffer, rinfo: dgram.RemoteInfo): void {
    try {
      const json = JSON.parse(msg.toString('utf8')) as AnnouncePacket;
      if (json.type !== 'announce') return;
      if (json.id === this.myId) return;

      console.log(`[Discovery] Duyuru alindi: ${json.name} (${rinfo.address}).`);

      this.peers.set(json.id, {
        id: json.id,
        displayName: json.name,
        host: rinfo.address,
        port: json.port,
        platform: json.platform,
        lastSeen: Date.now(),
      });
      this.emitPeers();
    } catch {
      // Bozuk/ilgisiz paket, yok say.
    }
  }

  private broadcastAnnounce(): void {
    const payload = Buffer.from(
      JSON.stringify({
        id: this.myId,
        name: this.myName,
        platform: this.myPlatform,
        port: TRANSFER_HTTP_PORT,
        type: 'announce',
      } satisfies AnnouncePacket),
    );

    const localAddresses = this.getLocalIPv4Addresses();
    if (localAddresses.length === 0) {
      console.warn('[Discovery] Aktif yerel IPv4 adresi bulunamadi.');
      return;
    }

    for (const localIp of localAddresses) {
      const directed = directedBroadcastAddress(localIp);
      const sender = dgram.createSocket({ type: 'udp4', reuseAddr: true });

      sender.on('error', (err) => {
        console.error(`[Discovery] ${localIp} uzerinden gonderilemedi:`, err.message);
        sender.close();
      });

      sender.bind(0, localIp, () => {
        sender.setBroadcast(true);

        let pending = directed ? 2 : 1;
        const finishOne = () => {
          pending -= 1;
          if (pending <= 0) sender.close();
        };

        if (directed) {
          sender.send(payload, DISCOVERY_UDP_PORT, directed, finishOne);
        }
        sender.send(payload, DISCOVERY_UDP_PORT, '255.255.255.255', finishOne);
      });
    }
  }

  private sweepStale(): void {
    const changed = sweepStalePeers(this.peers);
    if (changed) this.emitPeers();
  }

  private emitPeers(): void {
    if (this.stopped) return;
    this.onPeersChanged(Array.from(this.peers.values()));
  }
}
