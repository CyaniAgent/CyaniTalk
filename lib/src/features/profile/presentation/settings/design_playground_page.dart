import 'package:flutter/material.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:Nyachi/src/core/theme/design_tokens.dart';

class DesignPlaygroundPage extends StatelessWidget {
  const DesignPlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final m3eShape = context.m3eShape;

    return Scaffold(
      appBar: AppBar(title: const Text('Design Playground')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        children: [
          const _SectionHeader(title: 'Color Scheme'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ColorRow(
                  label: 'Primary',
                  color: colorScheme.primary,
                  onColor: colorScheme.onPrimary,
                ),
                _ColorRow(
                  label: 'Secondary',
                  color: colorScheme.secondary,
                  onColor: colorScheme.onSecondary,
                ),
                _ColorRow(
                  label: 'Tertiary',
                  color: colorScheme.tertiary,
                  onColor: colorScheme.onTertiary,
                ),
                _ColorRow(
                  label: 'Error',
                  color: colorScheme.error,
                  onColor: colorScheme.onError,
                ),
                _ColorRow(
                  label: 'Surface',
                  color: colorScheme.surface,
                  onColor: colorScheme.onSurface,
                ),
                _ColorRow(
                  label: 'Surface Container High',
                  color: colorScheme.surfaceContainerHigh,
                  onColor: colorScheme.onSurface,
                ),
                _ColorRow(
                  label: 'Surface Container Highest',
                  color: colorScheme.surfaceContainerHighest,
                  onColor: colorScheme.onSurface,
                ),
                _ColorRow(
                  label: 'Primary Container',
                  color: colorScheme.primaryContainer,
                  onColor: colorScheme.onPrimaryContainer,
                ),
                _ColorRow(
                  label: 'Secondary Container',
                  color: colorScheme.secondaryContainer,
                  onColor: colorScheme.onSecondaryContainer,
                ),
                _ColorRow(
                  label: 'Tertiary Container',
                  color: colorScheme.tertiaryContainer,
                  onColor: colorScheme.onTertiaryContainer,
                ),
                _ColorRow(
                  label: 'Outline',
                  color: colorScheme.outline,
                  onColor: colorScheme.surface,
                ),
                _ColorRow(
                  label: 'Outline Variant',
                  color: colorScheme.outlineVariant,
                  onColor: colorScheme.surface,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Typography'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.displayLarge,
                  label: 'displayLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.displayMedium,
                  label: 'displayMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.displaySmall,
                  label: 'displaySmall',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.headlineLarge,
                  label: 'headlineLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.headlineMedium,
                  label: 'headlineMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.headlineSmall,
                  label: 'headlineSmall',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.titleLarge,
                  label: 'titleLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.titleMedium,
                  label: 'titleMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.titleSmall,
                  label: 'titleSmall',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.bodyLarge,
                  label: 'bodyLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.bodyMedium,
                  label: 'bodyMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.bodySmall,
                  label: 'bodySmall',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.labelLarge,
                  label: 'labelLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.labelMedium,
                  label: 'labelMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.labelSmall,
                  label: 'labelSmall',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Shape Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShapeExample(
                  label: 'bottomSheet (28)',
                  radius: m3eShape.bottomSheet,
                  size: 60,
                ),
                const SizedBox(height: 12),
                _ShapeExample(
                  label: 'button (16)',
                  radius: m3eShape.button,
                  size: 48,
                ),
                const SizedBox(height: 12),
                _ShapeExample(
                  label: 'sliderTrack (4)',
                  radius: m3eShape.sliderTrack,
                  size: 40,
                ),
                const SizedBox(height: 12),
                _ShapeExample(
                  label: 'container (24)',
                  radius: m3eShape.container,
                  size: 56,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Slider Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TokenRow(
                  label: 'trackHeight',
                  value: '${context.m3eSlider.trackHeight} dp',
                ),
                _TokenRow(
                  label: 'thumbRadius',
                  value: '${context.m3eSlider.thumbRadius} dp',
                ),
                _TokenRow(
                  label: 'overlayRadius',
                  value: '${context.m3eSlider.overlayRadius} dp',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Menu Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TokenRow(
                  label: 'menuRadius',
                  value: '${context.m3eMenu.menuRadius} dp',
                ),
                _TokenRow(
                  label: 'itemRadius',
                  value: '${context.m3eMenu.itemRadius} dp',
                ),
                _TokenRow(
                  label: 'animationDuration',
                  value:
                      '${context.m3eMenu.animationDuration.inMilliseconds} ms',
                ),
                _TokenRow(
                  label: 'gapHeight',
                  value: '${context.m3eMenu.gapHeight} dp',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Sound Picker Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TokenRow(
                  label: 'chipRadius',
                  value: '${context.m3eSoundPicker.chipRadius} dp',
                ),
                _TokenRow(
                  label: 'chipHeight',
                  value: '${context.m3eSoundPicker.chipHeight} dp',
                ),
                _TokenRow(
                  label: 'chipSpacing',
                  value: '${context.m3eSoundPicker.chipSpacing} dp',
                ),
                _TokenRow(
                  label: 'gapBetweenChips',
                  value: '${context.m3eSoundPicker.gapBetweenChips} dp',
                ),
                _TokenRow(
                  label: 'iconSize',
                  value: '${context.m3eSoundPicker.iconSize} dp',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Title Bar Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TokenRow(
                  label: 'height',
                  value: '${context.m3eTitleBar.height} dp',
                ),
                _TokenRow(
                  label: 'windowButtonSize',
                  value: '${context.m3eTitleBar.windowButtonSize} dp',
                ),
                _TokenRow(
                  label: 'windowButtonSpacing',
                  value: '${context.m3eTitleBar.windowButtonSpacing} dp',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Buttons'),
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ButtonRow(
                  label: 'FilledButton',
                  child: FilledButton(
                    onPressed: null,
                    child: Text('Filled'),
                  ),
                ),
                _ButtonRow(
                  label: 'FilledTonalButton',
                  child: FilledButton.tonal(
                    onPressed: null,
                    child: Text('Tonal'),
                  ),
                ),
                _ButtonRow(
                  label: 'OutlinedButton',
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text('Outlined'),
                  ),
                ),
                _ButtonRow(
                  label: 'TextButton',
                  child: TextButton(onPressed: null, child: Text('Text')),
                ),
                _ButtonRow(
                  label: 'IconButton',
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(Icons.favorite),
                  ),
                ),
                _ButtonRow(
                  label: 'FilledButton (disabled)',
                  child: FilledButton(
                    onPressed: null,
                    child: Text('Disabled'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Sliders'),
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _M3ESliderExample(
                  label: 'Standard slider',
                  initialValue: 45,
                ),
                SizedBox(height: 12),
                _M3ESliderExample(
                  label: 'Discrete slider (10 divisions)',
                  initialValue: 40,
                  divisions: 10,
                ),
                SizedBox(height: 12),
                _M3ERangeSliderExample(label: 'Range slider'),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Chips'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Chip(label: Text('Assist')),
                    const Chip(
                      label: Text('Filter'),
                      deleteIcon: Icon(Icons.close, size: 18),
                      onDeleted: null,
                    ),
                    const InputChip(label: Text('Input'), selected: true),
                    FilterChip(
                      label: const Text('Filter'),
                      selected: true,
                      onSelected: (_) {},
                    ),
                    const ChoiceChip(label: Text('Choice'), selected: true),
                    const ActionChip(label: Text('Action'), onPressed: null),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Cards'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Elevated Card', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'This is a standard Material 3 Card with elevation.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Filled Card', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: colorScheme.surfaceContainerHighest,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'This card uses surfaceContainerHighest with no elevation.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Progress Indicators'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LinearProgressIndicator', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text('CircularProgressIndicator', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Dialogs (visual)'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AlertDialog preview — this is what a dialog looks like:',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text('Dialog Title', style: textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'This is a dialog content preview. In a real dialog you would have action buttons below.',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: null,
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 8),
                          FilledButton(
                            onPressed: null,
                            child: Text('Confirm'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;
  const _ColorRow({
    required this.label,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Center(child: Icon(Icons.circle, size: 16, color: onColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'JetBrainsMono'),
          ),
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  final TextTheme textTheme;
  final TextStyle? style;
  final String label;
  const _TypeRow({
    required this.textTheme,
    required this.style,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontFamily: 'JetBrainsMono',
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 2),
          Text('The quick brown fox jumps over the lazy dog.', style: style),
        ],
      ),
    );
  }
}

class _ShapeExample extends StatelessWidget {
  final String label;
  final double radius;
  final double size;
  const _ShapeExample({
    required this.label,
    required this.radius,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono'),
        ),
        const Spacer(),
        Text(
          '${radius.toInt()} px',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TokenRow extends StatelessWidget {
  final String label;
  final String value;
  const _TokenRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono'),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _ButtonRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

class _M3ESliderExample extends StatefulWidget {
  final String label;
  final double initialValue;
  final int? divisions;

  const _M3ESliderExample({
    required this.label,
    this.initialValue = 50,
    this.divisions,
  });

  @override
  State<_M3ESliderExample> createState() => _M3ESliderExampleState();
}

class _M3ESliderExampleState extends State<_M3ESliderExample> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'JetBrainsMono',
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        M3ESlider(
          value: _value,
          min: 0,
          max: 100,
          divisions: widget.divisions,
          label: _value.round().toString(),
          onChanged: (value) => setState(() => _value = value),
        ),
      ],
    );
  }
}

class _M3ERangeSliderExample extends StatefulWidget {
  final String label;

  const _M3ERangeSliderExample({required this.label});

  @override
  State<_M3ERangeSliderExample> createState() => _M3ERangeSliderExampleState();
}

class _M3ERangeSliderExampleState extends State<_M3ERangeSliderExample> {
  RangeValues _values = const RangeValues(25, 75);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'JetBrainsMono',
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        M3ERangeSlider(
          value: _values,
          min: 0,
          max: 100,
          onChanged: (values) => setState(() => _values = values),
        ),
      ],
    );
  }
}
