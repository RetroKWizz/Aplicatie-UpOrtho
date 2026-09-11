import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_exception.dart';
import '../../api/models/address_options.dart';
import '../../design_system/colors.dart';
import 'account_controller.dart';

/// Adresa noua: livrare sau facturare.
///
/// Ecranul nu decide singur ce e obligatoriu. Lista de campuri cerute vine de la
/// server (`/addresses/options`), pentru ca acolo traiesc regulile magazinului si ale
/// modulelor clientului: orasul e o inregistrare legata, nu text liber, iar codul
/// fiscal devine obligatoriu cand se completeaza numele firmei. La trimitere,
/// validarea o face tot serverul si intoarce lista campurilor gresite, pe care ecranul
/// le marcheaza unul cate unul.
class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, required this.kind});

  /// `delivery` sau `invoice`.
  final String kind;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _controllers = <String, TextEditingController>{
    'name': TextEditingController(),
    'street': TextEditingController(),
    'street2': TextEditingController(),
    'zip': TextEditingController(),
    'phone': TextEditingController(),
    'email': TextEditingController(),
    'company_name': TextEditingController(),
    'vat': TextEditingController(),
    'city': TextEditingController(),
  };

  AddressOptions? _options;
  int? _countryId;
  int? _stateId;
  int? _cityId;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Set<String> _badFields = {};

  bool get _isInvoice => widget.kind == 'invoice';

  List<String> get _required => _options == null
      ? const []
      : (_isInvoice ? _options!.required.invoice : _options!.required.delivery);

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadOptions);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadOptions({int? countryId, int? stateId}) async {
    setState(() => _loading = true);
    try {
      final options = await ref
          .read(accountRepositoryProvider)
          .fetchAddressOptions(countryId: countryId, stateId: stateId);
      if (!mounted) return;
      setState(() {
        _options = options;
        _countryId = countryId ?? options.defaultCountryId;
        _stateId = stateId;
        _loading = false;
      });
      // Prima incarcare nu stie inca tara, deci nu poate aduce judetele. Cand serverul
      // spune care e tara implicita, se cere din nou pentru ea.
      if (countryId == null && options.defaultCountryId != null) {
        await _loadOptions(countryId: options.defaultCountryId);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiException ? error.message : 'Formularul nu s-a putut incarca.';
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
      _badFields = {};
    });
    final values = <String, dynamic>{
      for (final entry in _controllers.entries)
        if (entry.value.text.trim().isNotEmpty) entry.key: entry.value.text.trim(),
      if (_countryId != null) 'country_id': _countryId,
      if (_stateId != null) 'state_id': _stateId,
      if (_cityId != null) 'city_id': _cityId,
    };
    try {
      await ref
          .read(accountRepositoryProvider)
          .createAddress(kind: widget.kind, values: values);
      // Lista de adrese e citita de mai multe ecrane (cont, checkout): se invalideaza,
      // nu se scrie peste, ca fiecare sa o ceara la urmatoarea afisare.
      ref.invalidate(addressesProvider);
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
        _error = 'Adresa nu s-a putut salva. Incearca din nou.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isInvoice ? 'Adresa de facturare' : 'Adresa de livrare'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _options == null
              ? _ErrorView(message: _error ?? 'Formularul nu s-a putut incarca.', onRetry: _loadOptions)
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    final options = _options!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _field('name', 'Nume'),
        if (_isInvoice) ...[
          _field('company_name', 'Nume firma'),
          _field('vat', 'Cod fiscal (CUI)',
              helper: 'Obligatoriu daca ai completat numele firmei.'),
        ],
        _field('street', 'Strada si numarul'),
        _field('street2', 'Detalii (bloc, scara, apartament)'),
        _countryPicker(options),
        if (options.states.isNotEmpty) _statePicker(options),
        if (options.cityIsList) _cityPicker(options) else _field('city', 'Oras'),
        _field('zip', 'Cod postal', keyboard: TextInputType.number),
        _field('phone', 'Telefon', keyboard: TextInputType.phone),
        _field('email', 'Email', keyboard: TextInputType.emailAddress),
        if (_error case final String message) ...[
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.danger)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salveaza adresa'),
        ),
      ],
    );
  }

  Widget _field(String name, String label,
      {TextInputType? keyboard, String? helper}) {
    final required = _required.contains(name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[name],
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          helperText: helper,
          errorText: _badFields.contains(name) ? 'Verifica acest camp' : null,
          filled: true,
          fillColor: AppColors.surface,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _countryPicker(AddressOptions options) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<int>(
          initialValue: _countryId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: _required.contains('country_id') ? 'Tara *' : 'Tara',
            errorText: _badFields.contains('country_id') ? 'Alege tara' : null,
            filled: true,
            fillColor: AppColors.surface,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final c in options.countries)
              DropdownMenuItem(value: c.id, child: Text(c.name)),
          ],
          // Schimbarea tarii aduce alte judete si poate schimba ce e obligatoriu:
          // se cere din nou de la server, nu se filtreaza local.
          onChanged: (id) {
            setState(() {
              _stateId = null;
              _cityId = null;
            });
            _loadOptions(countryId: id);
          },
        ),
      );

  Widget _statePicker(AddressOptions options) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<int>(
          initialValue: _stateId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: _required.contains('state_id') ? 'Judet *' : 'Judet',
            errorText: _badFields.contains('state_id') ? 'Alege judetul' : null,
            filled: true,
            fillColor: AppColors.surface,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final s in options.states) DropdownMenuItem(value: s.id, child: Text(s.name)),
          ],
          onChanged: (id) {
            setState(() => _cityId = null);
            _loadOptions(countryId: _countryId, stateId: id);
          },
        ),
      );

  Widget _cityPicker(AddressOptions options) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<int>(
          initialValue: _cityId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: _required.contains('city_id') ? 'Oras *' : 'Oras',
            helperText: options.states.isNotEmpty && _stateId == null
                ? 'Alege intai judetul.'
                : null,
            errorText: _badFields.contains('city_id') ? 'Alege orasul' : null,
            filled: true,
            fillColor: AppColors.surface,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final c in options.cities) DropdownMenuItem(value: c.id, child: Text(c.name)),
          ],
          onChanged: options.cities.isEmpty
              ? null
              : (id) {
                  setState(() => _cityId = id);
                  // Odoo tine si codul postal pe oras; il completam daca lipseste,
                  // ca la formularul de pe site.
                  final city = options.cities.firstWhere((c) => c.id == id);
                  if (city.zip != null && _controllers['zip']!.text.trim().isEmpty) {
                    _controllers['zip']!.text = city.zip!;
                  }
                },
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reincearca')),
          ],
        ),
      ),
    );
  }
}
