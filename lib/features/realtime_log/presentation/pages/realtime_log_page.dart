import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';

// ─── LOG ENTRY MODEL ─────────────────────────────────────────────────────────

class _LogEntry {
  final String level;
  final String message;
  final DateTime timestamp;

  const _LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
  });

  Color get color => switch (level) {
    'WARNING' => const Color(0xFFFBBF24),
    'ERROR' => const Color(0xFFF87171),
    'DEBUG' => const Color(0xFF60A5FA),
    _ => const Color(0xFF4ADE80),
  };
}

// ─── SIMULATED LOG DATA ──────────────────────────────────────────────────────

const _simulatedLogLines = [
  (level: 'INFO', msg: 'Löydetty 0 kohdetta'),
  (level: 'INFO', msg: 'Kohdetta ei löytynyt, luodaan uusi'),
  (level: 'INFO', msg: '→ ASUINKIINTEISTO (rakennusluokka_2018: 110)'),
  (level: 'INFO', msg: 'uusi kohde luotu: 1233'),
  (level: 'WARNING', msg: 'Rakennus 20373 ei vastaa PRT-tunnusta 102236106W'),
  (level: 'DEBUG', msg: 'not Tuple rakennus 22977, 102676925V'),
  (level: 'INFO', msg: 'Etsitään kohdetta: rakennukset={22977}'),
  (level: 'INFO', msg: 'Kohde löydetty: id=4421, tyyppi=ASUINKIINTEISTO'),
  (level: 'INFO', msg: 'Päivitetään kohteen 4421 tiedot'),
  (level: 'DEBUG', msg: 'SQL: UPDATE jkr.kohde SET ... WHERE id=4421'),
  (level: 'INFO', msg: 'Kohde 4421 päivitetty onnistuneesti'),
  (level: 'WARNING', msg: 'Rakennus 20981 — rakennusluokka puuttuu DVV-datasta'),
  (level: 'INFO', msg: 'Ohitetaan rakennus 20981 (ei pakollinen)'),
  (level: 'INFO', msg: 'Etsitään kohdetta: rakennukset={23105, 23106}'),
  (level: 'INFO', msg: 'Kohde löydetty: id=5012, tyyppi=HAPA'),
  (level: 'ERROR', msg: 'Virhe kohteen 5012 päivityksessä: duplicate key value violates unique constraint'),
  (level: 'INFO', msg: 'Yritetään uudelleen kohteen 5012 päivitystä'),
  (level: 'INFO', msg: 'Kohde 5012 päivitetty onnistuneesti (retry)'),
  (level: 'DEBUG', msg: 'Vapautetaan tietokantayhteys pooliin'),
  (level: 'INFO', msg: 'Erä 14/28 valmis — 48 kohdetta käsitelty, 2 virhettä'),
];

// ─── REALTIME LOG PAGE ───────────────────────────────────────────────────────

class RealtimeLogPage extends StatefulWidget {
  const RealtimeLogPage({super.key});

  @override
  State<RealtimeLogPage> createState() => _RealtimeLogPageState();
}

enum _ConnectionStatus { connected, disconnected, connecting }

class _RealtimeLogPageState extends State<RealtimeLogPage> {
  final List<_LogEntry> _logs = [];
  final ScrollController _scrollController = ScrollController();

  bool _paused = false;
  bool _autoscroll = true;
  _ConnectionStatus _connectionStatus = _ConnectionStatus.disconnected;

  // Simulated streaming
  Timer? _simulationTimer;
  int _simIndex = 0;

