import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/product_filters.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import 'catalog_controller.dart';
import 'product_filter_selection.dart';

/// Deschide ecranul de filtre. Filtrele se aplica imediat la fiecare apasare, nu la
/// final: numaratoarele de langa fiecare valoare vin de la server si trebuie sa se
/// potriveasca cu ce e bifat, altfel ar minti.
Future<void> showCatalogFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FilterSheet(),
  );
}

/// Deschide lista de sortari.
Future<void> showCatalogSortSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SortSheet(),
  );
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child, this.heightFactor});

  final Widget child;
  final double? heightFactor;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      constraints: heightFactor == null
          ? null
          : BoxConstraints(maxHeight: media.size.height * heightFactor!),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogControllerProvider);
    final selection = ref.watch(catalogFilterSelectionProvider);
    final state = catalog.value;
    final filters = state?.filters ?? const ProductFilters();
    final notifier = ref.read(catalogControllerProvider.notifier);

    return _SheetShell(
      heightFactor: 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(child: _Grabber()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
            child: Row(
              children: [
                const Expanded(child: Text('Filtre', style: AppTypography.title)),
                if (selection.activeCount > 0)
                  TextButton(
                    onPressed: () => notifier.setFilters(selection.cleared()),
                    child: const Text('Sterge tot'),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Inchide',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              children: [
                if (filters.price.usable)
                  _PriceSection(
                    price: filters.price,
                    selection: selection,
                    onChanged: (min, max) => notifier.setFilters(
                      selection.copyWith(minPrice: min, maxPrice: max),
                    ),
                    onCleared: () => notifier.setFilters(selection.copyWith(clearPrice: true)),
                  ),
                for (final attribute in filters.attributes)
                  _AttributeSection(
                    attribute: attribute,
                    selection: selection,
                    onToggle: (valueId) =>
                        notifier.setFilters(selection.toggleValue(attribute.id, valueId)),
                  ),
                if (filters.attributes.isEmpty && !filters.price.usable)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Nu exista filtre pentru aceasta lista de produse.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  catalog.isLoading
                      ? 'Se cauta...'
                      : _resultsLabel(state?.total ?? 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _resultsLabel(int total) {
    if (total == 0) return 'Niciun produs';
    if (total == 1) return 'Vezi 1 produs';
    return 'Vezi $total de produse';
  }
}

class _PriceSection extends StatefulWidget {
  const _PriceSection({
    required this.price,
    required this.selection,
    required this.onChanged,
    required this.onCleared,
  });

  final PriceFilter price;
  final ProductFilterSelection selection;
  final void Function(double min, double max) onChanged;
  final VoidCallback onCleared;

  @override
  State<_PriceSection> createState() => _PriceSectionState();
}

class _PriceSectionState extends State<_PriceSection> {
  RangeValues? _dragging;

  @override
  Widget build(BuildContext context) {
    final bounds = widget.price;
    final current = _dragging ??
        RangeValues(
          (widget.selection.minPrice ?? bounds.min).clamp(bounds.min, bounds.max),
          (widget.selection.maxPrice ?? bounds.max).clamp(bounds.min, bounds.max),
        );
    final hasSelection = widget.selection.minPrice != null || widget.selection.maxPrice != null;

    return _Section(
      title: 'Pret',
      trailing: hasSelection
          ? TextButton(onPressed: widget.onCleared, child: const Text('Reseteaza'))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${current.start.round()} - ${current.end.round()} lei',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          RangeSlider(
            values: current,
            min: bounds.min,
            max: bounds.max,
            // Etichetele se arata doar in timpul tragerii; valoarea curenta sta
            // oricum scrisa deasupra.
            labels: RangeLabels('${current.start.round()}', '${current.end.round()}'),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primaryLight,
            onChanged: (values) => setState(() => _dragging = values),
            // Cererea pleaca abia cand degetul se ridica: altfel am trimite zeci de
            // cereri pentru o singura miscare a glisorului.
            onChangeEnd: (values) {
              setState(() => _dragging = null);
              widget.onChanged(values.start, values.end);
            },
          ),
        ],
      ),
    );
  }
}

class _AttributeSection extends StatelessWidget {
  const _AttributeSection({
    required this.attribute,
    required this.selection,
    required this.onToggle,
  });

  final AttributeFilter attribute;
  final ProductFilterSelection selection;
  final void Function(int valueId) onToggle;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: attribute.name,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in attribute.values)
            _ValueChip(
              label: value.name,
              count: value.count,
              color: _parseColor(value.color),
              selected: selection.isSelected(attribute.id, value.id),
              // O valoare ramasa fara produse se poate doar DEBIFA, nu bifa: altfel
              // clientul ar ajunge intr-o grila goala dintr-un singur tap.
              onTap: value.count == 0 && !selection.isSelected(attribute.id, value.id)
                  ? null
                  : () => onToggle(value.id),
            ),
        ],
      ),
    );
  }

  static Color? _parseColor(String? raw) {
    if (raw == null || !raw.startsWith('#') || raw.length != 7) return null;
    final value = int.tryParse(raw.substring(1), radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final foreground = selected
        ? Colors.white
        : disabled
            ? AppColors.textSecondary.withValues(alpha: 0.5)
            : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.primaryLight.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (color != null) ...[
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTypography.body.copyWith(color: foreground, fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: AppTypography.caption.copyWith(
                  color: selected ? Colors.white70 : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTypography.sectionTitle)),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SortSheet extends ConsumerWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogControllerProvider).value?.filters ?? const ProductFilters();
    final selection = ref.watch(catalogFilterSelectionProvider);
    final notifier = ref.read(catalogControllerProvider.notifier);
    // Cheia bifata e cea aleasa de client; daca n-a ales nimic, e cea pe care
    // serverul o marcheaza ca implicita (sortarea configurata a magazinului).
    final activeKey = selection.sort ??
        filters.sorts.where((s) => s.selected).map((s) => s.key).firstOrNull;

    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(child: _Grabber()),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('Sorteaza', style: AppTypography.title)),
          ),
          for (final option in filters.sorts)
            ListTile(
              title: Text(option.name, style: AppTypography.body),
              trailing: option.key == activeKey
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                notifier.setFilters(selection.copyWith(sort: option.key));
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
