// Ag sabitleri: kesif (UDP) ve dosya transferi (HTTP) portlari/zamanlamalari.
// Eski Flutter surumundeki lib/utils/constants.dart ile birebir ayni degerler
// - iki taraf da ayni protokolu konusmali.
export const DISCOVERY_UDP_PORT = 57332;
export const TRANSFER_HTTP_PORT = 57333;

export const BROADCAST_INTERVAL_MS = 3000;
export const STALENESS_SWEEP_INTERVAL_MS = 2000;
export const PEER_TIMEOUT_MS = 8000;
export const TRANSFER_APPROVAL_TIMEOUT_MS = 30000;

// UDP broadcast bazi aglarda (ozellikle bazi ISP modemlerinde) iletilmiyor;
// bu yuzden alt agi unicast HTTP istekleriyle tarayan yedek kesif de var.
// Bu mekanizma gercek kullanici aginda kesfi calisir kilan asil sey oldu,
// atlanmamali.
export const SUBNET_SCAN_INTERVAL_MS = 12000;
export const SUBNET_SCAN_TIMEOUT_MS = 400;
export const SUBNET_SCAN_CONCURRENCY = 48;
