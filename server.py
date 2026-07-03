import socket
import threading
import sys

# Constants
HOST = '0.0.0.0' # Binds to all available network adapters
PORT = 3434

# ANSI Colors
GREEN = "\033[92m"
CYAN = "\033[96m"
YELLOW = "\033[93m"
RED = "\033[91m"
RESET = "\033[0m"
BOLD = "\033[1m"

def get_local_ips():
    ips = []
    try:
        # Get host name
        hostname = socket.gethostname()
        # Get all IP addresses associated with host
        for info in socket.getaddrinfo(hostname, None):
            ip = info[4][0]
            if ip.startswith("192.168.") or ip.startswith("10.") or ip.startswith("172."):
                if ip not in ips:
                    ips.append(ip)
    except Exception:
        pass
    # Fallback method
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        if ip not in ips:
            ips.append(ip)
        s.close()
    except Exception:
        pass
    return ips

# Global variables
client_conn = None
client_addr = None
lock = threading.Lock()

def receive_messages(conn, addr):
    global client_conn, client_addr
    print(f"\n{GREEN}[+]{RESET} Mobil cihaz bağlandı: {BOLD}{addr[0]}:{addr[1]}{RESET}")
    print(f"{YELLOW}[i]{RESET} Göndermek istediğiniz mesajı yazıp Enter'a basın.")
    
    # Simple line-oriented protocol (newlines)
    buffer = ""
    try:
        while True:
            data = conn.recv(1024)
            if not data:
                break
            
            buffer += data.decode('utf-8', errors='ignore')
            while '\n' in buffer:
                line, buffer = buffer.split('\n', 1)
                line = line.strip()
                if line:
                    # Clear current prompt, print message, and restore prompt
                    sys.stdout.write(f"\r{CYAN}[Mobil -> PC]{RESET} {line}\n")
                    sys.stdout.write(f"{BOLD}Mesaj gönder: {RESET}")
                    sys.stdout.flush()
    except Exception as e:
        sys.stdout.write(f"\n{RED}[-]{RESET} Hata oluştu: {e}\n")
    finally:
        with lock:
            if client_conn == conn:
                client_conn = None
                client_addr = None
        sys.stdout.write(f"\n{RED}[-]{RESET} Bağlantı kesildi: {addr[0]}:{addr[1]}\n")
        sys.stdout.write(f"{YELLOW}[i]{RESET} Yeni bağlantı bekleniyor...\n")
        sys.stdout.write(f"{BOLD}Mesaj gönder: {RESET}")
        sys.stdout.flush()
        conn.close()

def send_messages():
    global client_conn
    while True:
        try:
            # Display prompt
            msg = input(f"{BOLD}Mesaj gönder: {RESET}")
            msg = msg.strip()
            if not msg:
                continue
            
            with lock:
                if client_conn:
                    # Send with newline delimiter
                    client_conn.sendall((msg + "\n").encode('utf-8'))
                    print(f"{GREEN}[PC -> Mobil]{RESET} {msg}")
                else:
                    print(f"{RED}[!]{RESET} Bağlı bir mobil cihaz yok! Cihazın bağlanmasını bekleyin.")
        except (KeyboardInterrupt, EOFError):
            print(f"\n{YELLOW}[i]{RESET} Sunucu kapatılıyor...")
            break
        except Exception as e:
            print(f"{RED}[!]{RESET} Gönderme hatası: {e}")

def main():
    global client_conn, client_addr
    
    # Print available local IPs
    local_ips = get_local_ips()
    print("=" * 60)
    print(f" {BOLD}YEREL CHAT PYTHON SUNUCUSU{RESET} ")
    print("=" * 60)
    print(f"Telefon uygulamasından bağlanacağınız IP adresi:")
    if local_ips:
        for ip in local_ips:
            print(f"  - {GREEN}{ip}:{PORT}{RESET}")
            if ip == "192.168.0.16":
                print(f"    {YELLOW}(Hedeflenen IP ile eşleşiyor!){RESET}")
    else:
        print(f"  - {GREEN}0.0.0.0:{PORT}{RESET} (Yerel IP bulunamadı)")
    print(f"\n{YELLOW}[i]{RESET} Sunucu başlatılıyor. Lütfen bekleyin...")
    
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        server.bind((HOST, PORT))
    except Exception as e:
        print(f"{RED}[!]{RESET} Hata: Port {PORT} bağlanamadı. Detay: {e}")
        return
        
    server.listen(5)
    print(f"{GREEN}[+]{RESET} Sunucu dinlemede. Bağlantı bekleniyor...")
    
    # Start sender thread
    sender_thread = threading.Thread(target=send_messages, daemon=True)
    sender_thread.start()
    
    try:
        while True:
            conn, addr = server.accept()
            with lock:
                if client_conn:
                    print(f"\n{YELLOW}[i]{RESET} Yeni bağlantı geldi ({addr[0]}), eski bağlantı sonlandırılıyor.")
                    try:
                        client_conn.close()
                    except Exception:
                        pass
                client_conn = conn
                client_addr = addr
                
            # Start receiver thread for this client
            recv_thread = threading.Thread(target=receive_messages, args=(conn, addr), daemon=True)
            recv_thread.start()
    except KeyboardInterrupt:
        print(f"\n{YELLOW}[i]{RESET} Sunucu durduruldu.")
    finally:
        server.close()

if __name__ == '__main__':
    # Initialize terminal colors for Windows CMD
    if sys.platform == 'win32':
        import os
        os.system('color')
    main()
