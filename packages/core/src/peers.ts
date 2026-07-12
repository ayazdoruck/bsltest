import { PEER_TIMEOUT_MS } from './constants';
import type { Peer } from './types';

export function isPeerStale(peer: Peer, now: number = Date.now()): boolean {
  return now - peer.lastSeen > PEER_TIMEOUT_MS;
}

// Bir peer haritasindan (id -> Peer) bayat olanlari cikarir, degisiklik
// olup olmadigini da doner (UI'a gereksiz emit yapmamak icin).
export function sweepStalePeers(
  peers: Map<string, Peer>,
  now: number = Date.now(),
): boolean {
  let removedAny = false;
  for (const [id, peer] of peers) {
    if (isPeerStale(peer, now)) {
      peers.delete(id);
      removedAny = true;
    }
  }
  return removedAny;
}