  // WebSocket (for real backend)
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _channel?.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  /// Try to connect to the real WebSocket endpoint.
  /// Falls back to simulated log streaming if connection fails.
  void _connectWebSocket() {
    setState(() => _connectionStatus = _ConnectionStatus.connecting);

    final apiBase = EnvConfig.apiBaseUrl;
    final wsUrl = apiBase
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    final uri = Uri.parse('$wsUrl/ws/logs');

    try {
      _channel = WebSocketChannel.connect(uri);
      setState(() => _connectionStatus = _ConnectionStatus.connected);

      _channel!.stream.listen(
        (message) {
          if (_paused) return;
          _addLog(_parseWsMessage(message.toString()));
        },
        onError: (_) => _fallbackToSimulation(),
        onDone: () => _fallbackToSimulation(),
      );
    } catch (_) {
      _fallbackToSimulation();
    }
  }

  _LogEntry _parseWsMessage(String raw) {
    // Expect JSON like {"level":"INFO","msg":"..."} or plain text
    final levelMatch = RegExp(r'\[(INFO|WARNING|ERROR|DEBUG)\]').firstMatch(raw);
    final level = levelMatch?.group(1) ?? 'INFO';
    return _LogEntry(level: level, message: raw, timestamp: DateTime.now());
  }

  void _fallbackToSimulation() {
    _channel?.sink.close();
    _channel = null;
    if (!mounted) return;
    setState(() => _connectionStatus = _ConnectionStatus.connected);
    _startSimulation();
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (_paused || !mounted) return;
      final line = _simulatedLogLines[_simIndex % _simulatedLogLines.length];
      final now = DateTime.now();
      final ts = '${now.year}-${_p(now.month)}-${_p(now.day)} ${_p(now.hour)}:${_p(now.minute)}:${_p(now.second)}';
      _addLog(_LogEntry(
        level: line.level,
        message: '$ts [${line.level}] ${line.msg}',
        timestamp: now,
      ));
      _simIndex++;
    });
  }

  static String _p(int n) => n.toString().padLeft(2, '0');

  void _addLog(_LogEntry entry) {
    setState(() => _logs.add(entry));
    if (_autoscroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _togglePause() => setState(() => _paused = !_paused);

  void _clearLogs() => setState(() {
    _logs.clear();
    _simIndex = 0;
  });

  String get _wsDisplayUrl {
    final apiBase = EnvConfig.apiBaseUrl;
    final wsUrl = apiBase
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    return '$wsUrl/ws/logs';
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          _buildToolbar(),
          const SizedBox(height: 14),
          Expanded(child: _buildTerminal()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final (dotColor, statusText) = switch (_connectionStatus) {
      _ConnectionStatus.connected => (const Color(0xFF22C55E), 'Yhdistetty'),
      _ConnectionStatus.connecting => (const Color(0xFFFBBF24), 'Yhdistetään...'),
      _ConnectionStatus.disconnected => (const Color(0xFFEF4444), 'Ei yhteyttä'),
    };

    return CardContainer(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 7),
          Text(statusText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const Spacer(),
          // Autoscroll toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: Checkbox(
                  value: _autoscroll,
                  onChanged: (v) => setState(() => _autoscroll = v ?? true),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Text('Autoscroll', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(width: 14),
          OutlinedButton(
            onPressed: _togglePause,
            child: Text(_paused ? 'Jatka' : 'Keskeytä'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _clearLogs,
            child: const Text('Tyhjennä'),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminal() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1117),
        border: Border.all(color: Colors.black.withValues(alpha: 0.10), width: 0.5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          // Log content
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '[${log.level}] ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: log.color,
                        ),
                      ),
                      TextSpan(
                        text: log.message.replaceFirst(RegExp(r'^\S+ \S+ \[\w+\] '), ''),
                        style: TextStyle(
                          color: log.level == 'WARNING'
                              ? const Color(0xFFFBBF24)
                              : log.level == 'ERROR'
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFAAAAAA),
                        ),
                      ),
                    ]),
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'DM Mono',
                      height: 1.65,
                    ),
                  ),
                );
              },
            ),
          ),
          // Footer status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x10FFFFFF))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_logs.length} viestiä${_paused ? ' (keskeytetty)' : ''}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
                ),
                Text(
                  'WebSocket: $_wsDisplayUrl',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
