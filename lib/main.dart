import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'src/app_state.dart';
import 'src/playlist_details.dart';
import 'src/playlists.dart';

// Flutter公式YouTubeチャンネルのID
// From https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw
const flutterDevAccountId = 'UCwXdFgeE9KYzlDdR7TG9cMw';

// YouTube Data API v3 のAPIキー
// TODO: Replace with your YouTube API Key
const youTubeApiKey = 'AIzaNotAnApiKey';

// GoRouter設定: アプリのルーティング構造を定義
final _router = GoRouter(
  routes: <RouteBase>[
    // ルートパス（/）: プレイリスト一覧画面
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Playlists();
      },
      // 子ルート: ネストされたルーティング
      routes: <RouteBase>[
        // 動的パラメータ（:id）を含むルート
        // /playlist/PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG のような形式
        GoRoute(
          path: 'playlist/:id',
          builder: (context, state) {
            // クエリパラメータからプレイリスト名を取得
            final title = state.uri.queryParameters['title']!;
            // パスパラメータからプレイリストIDを取得
            final id = state.pathParameters['id']!;
            return PlaylistDetails(playlistId: id, playlistName: title);
          },
        ),
      ],
    ),
  ],
);

void main() {
  //  APIキーの設定チェック
  if (youTubeApiKey == 'AIzaNotAnApiKey') {
    print('youTubeApiKey has not been configured.');
    exit(1); // アプリを強制終了
  }

  runApp(
    // ChangeNotifierProvider: 状態管理のルートプロバイダー
    // アプリ全体で FlutterDevPlaylists の状態を共有
    ChangeNotifierProvider<FlutterDevPlaylists>(
      // create: プロバイダーのインスタンス生成
      // YouTube API クライアントを初期化してプレイリストデータを管理
      create: (context) => FlutterDevPlaylists(
        flutterDevAccountId: flutterDevAccountId,
        youTubeApiKey: youTubeApiKey,
      ),
      child: const PlaylistsApp(),
    ),
  );
}

// アプリのメインWidget（従来のMyAppから名前変更）
class PlaylistsApp extends StatelessWidget {
  const PlaylistsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router: GoRouter と統合されたMaterialApp
    // 従来の home プロパティの代わりに routerConfig を使用
    return MaterialApp.router(
      title: 'FlutterDev Playlists',
      // FlexColorScheme でライトテーマを設定
      // Material 3 デザインシステムに対応した赤色ベースのテーマ
      theme: FlexColorScheme.light(
        scheme: FlexScheme.red, // 赤色のカラースキーム
        useMaterial3: true, // Material 3 デザインを有効化
      ).toTheme,
      // ダークテーマ設定
      // 同じ赤色スキームのダーク版を適用
      darkTheme: FlexColorScheme.dark(
        scheme: FlexScheme.red,
        useMaterial3: true,
      ).toTheme,
      themeMode: ThemeMode.dark, // ダークモードを強制設定
      debugShowCheckedModeBanner: false, // デバッグバナーを非表示
      routerConfig: _router, // GoRouter の設定を適用
    );
  }
}
