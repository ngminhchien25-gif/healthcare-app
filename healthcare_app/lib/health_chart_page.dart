import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:healthcare_app/health_helper.dart';
import 'package:healthcare_app/health_metric_type.dart';
import 'package:healthcare_app/health_metric_type_repository.dart';
import 'package:healthcare_app/health_record.dart';
import 'package:healthcare_app/health_record_repository.dart';

class HealthChartPage extends StatefulWidget {
  final String title;
  const HealthChartPage({super.key, required this.title});

  @override
  State<HealthChartPage> createState() => _HealthChartPageState();
}

class _HealthChartPageState extends State<HealthChartPage> {
  List<HealthMetricType> _types = [];
  List<HealthRecord> _records = [];
  int? _metricTypeId;
  int _days = 30;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    try {
      var types = await HealthMetricTypeRepository.getMetricTypes();
      if (!mounted) return;
      setState(() {
        _types = types;
        if (types.isNotEmpty) _metricTypeId = types.first.id;
      });
      if (_metricTypeId != null) _loadChart();
    } catch (ex) {
      if (!mounted) return;
      setState(() => _error = 'Không tải được danh mục chỉ số');
      debugPrint(ex.toString());
    }
  }

  void _loadChart() async {
    if (_metricTypeId == null) return;
    try {
      var data = await HealthRecordRepository.getChart(_metricTypeId!, _days);
      if (!mounted) return;
      setState(() {
        _records = data;
        _error = null;
      });
    } catch (ex) {
      if (!mounted) return;
      setState(() => _error = 'Không tải được dữ liệu biểu đồ');
      debugPrint(ex.toString());
    }
  }

  HealthMetricType? get _currentType {
    for (var t in _types) {
      if (t.id == _metricTypeId) return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    HealthMetricType? type = _currentType;
    double? minVal;
    double? maxVal;
    double? avgVal;

    if (_records.isNotEmpty) {
      minVal = _records.map((e) => e.value).reduce(math.min);
      maxVal = _records.map((e) => e.value).reduce(math.max);
      avgVal = _records.map((e) => e.value).reduce((a, b) => a + b) /
          _records.length;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _metricTypeId,
            decoration: const InputDecoration(labelText: 'Chọn loại chỉ số'),
            items: [
              for (var t in _types)
                DropdownMenuItem<int>(
                  value: t.id,
                  child: Text('${t.name} (${t.unit})'),
                ),
            ],
            onChanged: (value) {
              setState(() => _metricTypeId = value);
              _loadChart();
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (int d in [7, 30, 90])
                ChoiceChip(
                  label: Text('$d ngày'),
                  selected: _days == d,
                  onSelected: (_) {
                    setState(() => _days = d);
                    _loadChart();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          if (_records.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('Chưa có dữ liệu đo trong khoảng thời gian này'),
                ),
              ),
            )
          else ...[
            // Khung vẽ biểu đồ đường
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biểu đồ ${type?.name ?? ''} (${type?.unit ?? ''})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (type?.code.toUpperCase() == 'BLOOD_PRESSURE')
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Đường xanh dương: Tâm thu · Đường cam: Tâm trương',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _HealthLineChartPainter(
                          records: _records,
                          minNormal: type?.minNormal,
                          maxNormal: type?.maxNormal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Thống kê nhanh Thấp nhất / Trung bình / Cao nhất
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text('Thấp nhất'),
                          Text(
                            HealthHelper.formatNumber(minVal!),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text('Trung bình'),
                          Text(
                            avgVal!.toStringAsFixed(1),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text('Cao nhất'),
                          Text(
                            HealthHelper.formatNumber(maxVal!),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Chi tiết lịch sử đo (${_records.length} lần)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            for (var r in _records.reversed)
              ListTile(
                dense: true,
                leading: Icon(
                  HealthHelper.metricIcon(r.metricCode),
                  color: HealthHelper.isOutOfRange(r) ? Colors.red : null,
                ),
                title: Text(HealthHelper.formatRecordValue(r)),
                subtitle: Text(
                  '${HealthHelper.dateTime(r.measuredAt)}${r.note == null ? '' : ' · ${r.note}'}',
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _HealthLineChartPainter extends CustomPainter {
  final List<HealthRecord> records;
  final double? minNormal;
  final double? maxNormal;

  _HealthLineChartPainter({
    required this.records,
    this.minNormal,
    this.maxNormal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    const double leftPad = 38;
    const double rightPad = 14;
    const double topPad = 14;
    const double bottomPad = 24;

    final double chartW = size.width - leftPad - rightPad;
    final double chartH = size.height - topPad - bottomPad;
    if (chartW <= 0 || chartH <= 0) return;

    List<double> allVals = [
      ...records.map((e) => e.value),
      ...records.where((e) => e.secondaryValue != null).map((e) => e.secondaryValue!),
    ];
    double minY = allVals.reduce(math.min);
    double maxY = allVals.reduce(math.max);
    if (minY == maxY) {
      minY -= 5;
      maxY += 5;
    } else {
      double pad = (maxY - minY) * 0.15;
      minY -= pad;
      maxY += pad;
    }

    double toY(double v) =>
        topPad + chartH - ((v - minY) / (maxY - minY)) * chartH;
    double toX(int i) => records.length == 1
        ? leftPad + chartW / 2
        : leftPad + (i / (records.length - 1)) * chartW;

    // Vẽ lưới ngang và nhãn trục Y
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    for (int step = 0; step <= 4; step++) {
      double val = minY + (maxY - minY) * (step / 4);
      double y = toY(val);
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + chartW, y), gridPaint);
      _drawText(
        canvas,
        HealthHelper.formatNumber(val),
        Offset(2, y - 7),
        const TextStyle(color: Colors.black54, fontSize: 10),
      );
    }

    // Vẽ đường chính (Value)
    final mainPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = Colors.blue;

    Path mainPath = Path();
    for (int i = 0; i < records.length; i++) {
      double x = toX(i);
      double y = toY(records[i].value);
      if (i == 0) {
        mainPath.moveTo(x, y);
      } else {
        mainPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
    canvas.drawPath(mainPath, mainPaint);

    // Vẽ đường phụ (SecondaryValue - huyết áp tâm trương nếu có)
    if (records.any((e) => e.secondaryValue != null)) {
      final secPaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      final secDot = Paint()..color = Colors.orange;
      Path secPath = Path();
      bool started = false;
      for (int i = 0; i < records.length; i++) {
        double? sv = records[i].secondaryValue;
        if (sv == null) continue;
        double x = toX(i);
        double y = toY(sv);
        if (!started) {
          secPath.moveTo(x, y);
          started = true;
        } else {
          secPath.lineTo(x, y);
        }
        canvas.drawCircle(Offset(x, y), 3.0, secDot);
      }
      canvas.drawPath(secPath, secPaint);
    }

    // Nhãn ngày đầu và ngày cuối dưới trục X
    String firstDate =
        '${records.first.measuredAt.day}/${records.first.measuredAt.month}';
    String lastDate =
        '${records.last.measuredAt.day}/${records.last.measuredAt.month}';
    _drawText(
      canvas,
      firstDate,
      Offset(leftPad, topPad + chartH + 6),
      const TextStyle(color: Colors.black54, fontSize: 10),
    );
    if (records.length > 1) {
      _drawText(
        canvas,
        lastDate,
        Offset(leftPad + chartW - 26, topPad + chartH + 6),
        const TextStyle(color: Colors.black54, fontSize: 10),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _HealthLineChartPainter oldDelegate) => true;
}