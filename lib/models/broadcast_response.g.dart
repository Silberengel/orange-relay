// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BroadcastResponse _$BroadcastResponseFromJson(Map<String, dynamic> json) =>
    BroadcastResponse(
      success: json['success'] as bool,
      broadcasted_to: (json['broadcasted_to'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      failed_relays: (json['failed_relays'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      total_success: (json['total_success'] as num).toInt(),
      total_failed: (json['total_failed'] as num).toInt(),
      error: json['error'] as String?,
      relay_statuses: (json['relay_statuses'] as List<dynamic>?)
          ?.map((e) => RelayStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BroadcastResponseToJson(BroadcastResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'broadcasted_to': instance.broadcasted_to,
      'failed_relays': instance.failed_relays,
      'total_success': instance.total_success,
      'total_failed': instance.total_failed,
      'error': instance.error,
      'relay_statuses': instance.relay_statuses,
    };

RelayStatus _$RelayStatusFromJson(Map<String, dynamic> json) => RelayStatus(
      relay_url: json['relay_url'] as String,
      success: json['success'] as bool,
      error: json['error'] as String?,
      response_time_ms: (json['response_time_ms'] as num).toInt(),
      auth_required: json['auth_required'] as bool? ?? false,
      auth_successful: json['auth_successful'] as bool? ?? false,
    );

Map<String, dynamic> _$RelayStatusToJson(RelayStatus instance) =>
    <String, dynamic>{
      'relay_url': instance.relay_url,
      'success': instance.success,
      'error': instance.error,
      'response_time_ms': instance.response_time_ms,
      'auth_required': instance.auth_required,
      'auth_successful': instance.auth_successful,
    };

RelayStats _$RelayStatsFromJson(Map<String, dynamic> json) => RelayStats(
      relay_url: json['relay_url'] as String,
      is_online: json['is_online'] as bool,
      last_seen: (json['last_seen'] as num).toInt(),
      success_rate: (json['success_rate'] as num).toDouble(),
      average_response_time_ms:
          (json['average_response_time_ms'] as num).toInt(),
      total_broadcasts: (json['total_broadcasts'] as num).toInt(),
      successful_broadcasts: (json['successful_broadcasts'] as num).toInt(),
      failed_broadcasts: (json['failed_broadcasts'] as num).toInt(),
    );

Map<String, dynamic> _$RelayStatsToJson(RelayStats instance) =>
    <String, dynamic>{
      'relay_url': instance.relay_url,
      'is_online': instance.is_online,
      'last_seen': instance.last_seen,
      'success_rate': instance.success_rate,
      'average_response_time_ms': instance.average_response_time_ms,
      'total_broadcasts': instance.total_broadcasts,
      'successful_broadcasts': instance.successful_broadcasts,
      'failed_broadcasts': instance.failed_broadcasts,
    };
