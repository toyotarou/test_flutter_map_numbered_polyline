import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  // ── 3 点ずつ × 5 本の経路 ──
  static final List<List<LatLng>> _polylinePoints = <List<LatLng>>[
    // ① 東京駅 → 秋葉原 → 浅草
    <LatLng>[
      const LatLng(35.680959, 139.767306),
      const LatLng(35.699739, 139.774473),
      const LatLng(35.710063, 139.810700),
    ],
    // ② 新宿 → 代々木公園 → 渋谷
    <LatLng>[
      const LatLng(35.690921, 139.700258),
      const LatLng(35.671736, 139.694944),
      const LatLng(35.658034, 139.701636),
    ],
    // ③ 品川 → お台場 → 羽田空港
    <LatLng>[
      const LatLng(35.628471, 139.738760),
      const LatLng(35.619630, 139.779829),
      const LatLng(35.549393, 139.784260),
    ],
    // ④ 上野 → 日暮里 → 田端
    <LatLng>[
      const LatLng(35.713768, 139.777254),
      const LatLng(35.727883, 139.770123),
      const LatLng(35.738923, 139.760508),
    ],
    // ⑤ 池袋 → 目白 → 高田馬場
    <LatLng>[
      const LatLng(35.728926, 139.711086),
      const LatLng(35.720198, 139.706031),
      const LatLng(35.713768, 139.703611),
    ],
  ];

  static final List<Color> _polylineColors = <Color>[
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  // ズームを 1 段階上下させる
  void _zoom(double delta) {
    final MapCamera cam = _mapController.camera;
    _mapController.move(cam.center, cam.zoom + delta);
  }

  /// 各ポリラインの「ほぼ中央」を計算（平均座標）
  List<LatLng> _polylineCenters() {
    return _polylinePoints.map(
      (List<LatLng> pts) {
        return LatLng(
          pts.map((LatLng p) => p.latitude).reduce((double a, double b) => a + b) / pts.length,
          pts.map((LatLng p) => p.longitude).reduce((double a, double b) => a + b) / pts.length,
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> centers = _polylineCenters();

    return Scaffold(
      appBar: AppBar(title: const Text('Clickable Numbered Polylines')),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialCenter: LatLng(35.6895, 139.6917), initialZoom: 11),
            children: <Widget>[
              // ベースマップ
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),

              // ポリライン
              // ignore: always_specify_types
              PolylineLayer(
                polylines: <Polyline<Object>>[
                  for (int i = 0; i < _polylinePoints.length; i++)
                    // ignore: always_specify_types
                    Polyline(points: _polylinePoints[i], color: _polylineColors[i], strokeWidth: 4),
                ],
              ),

              // クリック可能な番号付きマーカー
              MarkerLayer(
                markers: <Marker>[
                  for (int i = 0; i < centers.length; i++)
                    Marker(
                      point: centers[i],
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => print('Polyline ${i + 1} tapped'),
                        child: Container(
                          alignment: Alignment.center,

                          // ポリラインと同じ色
                          decoration: BoxDecoration(color: _polylineColors[i].withOpacity(0.9), shape: BoxShape.circle),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── ズームボタン ──
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: <Widget>[
                FloatingActionButton.small(heroTag: 'zoomIn', onPressed: () => _zoom(1), child: const Icon(Icons.add)),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                    heroTag: 'zoomOut', onPressed: () => _zoom(-1), child: const Icon(Icons.remove)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
