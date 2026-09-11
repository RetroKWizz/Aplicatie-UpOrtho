import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/profile.dart';
import '../../design_system/colors.dart';
import 'account_controller.dart';

/// Datele contului: aceleasi campuri pe care le are si contul de pe site.
///
/// Ce e obligatoriu si ce se poate modifica vine de la server, nu se decide aici.
/// Codul fiscal si tara se blocheaza cand Odoo spune ca nu mai pot fi schimbate
/// (dupa emiterea documentelor contabile) - altfel clientul ar scrie degeaba.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const _fields = <String, String>{
    'name': 'Nume',
    'company_name': 'Firma',
    'vat': 'Cod fiscal (CUI)',
    'email': 'Email',
    'phone': 'Telefon',
    'mobile': 'Mobil',
    'function': 'Functie',
    'street': 'Strada si numarul',
    'street2': 'Detalii adresa',
    'city': 'Oras',
    'zip': 'Cod postal',
  };

  final _controllers = <String, TextEditingController>{};
  AccountProfileResponse? _loaded;
  bool _saving = false;
  String? _error;
  String? _saved;
  Set<String> _badFields = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Umple campurile o singura data, la prima incarcare. Reumplute la fiecare build,
  /// ar sterge ce tocmai a tastat clientul.
  void _fill(AccountProfileResponse response) {
    if (_loaded != null) return;
    _loaded = response;
    final p = response.profile;
    final values = <String, String?>{
      'name': p.name,
      'company_name': p.companyName,
      'vat': p.vat,
      'email': p.email,
      'phone': p.phone,
      'mobile': p.mobile,
      'function': p.function,
      'street': p.street,
      'street2': p.street2,
      'city': p.city,
      'zip': p.zip,
    };
    for (final entry in values.entries) {
      _controllers[entry.key] = TextEditingController(text: entry.value ?? '');
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
      _saved = null;
      _badFields = {};
    });
    // Se trimit campurile pe care clientul chiar le poate schimba, inclusiv cele
    // golite: un camp gol e o cerere de stergere, pe care serverul o refuza daca e
    // obligatoriu. Un camp BLOCAT (codul fiscal dupa emiterea facturilor) nu se
    // trimite deloc - altfel am cere o schimbare pe care Odoo o refuza oricum.
    final values = <String, dynamic>{
      for (final entry in _controllers.entries)
        if (!_isLocked(entry.key)) entry.key: entry.value.text.trim(),
    };
    try {
      await ref.read(accountRepositoryProvider).updateProfile(values);
      ref.invalidate(profileProvider);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = 'Datele au fost salvate.';
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      final fields = error.details['fields'];
      setState(() {
        _saving = false;
        _error = error.message;
        _badFields = fields is List ? fields.map((f) => '$f').toSet() : {};
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Datele nu s-au putut salva. Incearca din nou.';
      });
    }
  }

  /// `mobile` si `function` nu sunt in formularul web al portalului, dar serverul le
  /// accepta si aplicatia le arata.
  bool _isEditable(String field) =>
      field == 'mobile' ||
      field == 'function' ||
      (_loaded?.editable.contains(field) ?? false);

  bool _isLocked(String field) {
    final profile = _loaded?.profile;
    if (profile == null) return true;
    if (field == 'vat' && !profile.canEditVat) return true;
    return !_isEditable(field);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Datele contului')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                const SizedBox(height: 12),
                Text(
                  error is ApiException ? error.message : 'Datele nu s-au putut incarca.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(profileProvider),
                  child: const Text('Reincearca'),
                ),
              ],
            ),
          ),
        ),
        data: (response) {
          _fill(response);
          return _buildForm(response);
        },
      ),
    );
  }

  Widget _buildForm(AccountProfileResponse response) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in _fields.entries) _field(entry.key, entry.value, response),
        if (response.profile.country case final String country) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Tara: $country${response.profile.state == null ? '' : ', ${response.profile.state}'}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
        if (!response.profile.canEditVat)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Codul fiscal si tara nu mai pot fi schimbate dupa emiterea facturilor. '
              'Pentru o corectie, contacteaza-ne.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        if (_error case final String message)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(message, style: const TextStyle(color: AppColors.danger)),
          ),
        if (_saved case final String message)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(message, style: const TextStyle(color: AppColors.success)),
          ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salveaza'),
        ),
      ],
    );
  }

  Widget _field(String name, String label, AccountProfileResponse response) {
    final locked = _isLocked(name);
    final required = response.required.contains(name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[name],
        enabled: !locked,
        keyboardType: switch (name) {
          'email' => TextInputType.emailAddress,
          'phone' || 'mobile' => TextInputType.phone,
          _ => null,
        },
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          errorText: _badFields.contains(name) ? 'Verifica acest camp' : null,
          filled: true,
          fillColor: locked ? AppColors.background : AppColors.surface,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
