import 'package:flutter/material.dart';

class HomeProfileSectionData {
  final String title;
  final IconData icon;
  final List<HomeProfileMenuItem> items;

  const HomeProfileSectionData({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class HomeProfileMenuItem {
  final String label;
  final IconData icon;
  final String? route;

  const HomeProfileMenuItem({
    required this.label,
    required this.icon,
    this.route,
  });
}

class HomeCategoryData {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accent;

  const HomeCategoryData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accent,
  });
}

class HomeOfficeBranch {
  final String name;
  final String address;
  final String mapQuery;
  final String phone;

  const HomeOfficeBranch({
    required this.name,
    required this.address,
    required this.mapQuery,
    required this.phone,
  });
}
