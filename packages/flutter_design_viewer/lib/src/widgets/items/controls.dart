import 'package:device_preview/device_preview.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_design/flutter_design.dart';
import 'package:flutter_design_viewer/flutter_design_viewer.dart';
import 'package:flutter_design_viewer/src/measures.dart';
import 'package:flutter_design_viewer/src/widgets/items/frames.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ionicons/ionicons.dart';

import 'buttons.dart';
import 'images.dart';

class DataBuilderPanel extends HookConsumerWidget {
  final FieldMetaData fieldMetaData;
  final ValueNotifier<Map<String, DataBuilder>> dataBuildersNotifier;
  const DataBuilderPanel({
    required this.fieldMetaData,
    required this.dataBuildersNotifier,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataBuilder = dataBuildersNotifier.value[fieldMetaData.name]!;
    final dataBuilderOptions = ref.watch(dataBuilderOptionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: ShapeDecoration(
            color: theme.backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          child: Paddings.horizontal16(
            child: DropdownButton<DataBuilder>(
              items: dataBuilderOptions[fieldMetaData.name]!
                  .map((e) => DropdownMenuItem(
                        key: ValueKey(e.name),
                        child: Text(e.name),
                        value: e,
                      ))
                  .toList(),
              onChanged: _updateBuilder,
              underline: const SizedBox.shrink(),
              value: dataBuilder,
              isExpanded: true,
            ),
          ),
        ),
        dataBuilder.buildDesigner(context, _updateBuilder),
      ],
    );
  }

  void _updateBuilder(v) {
    dataBuildersNotifier.value = {
      ...dataBuildersNotifier.value,
      fieldMetaData.name: v!,
    };
  }
}

