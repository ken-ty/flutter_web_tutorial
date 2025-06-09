// 1. dart:io ライブラリから Platform クラスのみをインポート
// Platform: 実行環境（OS）の情報を取得するためのクラス
import 'dart:io' show Platform;

// 2. flutter/foundation.dart から kIsWeb 定数のみをインポート
// kIsWeb: アプリがWebブラウザ上で動作しているかを判定するフラグ
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      // 3. ホーム画面を ResizeablePage に変更（レスポンシブ対応ページ）
      home: const ResizeablePage(),
    );
  }
}

// 4. レスポンシブ対応とプラットフォーム情報表示のページ
class ResizeablePage extends StatelessWidget {
  const ResizeablePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 5. MediaQuery: デバイスの画面情報（サイズ、解像度等）を取得
    // ウィンドウサイズ変更時に自動的に再描画される
    final mediaQuery = MediaQuery.of(context);

    // 6. Theme から現在のプラットフォーム情報を取得
    // Flutter が自動判定したプラットフォーム（TargetPlatform enum）
    final themePlatform = Theme.of(context).platform;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Window properties',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8), // 縦方向のスペース作成
            // 7. 固定幅のコンテナでテーブル表示エリアを制限
            SizedBox(
              width: 350,
              // 8. Table Widget: 行と列を持つテーブル形式のレイアウト
              // GridView より軽量で、データ表示に適している
              child: Table(
                textBaseline: TextBaseline.alphabetic, // テキストのベースライン揃え
                children: <TableRow>[
                  // 9. ウィンドウサイズの表示行
                  // MediaQuery から取得した画面サイズを小数点1桁で表示
                  _fillTableRow(
                    context: context,
                    property: 'Window Size',
                    value:
                        '${mediaQuery.size.width.toStringAsFixed(1)} x '
                        '${mediaQuery.size.height.toStringAsFixed(1)}',
                  ),

                  // 10. デバイスピクセル比の表示行
                  // 物理ピクセル数 ÷ 論理ピクセル数（高解像度ディスプレイ対応）
                  _fillTableRow(
                    context: context,
                    property: 'Device Pixel Ratio',
                    value: mediaQuery.devicePixelRatio.toStringAsFixed(2),
                  ),

                  // 11. 実際のプラットフォーム判定結果の表示行
                  // dart:io の Platform クラスによる実環境の検出結果
                  _fillTableRow(
                    context: context,
                    property: 'Platform.isXXX',
                    value: platformDescription(),
                  ),

                  // 12. Flutter Theme によるプラットフォーム判定の表示行
                  // Flutter Framework が判定したプラットフォーム情報
                  _fillTableRow(
                    context: context,
                    property: 'Theme.of(ctx).platform',
                    value: themePlatform.toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 13. テーブル行生成のヘルパーメソッド
  // プロパティ名と値を受け取って TableRow を生成する再利用可能な関数
  TableRow _fillTableRow({
    required BuildContext context,
    required String property,
    required String value,
  }) {
    return TableRow(
      children: [
        // 14. 左側セル：プロパティ名表示
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.baseline, // ベースライン揃え
          child: Padding(
            padding: const EdgeInsets.all(8.0), // セル内の余白
            child: Text(property),
          ),
        ),
        // 15. 右側セル：値表示
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.baseline,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(value),
          ),
        ),
      ],
    );
  }

  // 16. プラットフォーム判定ロジック
  // 実行環境に応じて適切なプラットフォーム名を返す
  String platformDescription() {
    // 17. Web環境の優先判定（kIsWeb は コンパイル時定数）
    if (kIsWeb) {
      return 'Web';
    }
    // 18. モバイルプラットフォームの判定
    else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    }
    // 19. デスクトッププラットフォームの判定
    else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    }
    // 20. その他・未来のプラットフォーム対応
    else if (Platform.isFuchsia) {
      return 'Fuchsia'; // Google の次世代OS
    } else {
      return 'Unknown'; // 未知のプラットフォーム
    }
  }
}
