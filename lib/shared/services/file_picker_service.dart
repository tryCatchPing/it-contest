import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

// TODO(xodnd): 웹 지원 안해도 되는 구조로 수정

/// 📁 파일 선택 서비스
///
/// PDF 파일 선택 기능을 제공합니다.
/// 플랫폼에 관계없이 일관된 API를 제공합니다.
class FilePickerService {
  // 인스턴스 생성 방지 (유틸리티 클래스)
  FilePickerService._();

  /// PDF 파일을 선택하고 결과를 반환합니다.
  ///
  /// Returns:
  /// - String: 파일 경로 (path가 available한 경우)
  /// - Uint8List: 파일 바이트 데이터 (path가 없거나 withData 사용시)
  /// - null: 선택 취소 또는 실패
  static Future<dynamic> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // 항상 bytes 데이터 로드
      );

      if (result != null) {
        final file = result.files.single;

        // 파일 경로가 있으면 경로 우선 반환 (성능상 유리)
        if (file.path != null) {
          print('✅ PDF 파일 선택됨: ${file.path}');
          return file.path!; // String 반환
        }

        // 파일 경로가 없으면 바이트 데이터 반환
        if (file.bytes != null) {
          print('✅ PDF 파일 선택됨: ${file.bytes!.length} bytes');
          return file.bytes!; // Uint8List 반환
        }

        print('❌ 파일 데이터를 읽는 데 실패했습니다.');
        return null;
      } else {
        print('ℹ️ PDF 파일 선택 취소됨.');
        return null;
      }
    } catch (e) {
      print('❌ 파일 선택 중 오류 발생: $e');
      return null;
    }
  }

  /// 선택된 파일이 바이트 데이터인지 확인
  static bool isFileData(dynamic fileData) {
    return fileData is Uint8List;
  }

  /// 선택된 파일이 파일 경로인지 확인
  static bool isFilePath(dynamic fileData) {
    return fileData is String;
  }
}