class SelectableThemeGroup extends HookConsumerWidget {
  final String value;
  final void Function(String) valueChanged;
  const SelectableThemeGroup({
    required this.value,
    required this.valueChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewerSettings = ref.watch(viewerSettingsProvider);
    return SelectableGlyphGroup<String>(
      items: viewerSettings.enabledThemes.keys,
      selectedItem: value,
      selectionChanged: (e) => valueChanged(e),
      builder: (context, e, [selected = false]) {
        final color = selected ? theme.primaryColor : null;
        return CircleAvatar(
          backgroundColor: color,
          radius: 10,
          child: CircleAvatar(
            backgroundColor:
                viewerSettings.enabledThemes[e]?.scaffoldBackgroundColor,
            radius: 8,
          ),
        );
      },
    );
  }
}

class SelectableDeviceGroup extends HookConsumerWidget {
  final String value;
  final void Function(String) valueChanged;
  const SelectableDeviceGroup({
    required this.value,
    required this.valueChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ExpandableController(initialExpanded: false);
    return SelectableContainer(
      child: ExpandablePanel(
        controller: controller,
        theme: ExpandableThemeData(
          tapBodyToExpand: true,
          alignment: Alignment.centerLeft,
          headerAlignment: ExpandablePanelHeaderAlignment.top,
          useInkWell: true,
          iconColor: theme.colorScheme.onBackground,
          iconPadding: EdgeInsets.zero,
          bodyAlignment: ExpandablePanelBodyAlignment.center,
        ),
        header: Paddings.top3(
          child: Text(
            value,
            style: theme.textTheme.bodyText2?.copyWith(
              color: theme.primaryColor,
            ),
          ),
        ),
        collapsed: const SizedBox.shrink(),
        expanded: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Text(
              'Select from the items below: ',
              style: theme.textTheme.caption,
            ),
            Paddings.all6(
              child: SelectableGlyphGroup<DeviceInfo>(
                items: Devices.all,
                selectedItem: Devices.all
                    .firstWhere((e) => e.identifier.toString() == value),
                selectionChanged: (e) {
                  controller.toggle();
                  valueChanged(e.identifier.toString());
                },
                builder: (context, e, [selected = false]) {
                  final color = selected ? theme.primaryColor : null;
                  return Text(
                    e.identifier.toString(),
                    style: theme.textTheme.bodyText2?.copyWith(color: color),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectableDevicesGroup extends HookConsumerWidget {
  final List<String> value;
  final void Function(List<String>) valueChanged;
  const SelectableDevicesGroup({
    required this.value,
    required this.valueChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SelectableContainer(
      child: ExpandablePanel(
        theme: ExpandableThemeData(
          tapBodyToExpand: true,
          alignment: Alignment.centerLeft,
          headerAlignment: ExpandablePanelHeaderAlignment.top,
          useInkWell: true,
          iconColor: theme.colorScheme.onBackground,
          iconPadding: EdgeInsets.zero,
        ),
        header: Paddings.top3(
          child: Text(
            '${value.length} devices',
            style: theme.textTheme.bodyText2?.copyWith(
              color: theme.primaryColor,
            ),
          ),
        ),
        collapsed: const SizedBox.shrink(),
        expanded: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Text(
              'Select from the items below: ',
              style: theme.textTheme.caption,
            ),
            Paddings.all6(
              child: MultiSelectableGlyphGroup<DeviceInfo>(
                items: Devices.all,
                selectedItems: Devices.all
                    .where((e) => value.contains(e.identifier.toString())),
                selectionChanged: (e) => valueChanged(
                    e.map((e) => e.identifier.toString()).toList()),
                builder: (context, e, [selected = false]) {
                  final color = selected ? theme.primaryColor : null;
                  return Text(
                    e.identifier.toString(),
                    style: theme.textTheme.bodyText2?.copyWith(color: color),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowDataBuilderToggle extends StatelessWidget {
  final bool value;
  final void Function(bool) valueChanged;
  const ShowDataBuilderToggle({
    Key? key,
    required this.value,
    required this.valueChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SelectableContainer(
      child: Tooltip(
        message: 'Show data builder',
        child: GestureDetector(
          onTap: () => valueChanged(!value),
          child: ThemableGlyph(
            glyph: ViewerGlyphUnion.icon(
              icon: Ionicons.server_outline,
              color:
                  value ? theme.primaryColor : theme.colorScheme.onBackground,
            ),
          ),
        ).asMouseClickRegion,
      ),
    );
  }
}

class SelectableDisplayModeGroup extends StatelessWidget {
  final DisplayMode value;
  final void Function(DisplayMode) valueChanged;
  const SelectableDisplayModeGroup({
    Key? key,
    required this.value,
    required this.valueChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SelectableGlyphGroup<DisplayMode>(
      items: DisplayMode.values,
      selectedItem: value,
      selectionChanged: (e) => valueChanged(e),
      builder: (context, e, [selected = false]) {
        final color = selected ? theme.primaryColor : null;
        return Tooltip(
            message: e.name,
            child: ThemableGlyph(
              glyph: {
                    DisplayMode.widgetOnly: ViewerGlyphUnion.icon(
                      icon: FeatherIcons.box,
                      color: color,
                    ),
                    DisplayMode.codeOnly: ViewerGlyphUnion.icon(
                      icon: Ionicons.code_slash,
                      color: color,
                    ),
                    DisplayMode.widgetCodeSideBySide: ViewerGlyphUnion.icon(
                      icon: FeatherIcons.sidebar,
                      color: color,
                    ),
                  }[e] ??
                  ViewerGlyphUnion.icon(
                    icon: Ionicons.help_outline,
                    color: color,
                  ),
            ));
      },
    );
  }
}

class SelectableViewModeGroup extends StatelessWidget {
  final ViewMode value;
  final void Function(ViewMode) valueChanged;
  const SelectableViewModeGroup({
    Key? key,
    required this.value,
    required this.valueChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SelectableGlyphGroup<ViewMode>(
      items: ViewMode.values,
      selectedItem: value,
      selectionChanged: (e) => valueChanged(e),
      builder: (context, e, [selected = false]) {
        final color = selected ? theme.primaryColor : null;
        return Tooltip(
          message: e.name,
          child: ThemableGlyph(
            glyph: {
                  ViewMode.canvas: ViewerGlyphUnion.icon(
                    icon: Ionicons.easel_outline,
                    color: color,
                  ),
                  ViewMode.devices: ViewerGlyphUnion.icon(
                    icon: Ionicons.phone_portrait_outline,
                    color: color,
                  ),
                  ViewMode.themes: ViewerGlyphUnion.icon(
                    icon: Ionicons.partly_sunny_outline,
                    color: color,
                  ),
                  ViewMode.locales: ViewerGlyphUnion.icon(
                    icon: Ionicons.language,
                    color: color,
                  ),
                }[e] ??
                ViewerGlyphUnion.icon(
                  icon: Ionicons.help_outline,
                  color: color,
                ),
          ),
        );
      },
    );
  }
}
