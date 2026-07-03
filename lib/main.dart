import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bsl Test Chat',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F111E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF10B981),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// GIRIS / SPLASH EKRANI  (ag durumu ne olursa olsun acilista gorunur)
// ---------------------------------------------------------------------------
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F111E), Color(0xFF1E1E38)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.forum_rounded,
                    size: 80,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 36),
                const Text(
                  'Bsl Test Chat',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Telefon ile bilgisayar arasinda yerel ag uzerinden haberlesme.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                const Spacer(flex: 3),
                // Baslayalim butonu
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    },
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: const Text(
                      'Baslayalim',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const CodedByWidget(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MESAJ MODELI
// ---------------------------------------------------------------------------
class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, required this.time});

  Map<String, dynamic> toJson() => {
        'text': text,
        'isMe': isMe,
        'time': time.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'] as String,
        isMe: json['isMe'] as bool,
        time: DateTime.parse(json['time'] as String),
      );
}

// ---------------------------------------------------------------------------
// SOHBET EKRANI
// ---------------------------------------------------------------------------
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Sunucunun (PC) LAN IP'si ve portu. IP degisirse burayi guncelle.
  final String _ip = '192.168.0.16';
  final int _port = 3434;

  Socket? _socket;
  StreamSubscription<List<int>>? _socketSubscription;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _connectionError = '';

  // Bolunmus TCP paketlerini ve cok-baytli UTF-8 karakterlerini
  // dogru cozmek icin ham byte buffer (satir = '\n' ile ayrilir).
  final List<int> _rxBuffer = [];

  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectToServer();
  }

  @override
  void dispose() {
    _closeConnection();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _closeConnection() {
    _socketSubscription?.cancel();
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
    _rxBuffer.clear();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? serialized = prefs.getStringList('chat_messages');
      if (serialized != null) {
        setState(() {
          _messages.clear();
          _messages.addAll(
            serialized.map((item) => ChatMessage.fromJson(jsonDecode(item))),
          );
        });
        Timer(const Duration(milliseconds: 200), () {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      debugPrint('Mesajlar yuklenirken hata: $e');
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> serialized =
          _messages.map((msg) => jsonEncode(msg.toJson())).toList();
      await prefs.setStringList('chat_messages', serialized);
    } catch (e) {
      debugPrint('Mesajlar kaydedilirken hata: $e');
    }
  }

  Future<void> _connectToServer() async {
    if (_isConnecting) return;
    setState(() {
      _isConnecting = true;
      _connectionError = '';
    });
    _closeConnection();

    try {
      _socket =
          await Socket.connect(_ip, _port, timeout: const Duration(seconds: 4));
      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });

      _socketSubscription = _socket!.listen(
        _onData,
        onError: (Object error) {
          setState(() {
            _isConnected = false;
            _connectionError = 'Hata: $error';
          });
          _closeConnection();
        },
        onDone: () {
          setState(() {
            _isConnected = false;
            _connectionError = 'Sunucu baglantisi kesti.';
          });
          _closeConnection();
        },
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isConnecting = false;
        _connectionError = 'Sunucuya baglanilamadi. IP: $_ip:$_port';
      });
    }
  }

  // Ham byte'lari buffer'a ekle, tam satirlari (\n) ayirip coz.
  void _onData(List<int> data) {
    _rxBuffer.addAll(data);
    int idx;
    while ((idx = _rxBuffer.indexOf(10)) != -1) {
      final lineBytes = _rxBuffer.sublist(0, idx);
      _rxBuffer.removeRange(0, idx + 1);
      final line = utf8.decode(lineBytes, allowMalformed: true).trim();
      if (line.isNotEmpty) _addMessage(line, false);
    }
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (!_isConnected || _socket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sunucuya bagli degilsiniz!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      _socket!.write('$text\n');
      _addMessage(text, true);
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mesaj gonderilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addMessage(String text, bool isMe) {
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: isMe, time: DateTime.now()));
    });
    _saveMessages();
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _confirmDeleteMessage(ChatMessage msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mesaji Sil'),
        content: const Text('Bu mesaji silmek istediginizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Iptal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.remove(msg));
              _saveMessages();
              Navigator.pop(context);
            },
            child: const Text('Sil',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmClearMessages() {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Temizlenecek mesaj yok.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sohbeti Temizle'),
        content: const Text('Tum mesaj gecmisini silmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Iptal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              _saveMessages();
              Navigator.pop(context);
            },
            child: const Text('Temizle',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bsl Test Chat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CodedByWidget(showCompact: true),
          ],
        ),
        backgroundColor: const Color(0xFF151829),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Sohbeti Temizle',
            onPressed: _confirmClearMessages,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yeniden Baglan',
            onPressed: _connectToServer,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBar(),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessageBubble(_messages[index]),
                  ),
          ),
          _buildInputPanel(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final Color bg = _isConnected
        ? const Color(0xFF065F46)
        : (_isConnecting ? const Color(0xFF78350F) : const Color(0xFF991B1B));
    final Color dot = _isConnected
        ? Colors.greenAccent
        : (_isConnecting ? Colors.orangeAccent : Colors.redAccent);
    final String text = _isConnected
        ? '$_ip:$_port sunucusuna bagli'
        : (_isConnecting
            ? '$_ip:$_port baglaniyor...'
            : 'Baglanti Kesik. $_connectionError');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: bg,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dot,
              boxShadow: [
                BoxShadow(
                    color: dot.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 2),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ),
          if (!_isConnected && !_isConnecting)
            TextButton(
              onPressed: _connectToServer,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Baglan',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text('Henuz mesaj yok',
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          Text('Bilgisayarla haberlesmek icin yazmaya baslayin.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF151829),
        border: Border(top: BorderSide(color: Color(0xFF232840), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Mesajinizi yazin...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                fillColor: const Color(0xFF1E2235),
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 25,
            backgroundColor:
                _isConnected ? const Color(0xFF6366F1) : Colors.grey[700],
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _isConnected ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _confirmDeleteMessage(msg),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color:
                msg.isMe ? const Color(0xFF6366F1) : const Color(0xFF232840),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
              bottomRight: Radius.circular(msg.isMe ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(msg.text,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: msg.isMe ? Colors.indigo[100] : Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "coded by @ayazdoruck"
// ---------------------------------------------------------------------------
class CodedByWidget extends StatefulWidget {
  final bool showCompact;
  const CodedByWidget({super.key, this.showCompact = false});

  @override
  State<CodedByWidget> createState() => _CodedByWidgetState();
}

class _CodedByWidgetState extends State<CodedByWidget> {
  late final TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = _launchUrl;
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://github.com/ayazdoruck');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: widget.showCompact ? Colors.grey[400] : Colors.grey[500],
          fontSize: widget.showCompact ? 11 : 13,
        ),
        children: [
          const TextSpan(text: 'coded by '),
          TextSpan(
            text: '@ayazdoruck',
            style: const TextStyle(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: _tapRecognizer,
          ),
        ],
      ),
    );
  }
}
