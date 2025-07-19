import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 📁 파일 선택 서비스
///
/// PDF 파일 선택 기능을 제공합니다.
/// 웹과 모바일/데스크탑 플랫폼의 차이를 처리합니다.
///
/// 나중에 메인 기능으로 통합 예정
class FilePickerService {
  // 인스턴스 생성 방지 (유틸리티 클래스)
  FilePickerService._();

  /// PDF 파일을 선택하고 결과를 반환합니다.
  ///
  /// Returns:
  /// - String: 모바일/데스크탑에서 파일 경로
  /// - Uint8List: 웹에서 파일 바이트 데이터
  /// - null: 선택 취소 또는 실패
  static Future<dynamic> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb, // 웹일 경우 true로 설정하여 bytes를 로드
      );

      if (result != null) {
        if (kIsWeb) {
          // 웹: bytes 데이터 반환
          final fileBytes = result.files.single.bytes;
          if (fileBytes != null) {
            print('✅ PDF 파일 선택됨 (웹): ${fileBytes.length} bytes');
            return fileBytes; // Uint8List 반환
          } else {
            print('❌ 웹에서 파일 bytes를 읽는 데 실패했습니다.');
            return null;
          }
        } else {
          // 모바일/데스크탑: 파일 경로 반환
          final filePath = result.files.single.path;
          if (filePath != null) {
            print('✅ PDF 파일 선택됨: $filePath');
            return filePath; // String 반환
          } else {
            print('❌ 파일 경로를 가져오는 데 실패했습니다.');
            return null;
          }
        }
      } else {
        print('ℹ️ PDF 파일 선택 취소됨.');
        return null;
      }
    } catch (e) {
      print('❌ 파일 선택 중 오류 발생: $e');
      return null;
    }
  }

  /// 선택된 파일이 웹용 바이트 데이터인지 확인
  static bool isWebFileData(dynamic fileData) {
    return fileData is Uint8List;
  }

  /// 선택된 파일이 모바일/데스크탑용 경로인지 확인
  static bool isFilePath(dynamic fileData) {
    return fileData is String;
  }
}
