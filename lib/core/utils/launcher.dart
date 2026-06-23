import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility for launching phone calls, maps and links.
class Launcher {
  Launcher._();

  /// Opens the phone dialer with [phone] (e.g. "+77471234567").
  static Future<void> call(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось позвонить: $phone')),
        );
      }
    }
  }

  /// Opens Google Maps / Yandex Maps with a destination.
  static Future<void> navigate(
      BuildContext context, double lat, double lng, String label) async {
    // Try Google Maps first, fall back to geo URI.
    final googleMaps =
        Uri.parse('https://maps.google.com/?q=$lat,$lng($label)');
    final geo = Uri(scheme: 'geo', path: '$lat,$lng', query: 'q=$label');

    if (await canLaunchUrl(googleMaps)) {
      await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(geo)) {
      await launchUrl(geo);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Навигатор недоступен')),
        );
      }
    }
  }

  /// Opens the emergency number 103 (KZ ambulance) or 112 (universal).
  static Future<void> sos(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Экстренный вызов'),
        content: const Text(
            'Позвонить в службу экстренной помощи 112?\n\nЖедел қызметке 112 қоңырау шалу керек пе?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Позвонить 112')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await call(context, '112');
    }
  }
}
