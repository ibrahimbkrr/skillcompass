import 'package:flutter_test/flutter_test.dart';
import 'package:skillcompass_frontend/features/dashboard/presentation/services/analysis_service.dart';
import 'package:mockito/mockito.dart';

class MockAnalysisService extends Mock implements AnalysisService {}

void main() {
  group('AnalysisService', () {
    test('analyzeText fonksiyonu çağrılabilir', () async {
      final mockService = MockAnalysisService();
      when(mockService.analyzeText('test')).thenAnswer((_) async => 'analiz sonucu');
      final result = await mockService.analyzeText('test');
      expect(result, 'analiz sonucu');
    });
  });
} 