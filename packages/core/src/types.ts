// Eski Flutter surumundeki lib/models/*.dart ile birebir ayni sekiller.

export type Platform = 'windows' | 'ios' | 'android' | 'macos' | 'unknown';

export interface Peer {
  id: string;
  displayName: string;
  host: string;
  port: number;
  platform: Platform;
  lastSeen: number; // epoch ms
}

export type TransferDirection = 'send' | 'receive';

export type TransferStatus =
  | 'awaitingApproval'
  | 'inProgress'
  | 'completed'
  | 'rejected'
  | 'timedOut'
  | 'failed';

export interface TransferTask {
  id: string;
  fileName: string;
  fileSize: number;
  direction: TransferDirection;
  peer: Peer;
  status: TransferStatus;
  progressBytes: number;
  errorMessage?: string;
}

export interface DiscoveryStatus {
  addresses: string[];
  broadcastCount: number;
  receivedCount: number;
  scanCount: number;
  error: string | null;
}

// --- Tel uzerindeki mesaj sekilleri (UDP + HTTP) ---

export interface AnnouncePacket {
  id: string;
  name: string;
  platform: Platform;
  port: number;
  type: 'announce';
}

export interface WhoAmIResponse {
  id: string;
  name: string;
  platform: Platform;
}

export interface PrepareRequest {
  senderId: string;
  senderName: string;
  fileName: string;
  fileSize: number;
  sessionId: string;
}

export interface PrepareResponse {
  accepted: boolean;
}

export interface ReceiveResponse {
  ok: boolean;
  error?: string;
}
