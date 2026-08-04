import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_providers.dart';
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});
  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}
class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  String _current = '';
  String? _error;
  bool _checkingBiometrics = true;
  bool _biometricsAvailable = false;
  @override
  void initState() {
    super.initState();
    _tryBiometricsFirst();
  }
  Future<void> _tryBiometricsFirst() async {
    final repo = ref.read(securityRepositoryProvider);
    final available = await repo.canUseBiometrics();
    if (mounted) setState(() { _biometricsAvailable = available; _checkingBiometrics = false; });
    if (available) {
      final ok = await repo.authenticateWithBiometrics();
      if (ok && mounted) Navigator.of(context).pop(true);
    }
  }
  void _onDigit(String d) {
    if (_current.length >= 4) return;
    setState(() { _current += d; _error = null; });
    if (_current.length == 4) _verify();
  }
  void _onDelete() {
    if (_current.isEmpty) return;
    setState(() => _current = _current.substring(0, _current.length - 1));
  }
  Future<void> _verify() async {
    final repo = ref.read(securityRepositoryProvider);
    final ok = await repo.verifyPin(_current);
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    } else {
      setState(() { _error = 'PIN incorrecto'; _current = ''; });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nota bloqueada')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.lock_rounded, size: 48),
            const SizedBox(height: 12),
            const Text('Ingresa tu PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _current.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16, height: 16,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: filled ? Theme.of(context).colorScheme.primary : Colors.transparent, border: Border.all(color: Theme.of(context).colorScheme.outline)),
                );
              }),
            ),
            if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: Colors.red))],
            if (!_checkingBiometrics && _biometricsAvailable) ...[
              const SizedBox(height: 12),
              TextButton.icon(onPressed: _tryBiometricsFirst, icon: const Icon(Icons.fingerprint_rounded), label: const Text('Usar huella digital')),
            ],
            const Spacer(),
            _NumberPad(onDigit: _onDigit, onDelete: _onDelete),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.onDigit, required this.onDelete});
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    const rows = [['1','2','3'],['4','5','6'],['7','8','9'],['','0','del']];
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 64, height: 64);
              if (key == 'del') {
                return SizedBox(width: 64, height: 64, child: IconButton(onPressed: onDelete, icon: const Icon(Icons.backspace_outlined)));
              }
              return SizedBox(width: 64, height: 64, child: TextButton(onPressed: () => onDigit(key), child: Text(key, style: const TextStyle(fontSize: 24))));
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
