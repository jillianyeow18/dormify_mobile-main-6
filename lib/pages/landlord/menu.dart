import 'package:flutter/material.dart';

final Map<String, List<String>> cityData = {
  "Kuala Lumpur": ["Kuala Lumpur"],
  "Kedah": ["Alor Setar", "Sungai Petani", "Kulim", "Jitra"],
  "Penang": [
    "Ayer Itam",
    "Balik Pulau",
    "Batu Ferringhi",
    "Batu Maung",
    "Bayan Lepas",
    "Bukit Mertajam",
    "Butterworth",
    "Gelugor",
    "Jelutong",
    "Kepala Batas",
    "Kubang Semang",
    "Nibong Tebal",
    "Penaga",
    "Penang Hill",
    "Perai",
    "Permatang Pauh",
    "Pulau Pinang",
    "Simpang Ampat",
    "Sungai Jawi",
    "Tanjong Bungah",
    "Tanjung Bungah",
    "Tasek Gelugor",
    "Tasek Gelugur",
    "USM Pulau Pinang"
  ],
  "Sabah": [
    "Kota Kinabalu",
    "Beaufort",
    "Beluran",
    "Keningau",
    "Kota Belud",
    "Kinabatangan",
    "Kudat",
    "Lahad Datu",
    "Pensiangan",
    "Tawau",
    "Sandakan",
    "Semporna"
  ],
};

final List<Map<String, dynamic>> facilities = [
  {'label': 'Swimming Pool', 'icon': Icons.pool},
  {'label': 'Gym', 'icon': Icons.fitness_center},
  {'label': 'Parking', 'icon': Icons.local_parking},
  {'label': 'Wi-Fi', 'icon': Icons.wifi},
  {'label': 'CCTV', 'icon': Icons.videocam},
  {'label': 'Playground', 'icon': Icons.sports_soccer},
  {'label': 'Garden', 'icon': Icons.park},
  {'label': 'Security', 'icon': Icons.security},
  {'label': 'Others', 'icon': Icons.more_horiz},
];
