import 'package:flutter/material.dart';
import 'package:ios_integration_demo/viewmodel/device_info_viewmodel.dart';
import 'package:provider/provider.dart';

class DeviceInfoScreen extends StatelessWidget {
  const DeviceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<DeviceInfoViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Информация об устройстве')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: viewmodel.data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }
            if (snapshot.hasData) {
              final info = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection(
                    title: 'Основное',
                    items: {
                      'Имя устройства': info['name'],
                      'Модель': info['model'],
                      'Локализованная модель': info['localizedModel'],
                      'Система': info['systemName'],
                      'Версия системы': info['systemVersion'],
                      'Язык': info['languageCode'],
                      'Регион': info['regionCode'],
                      'Валюта': info['currencyCode'],
                      'Язык/Регион': info['localeIdentifier'],
                    },
                  ),
                  _buildSection(
                    title: 'Производительность',
                    items: {
                      'Процессоров всего': info['cpuCount'],
                      'Активных процессоров': info['activeProcessorCount'],
                      'Физическая память (байт)': info['physicalMemory'],
                      'Имя хоста': info['hostName'],
                      'Система (hw.machine)': info['machine'],
                    },
                  ),
                  _buildSection(
                    title: 'Экран',
                    items: {
                      'Ширина экрана': info['screenWidth'],
                      'Высота экрана': info['screenHeight'],
                      'Масштаб экрана': info['screenScale'],
                      'Яркость': info['brightness'],
                    },
                  ),
                  _buildSection(
                    title: 'Аккумулятор и устройство',
                    items: {
                      'Уровень заряда': info['batteryLevel'],
                      'Состояние батареи': info['batteryState'],
                      'Ориентация': info['orientation'],
                      'Поддержка многозадачности': info['isMultitaskingSupported'],
                      'Интерфейс': info['userInterfaceIdiom'],
                    },
                  ),
                  _buildSection(
                    title: 'Сеть и оператор',
                    items: {
                      'IP-адрес Wi-Fi': info['ipAddress'],
                      'Оператор': info['carrierName'],
                      'Код страны (ISO)': info['isoCountryCode'],
                      'MCC': info['mobileCountryCode'],
                      'MNC': info['mobileNetworkCode'],
                    },
                  ),
                  _buildSection(
                    title: 'Безопасность и биометрия',
                    items: {
                      'Биометрия доступна': info['biometricAvailable'],
                      'Тип биометрии': info['biometricType'],
                    },
                  ),
                  _buildSection(
                    title: 'Датчики',
                    items: {
                      'Гироскоп': info['hasGyro'],
                      'Акселерометр': info['hasAccelerometer'],
                      'Магнитометр': info['hasMagnetometer'],
                    },
                  ),
                  _buildSection(
                    title: 'Хранилище',
                    items: {
                      'Общий объем': info['totalStorage'],
                      'Свободное место': info['freeStorage'],
                    },
                  ),
                  _buildSection(
                    title: 'Камера',
                    items: {
                      'Наличие камеры': info['hasCamera'],
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }
            return const Center(child: Text('Нет данных'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewmodel.getAllDeviceInfo(),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Map<String, dynamic> items,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...items.entries.map(
                  (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        e.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('${e.value ?? "н/д"}'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
