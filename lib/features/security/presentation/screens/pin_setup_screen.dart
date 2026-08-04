import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_providers.dart';
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});
  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}
class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _firstPin = '';
  String _current = '';
  bool _confirming = false;
  String? _error;
  void _onDigit(String d) {
    if (_current.length >= 4) return;
    setState(() { _current += d; _error = null; });
    if (_current.length == 4) _onComplete();
  }
  void _onDelete() {
    if (_current.isEmpty) return;
    setState(() => _current = _current.substring(0, _current.length - 1));
  }
  Future<void> _onComplete() async {
    if (!_confirming) {
      setState(() { _firstPin = _current; _current = ''; _confirming = true; });
      return;
    }
    if (_current == _firstPin) {
      final repo = ref.read(securityRepositoryProvider);
      await repo.setPin(_current);
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() { _error = 'Los PIN no coinciden, intenta de nuevo'; _current = ''; _confirming = false; _firstPin = ''; });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear PIN')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(_confirming ? 'Confirma tu PIN' : 'Crea un PIN de 4 digitos', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
