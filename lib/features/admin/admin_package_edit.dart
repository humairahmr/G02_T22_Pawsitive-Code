import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/back_navigation.dart';
import '../../theme/design_tokens.dart';
import 'models/payment_review.dart' show formatRm;
import 'models/studio_package.dart';

class AdminPackageEditScreen extends StatefulWidget {
  const AdminPackageEditScreen({
    super.key,
    this.package,
    this.store,
    this.onDone,
  });

  /// null = "Add package", otherwise "Edit package".
  final StudioPackage? package;
  final PackageStore? store;

  /// Called after Save or Cancel (the router sends the admin back to the list).
  final VoidCallback? onDone;

  @override
  State<AdminPackageEditScreen> createState() => _AdminPackageEditScreenState();
}

class _AdminPackageEditScreenState extends State<AdminPackageEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.package?.name ?? '',
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.package == null
        ? ''
        : formatRm(widget.package!.price).substring(3),
  );
  late final TextEditingController _duration = TextEditingController(
    text: widget.package == null
        ? ''
        : formatHours(widget.package!.durationHours),
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.package?.description ?? '',
  );
  late PackageCategory _category =
      widget.package?.category ?? PackageCategory.wedding;
  late final List<String> _included = List.of(widget.package?.included ?? []);
  late bool _visible = widget.package?.visible ?? true;

  bool get _isEdit => widget.package != null;
  PackageStore get _store => widget.store ?? packageStore;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _duration.dispose();
    _description.dispose();
    super.dispose();
  }

  double? _number(String? v) =>
      double.tryParse((v ?? '').replaceAll(',', '').trim());

  InputDecoration _dec({String? hint, String? suffix}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: Colors.white, width: 1.5),
    );
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(
          color: DesignTokens.studioYellow,
          width: 2,
        ),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: DesignTokens.alertPink),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: DesignTokens.alertPink),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  );

  Future<void> _addItem() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. 20 printed photos'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (!mounted || text == null || text.isEmpty) return;
    setState(() => _included.add(text));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final price = _number(_price.text)!;
    final hours = _number(_duration.text)!;

    if (_isEdit) {
      _store.update(
        widget.package!.copyWith(
          name: _name.text.trim(),
          category: _category,
          price: price,
          durationHours: hours,
          description: _description.text.trim(),
          included: List.of(_included),
          visible: _visible,
        ),
      );
    } else {
      _store.add(
        StudioPackage(
          id: _store.nextId(),
          name: _name.text.trim(),
          category: _category,
          price: price,
          durationHours: hours,
          description: _description.text.trim(),
          included: List.of(_included),
          visible: _visible,
        ),
      );
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Package saved')));
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    const white = TextStyle(color: Colors.white, fontSize: 18);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      children: [
                        ScreenHeader(
                          title: _isEdit ? 'Edit package' : 'Add package',
                          fallbackLocation: '/admin/packages',
                        ),
                        _label('Package name'),
                        TextFormField(
                          controller: _name,
                          style: white,
                          decoration: _dec(hint: 'e.g. Wedding Classic'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter a package name'
                              : null,
                        ),
                        _label('Category'),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final c in PackageCategory.values)
                              ChoiceChip(
                                label: Text(c.label),
                                selected: _category == c,
                                showCheckmark: false,
                                selectedColor: DesignTokens.studioYellow,
                                backgroundColor: const Color(0xFF48453F),
                                side: BorderSide.none,
                                labelStyle: TextStyle(
                                  color: _category == c
                                      ? DesignTokens.cardText
                                      : Colors.white,
                                  fontSize: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                onSelected: (_) =>
                                    setState(() => _category = c),
                              ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Price (RM)'),
                                  TextFormField(
                                    controller: _price,
                                    style: white,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]'),
                                      ),
                                    ],
                                    decoration: _dec(hint: '0'),
                                    validator: (v) {
                                      final n = _number(v);
                                      return (n == null || n <= 0)
                                          ? 'Enter a price'
                                          : null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Duration'),
                                  TextFormField(
                                    controller: _duration,
                                    style: white,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]'),
                                      ),
                                    ],
                                    decoration: _dec(
                                      hint: '0',
                                      suffix: 'hours',
                                    ),
                                    validator: (v) {
                                      final n = _number(v);
                                      return (n == null || n <= 0)
                                          ? 'Enter hours'
                                          : null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _label('Description'),
                        TextFormField(
                          controller: _description,
                          style: white,
                          minLines: 3,
                          maxLines: 5,
                          decoration: _dec(hint: 'Describe this package'),
                        ),
                        _label('What’s included'),
                        for (var i = 0; i < _included.length; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A4640),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: DesignTokens.studioYellow,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(_included[i], style: white),
                                ),
                                IconButton(
                                  tooltip: 'Remove',
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () =>
                                      setState(() => _included.removeAt(i)),
                                ),
                              ],
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addItem,
                            style: TextButton.styleFrom(
                              foregroundColor: DesignTokens.studioYellow,
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text(
                              'Add item',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        _label('Photos'),
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            _PhotoTile(
                              add: true,
                              onTap: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Photo upload will work once storage '
                                        'is connected.',
                                      ),
                                    ),
                                  ),
                            ),
                            const _PhotoTile(),
                            const _PhotoTile(),
                            const _PhotoTile(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Visible to customers', style: white),
                            ),
                            Switch.adaptive(
                              value: _visible,
                              onChanged: (v) => setState(() => _visible = v),
                              activeTrackColor: DesignTokens.studioYellow,
                              activeThumbColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: widget.onDone,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFC0392B),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: DesignTokens.studioYellow,
                              foregroundColor: DesignTokens.cardText,
                            ),
                            child: const Text(
                              'Save package',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({this.add = false, this.onTap});

  final bool add;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF4A4640),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 82,
          height: 82,
          child: Icon(
            add ? Icons.add : Icons.photo_camera_outlined,
            color: add ? DesignTokens.studioYellow : Colors.white38,
            size: add ? 34 : 24,
          ),
        ),
      ),
    );
  }
}
