import 'package:json_annotation/json_annotation.dart';

part 'broadcast_response.g.dart';

@JsonSerializable()
class BroadcastResponse {
  final bool success;
  final List<String> broadcasted_to;
  final List<String> failed_relays;
  final int total_success;
  final int total_failed;
  final String? error;
  final List<RelayStatus>? relay_statuses;

  const BroadcastResponse({
    required this.success,
    required this.broadcasted_to,
    required this.failed_relays,
    required this.total_success,
    required this.total_failed,
    this.error,
    this.relay_statuses,
  });

  factory BroadcastResponse.fromJson(Map<String, dynamic> json) => _$BroadcastResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BroadcastResponseToJson(this);

  /// Get success rate percentage
  double get successRate {
    final total = total_success + total_failed;
    if (total == 0) return 0.0;
    return (total_success / total) * 100;
  }

  /// Get success rate as string
  String get successRateString {
    return '${successRate.toStringAsFixed(1)}%';
  }

  /// Check if all relays succeeded
  bool get allSucceeded {
    return total_failed == 0 && total_success > 0;
  }

  /// Check if all relays failed
  bool get allFailed {
    return total_success == 0 && total_failed > 0;
  }

  /// Get status message
  String get statusMessage {
    if (allSucceeded) {
      return 'Successfully broadcasted to all $total_success relays';
    } else if (allFailed) {
      return 'Failed to broadcast to any relay';
    } else {
      return 'Broadcasted to $total_success/$total_success+$total_failed relays';
    }
  }
}

@JsonSerializable()
class RelayStatus {
  final String relay_url;
  final bool success;
  final String? error;
  final int response_time_ms;
  final bool auth_required;
  final bool auth_successful;

  const RelayStatus({
    required this.relay_url,
    required this.success,
    this.error,
    required this.response_time_ms,
    this.auth_required = false,
    this.auth_successful = false,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) => _$RelayStatusFromJson(json);
  Map<String, dynamic> toJson() => _$RelayStatusToJson(this);

  /// Get response time as string
  String get responseTimeString {
    if (response_time_ms < 1000) return '${response_time_ms}ms';
    return '${(response_time_ms / 1000).toStringAsFixed(1)}s';
  }

  /// Get status icon
  String get statusIcon {
    if (success) return '✅';
    if (auth_required && !auth_successful) return '🔐';
    return '❌';
  }

  /// Get status message
  String get statusMessage {
    if (success) {
      return 'Success (${responseTimeString})';
    } else if (auth_required && !auth_successful) {
      return 'Authentication failed';
    } else {
      return error ?? 'Unknown error';
    }
  }
}

@JsonSerializable()
class RelayStats {
  final String relay_url;
  final bool is_online;
  final int last_seen;
  final double success_rate;
  final int average_response_time_ms;
  final int total_broadcasts;
  final int successful_broadcasts;
  final int failed_broadcasts;

  const RelayStats({
    required this.relay_url,
    required this.is_online,
    required this.last_seen,
    required this.success_rate,
    required this.average_response_time_ms,
    required this.total_broadcasts,
    required this.successful_broadcasts,
    required this.failed_broadcasts,
  });

  factory RelayStats.fromJson(Map<String, dynamic> json) => _$RelayStatsFromJson(json);
  Map<String, dynamic> toJson() => _$RelayStatsToJson(this);

  /// Get success rate as percentage string
  String get successRateString {
    return '${(success_rate * 100).toStringAsFixed(1)}%';
  }

  /// Get average response time as string
  String get averageResponseTimeString {
    if (average_response_time_ms < 1000) return '${average_response_time_ms}ms';
    return '${(average_response_time_ms / 1000).toStringAsFixed(1)}s';
  }

  /// Get last seen as relative time
  String get lastSeenString {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = now - last_seen;
    
    if (diff < 60) return 'now';
    if (diff < 3600) return '${diff ~/ 60}m ago';
    if (diff < 86400) return '${diff ~/ 3600}h ago';
    return '${diff ~/ 86400}d ago';
  }

  /// Get status icon
  String get statusIcon {
    if (!is_online) return '🔴';
    if (success_rate >= 0.9) return '🟢';
    if (success_rate >= 0.7) return '🟡';
    return '🔴';
  }
}
