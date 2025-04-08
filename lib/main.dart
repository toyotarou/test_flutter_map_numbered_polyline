// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'numbered_polylines.dart';

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

  // サンプル用：各ポリラインの座標（StationLatLng 型）を定義
  static final List<List<StationLatLng>> _polylineStations = <List<StationLatLng>>[
    // Polyline 1: 東京駅 → 秋葉原 → 浅草
    <StationLatLng>[
      StationLatLng(stationName: '東京駅', lat: '35.680959', lng: '139.767306'),
      StationLatLng(stationName: '秋葉原', lat: '35.699739', lng: '139.774473'),
      StationLatLng(stationName: '浅草', lat: '35.710063', lng: '139.810700'),
    ],
    // Polyline 2: 新宿 → 代々木公園 → 渋谷
    <StationLatLng>[
      StationLatLng(stationName: '新宿', lat: '35.690921', lng: '139.700258'),
      StationLatLng(stationName: '代々木公園', lat: '35.671736', lng: '139.694944'),
      StationLatLng(stationName: '渋谷', lat: '35.658034', lng: '139.701636'),
    ],
    // Polyline 3: 品川 → お台場 → 羽田空港
    <StationLatLng>[
      StationLatLng(stationName: '品川', lat: '35.628471', lng: '139.738760'),
      StationLatLng(stationName: 'お台場', lat: '35.619630', lng: '139.779829'),
      StationLatLng(stationName: '羽田空港', lat: '35.549393', lng: '139.784260'),
    ],
    // Polyline 4: 上野 → 日暮里 → 田端
    <StationLatLng>[
      StationLatLng(stationName: '上野', lat: '35.713768', lng: '139.777254'),
      StationLatLng(stationName: '日暮里', lat: '35.727883', lng: '139.770123'),
      StationLatLng(stationName: '田端', lat: '35.738923', lng: '139.760508'),
    ],
    // Polyline 5: 池袋 → 目白 → 高田馬場
    <StationLatLng>[
      StationLatLng(stationName: '池袋', lat: '35.728926', lng: '139.711086'),
      StationLatLng(stationName: '目白', lat: '35.720198', lng: '139.706031'),
      StationLatLng(stationName: '高田馬場', lat: '35.713768', lng: '139.703611'),
    ],
  ];

  // 各ポリラインに対応する表示色
  static final List<Color> _polylineColors = <Color>[
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  // ズーム操作：1 段階ずつズームイン／ズームアウト
  void _zoom(double delta) {
    final MapCamera cam = _mapController.camera;
    _mapController.move(cam.center, cam.zoom + delta);
  }

  // マーカーがタップされた際、該当する polyline の stationName をダイアログで表示する
  void _onMarkerTap(int index) {
    final List<StationLatLng> stations = _polylineStations[index];
    final String stationNames = stations.map((StationLatLng s) => s.stationName).join('\n'); // 改行区切りに
    // ignore: inference_failure_on_function_invocation
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Polyline ${index + 1} Stations'),
        content: Text(stationNames),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clickable Numbered Polylines')),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialCenter: LatLng(35.6895, 139.6917), initialZoom: 11),
            children: <Widget>[
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              // 共通ウィジェットからポリラインと番号付きマーカーを描画
              NumberedPolylinesWidget(polylines: _polylineStations, colors: _polylineColors, onMarkerTap: _onMarkerTap),
            ],
          ),
          // ズームボタン（右下）
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
