import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../data/open_food_facts_client.dart';
import '../widgets/create_food_dialog.dart';
import '../widgets/serving_size_sheet.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({
    super.key,
    required this.mealType,
    required this.date,
  });

  final String mealType;
  final DateTime date;

  static Future<bool?> show(
    BuildContext context, {
    required String mealType,
    required DateTime date,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => BarcodeScannerScreen(
          mealType: mealType,
          date: date,
        ),
      ),
    );
  }

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _animController;
  final OpenFoodFactsClient _offClient = OpenFoodFactsClient();

  bool _isProcessing = false;
  bool _isTorchOn = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Поиск продукта в базе...';
    });

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    try {
      final foodDao = ref.read(foodDaoProvider);

      // ── Уровень 1: Поиск в локальной базе телефона (Drift SQLite) ──
      final localProduct = await foodDao.getFoodByBarcode(code);

      if (localProduct != null && mounted) {
        setState(() => _statusMessage = 'Найден в вашей базе!');
        final added = await ServingSizeSheet.show(
          context,
          product: localProduct,
          initialMealType: widget.mealType,
          date: widget.date,
        );

        if (added == true && mounted) {
          Navigator.of(context).pop(true);
          return;
        } else if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusMessage = null;
          });
          return;
        }
      }

      // ── Уровень 2: Поиск в базе Open Food Facts ──────────────────
      if (mounted) {
        setState(() => _statusMessage = 'Запрос в базу продуктов (Open Food Facts)...');
      }

      final remoteProduct = await _offClient.getByBarcode(code);

      if (remoteProduct != null && mounted) {
        setState(() => _statusMessage = 'Продукт найден! Сохраняем в базу...');

        final newId = await foodDao.insertFood(
          FoodProductsCompanion.insert(
            name: remoteProduct.name,
            brand: drift.Value(remoteProduct.brand),
            barcode: drift.Value(remoteProduct.barcode ?? code),
            caloriesPer100g: remoteProduct.calories,
            proteinPer100g: remoteProduct.protein,
            fatPer100g: remoteProduct.fat,
            carbsPer100g: remoteProduct.carbs,
            category: drift.Value(remoteProduct.category),
            sourceType: const drift.Value('open_food_facts'),
          ),
        );

        final importedProduct = await foodDao.getFoodById(newId);

        if (importedProduct != null && mounted) {
          final added = await ServingSizeSheet.show(
            context,
            product: importedProduct,
            initialMealType: widget.mealType,
            date: widget.date,
          );

          if (added == true && mounted) {
            Navigator.of(context).pop(true);
            return;
          } else if (mounted) {
            setState(() {
              _isProcessing = false;
              _statusMessage = null;
            });
            return;
          }
        }
      }

      // ── Уровень 3: Товар не найден нигде ─────────────────────────
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        await _showNotFoundDialog(code);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при поиске: $e')),
        );
      }
    }
  }

  Future<void> _showNotFoundDialog(String barcode) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.qr_code_scanner_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Штрих-код считан',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          barcode,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Этого товара пока нет в онлайн-базе. Вы можете внести его название и КБЖУ с упаковки один раз — он навсегда привяжется к этому штрихкоду на вашем телефоне!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'create'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Добавить продукт за 15 сек'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, 'cancel'),
                  child: const Text('Продолжить сканирование'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == 'create' && mounted) {
      final created = await CreateFoodDialog.show(context, initialBarcode: barcode);
      if (created != null && mounted) {
        final added = await ServingSizeSheet.show(
          context,
          product: created,
          initialMealType: widget.mealType,
          date: widget.date,
        );
        if (added == true && mounted) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  Future<void> _showManualInputDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ввод штрих-кода'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Введите 13 цифр штрих-кода с упаковки продукта:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Штрих-код (EAN-13)',
                hintText: '4607025392238',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(ctx, code);
              }
            },
            child: const Text('Найти'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      _handleBarcode(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.72;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Камера сканера ─────────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleBarcode(barcode.rawValue!);
                  break;
                }
              }
            },
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.videocam_off_rounded,
                          size: 48,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Камера недоступна',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Нет доступа к камере или это симулятор. Вы можете ввести штрих-код вручную.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _showManualInputDialog,
                        icon: const Icon(Icons.keyboard_rounded),
                        label: const Text('Ввести штрих-код'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Затемнение вокруг видоискателя (Cutout Overlay) ────────
          CustomPaint(
            size: size,
            painter: _ScannerOverlayPainter(
              scanBoxSize: scanAreaSize,
              borderColor: AppColors.primary,
            ),
          ),

          // ── Анимированная лазерная линия сканирования ──────────────
          if (!_isProcessing)
            Center(
              child: SizedBox(
                width: scanAreaSize - 20,
                height: scanAreaSize - 20,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment(0.0, _animController.value * 2.0 - 1.0),
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // ── Верхняя панель управления ──────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Назад',
                    ),
                    const Text(
                      'Сканер штрих-кода',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: _isTorchOn ? const Color(0xFFF59E0B) : Colors.white,
                          ),
                          onPressed: () async {
                            await _controller.toggleTorch();
                            setState(() => _isTorchOn = !_isTorchOn);
                          },
                          tooltip: 'Вспышка',
                        ),
                        IconButton(
                          icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                          onPressed: () => _controller.switchCamera(),
                          tooltip: 'Сменить камеру',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Индикатор загрузки / поиска ────────────────────────────
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.65),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage ?? 'Поиск...',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Нижняя панель с подсказкой и кнопкой ручного ввода ─────
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Наведите рамку на штрих-код продукта',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _showManualInputDialog,
                      icon: const Icon(Icons.keyboard_outlined, color: Colors.white, size: 18),
                      label: const Text(
                        'Ввести штрих-код вручную',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        backgroundColor: Colors.black38,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter для отрисовки видоискателя со скругленными уголками
class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({
    required this.scanBoxSize,
    required this.borderColor,
  });

  final double scanBoxSize;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    final left = (size.width - scanBoxSize) / 2;
    final top = (size.height - scanBoxSize) / 2;
    final rect = Rect.fromLTWH(left, top, scanBoxSize, scanBoxSize);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // Вырезаем прямоугольник видоискателя из полупрозрачного фона
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    // Рисуем стильные уголки
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;

    // Верхний левый
    canvas.drawLine(Offset(left + 8, top), Offset(left + 8 + cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left, top + 8), Offset(left, top + 8 + cornerLength), cornerPaint);

    // Верхний правый
    canvas.drawLine(Offset(left + scanBoxSize - 8, top),
        Offset(left + scanBoxSize - 8 - cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left + scanBoxSize, top + 8),
        Offset(left + scanBoxSize, top + 8 + cornerLength), cornerPaint);

    // Нижний левый
    canvas.drawLine(Offset(left + 8, top + scanBoxSize),
        Offset(left + 8 + cornerLength, top + scanBoxSize), cornerPaint);
    canvas.drawLine(Offset(left, top + scanBoxSize - 8),
        Offset(left, top + scanBoxSize - 8 - cornerLength), cornerPaint);

    // Нижний правый
    canvas.drawLine(Offset(left + scanBoxSize - 8, top + scanBoxSize),
        Offset(left + scanBoxSize - 8 - cornerLength, top + scanBoxSize), cornerPaint);
    canvas.drawLine(Offset(left + scanBoxSize, top + scanBoxSize - 8),
        Offset(left + scanBoxSize, top + scanBoxSize - 8 - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanBoxSize != scanBoxSize || oldDelegate.borderColor != borderColor;
  }
}
