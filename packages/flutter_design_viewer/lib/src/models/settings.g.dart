// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ViewerState _$$_ViewerStateFromJson(Map<String, dynamic> json) =>
    _$_ViewerState(
      viewMode: $enumDecode(_$ViewModeEnumMap, json['viewMode']),
      targetDeviceId: json['targetDeviceId'] as String,
      targetDeviceIds: (json['targetDeviceIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      targetThemeId: json['targetThemeId'] as String,
      targetThemeIds: (json['targetThemeIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      targetLocaleId: json['targetLocaleId'] as String,
      targetLocaleIds: (json['targetLocaleIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      catalogId: json['catalogId'] as String?,
    );

Map<String, dynamic> _$$_ViewerStateToJson(_$_ViewerState instance) =>
    <String, dynamic>{
      'viewMode': _$ViewModeEnumMap[instance.viewMode],
      'targetDeviceId': instance.targetDeviceId,
      'targetDeviceIds': instance.targetDeviceIds,
      'targetThemeId': instance.targetThemeId,
      'targetThemeIds': instance.targetThemeIds,
      'targetLocaleId': instance.targetLocaleId,
      'targetLocaleIds': instance.targetLocaleIds,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode],
      'catalogId': instance.catalogId,
    };

const _$ViewModeEnumMap = {
  ViewMode.canvas: 'canvas',
  ViewMode.devices: 'devices',
  ViewMode.themes: 'themes',
  ViewMode.locales: 'locales',
};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

_$_Breakpoints _$$_BreakpointsFromJson(Map<String, dynamic> json) =>
    _$_Breakpoints(
      mobile: (json['mobile'] as num?)?.toDouble() ?? 320,
      tablet: (json['tablet'] as num?)?.toDouble() ?? 768,
      desktop: (json['desktop'] as num?)?.toDouble() ?? 1024,
    );

Map<String, dynamic> _$$_BreakpointsToJson(_$_Breakpoints instance) =>
    <String, dynamic>{
      'mobile': instance.mobile,
      'tablet': instance.tablet,
      'desktop': instance.desktop,
    };