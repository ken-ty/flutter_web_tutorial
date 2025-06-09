import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

// プレイリスト一覧画面の StatelessWidget
class Playlists extends StatelessWidget {
  const Playlists({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // アプリバーにタイトルを表示
      appBar: AppBar(title: const Text('FlutterDev Playlists')),
      // Consumer: Provider の状態変更を監視してUIを再構築
      body: Consumer<FlutterDevPlaylists>(
        // builder: 状態が変更されるたびに呼ばれるビルダー関数
        // flutterDev: Provider から取得した FlutterDevPlaylists インスタンス
        // child: 変更されない静的な子Widget（ここでは使用していない）
        builder: (context, flutterDev, child) {
          final playlists = flutterDev.playlists; // プレイリスト一覧を取得
          // データがまだ読み込まれていない場合の処理
          if (playlists.isEmpty) {
            // ローディングインジケーターを中央に表示
            return const Center(child: CircularProgressIndicator());
          }

          // データが存在する場合はリストビューを表示
          return _PlaylistsListView(items: playlists);
        },
      ),
    );
  }
}

// プライベートクラス: プレイリストのリスト表示Widget
class _PlaylistsListView extends StatelessWidget {
  const _PlaylistsListView({required this.items});

  final List<Playlist> items; // 表示するプレイリストのリスト

  @override
  Widget build(BuildContext context) {
    // ListView.builder: 大量のデータを効率的に表示するWidget
    // 必要な分だけアイテムを生成（メモリ効率が良い）
    return ListView.builder(
      itemCount: items.length, // リストの総アイテム数
      // itemBuilder: 各インデックスに対応するWidgetを生成
      itemBuilder: (context, index) {
        var playlist = items[index]; // 現在のインデックスのプレイリスト
        return Padding(
          padding: const EdgeInsets.all(8.0), // アイテム間の余白
          // ListTile: Material Design のリストアイテムWidget
          child: ListTile(
            // leading: 左側に表示するWidget（サムネイル画像）
            leading: Image.network(
              playlist.snippet!.thumbnails!.default_!.url!, // YouTube のサムネイルURL
            ),
            title: Text(playlist.snippet!.title!), // プレイリストのタイトル
            subtitle: Text(playlist.snippet!.description!), // プレイリストの説明
            // onTap: タップされた時の処理
            onTap: () {
              // GoRouter を使用してプレイリスト詳細画面に遷移
              context.go(
                // Uri クラスでパスとクエリパラメータを構築
                Uri(
                  path: '/playlist/${playlist.id}', // パスパラメータでプレイリストIDを渡す
                  queryParameters: <String, String>{
                    // クエリパラメータでプレイリスト名を渡す
                    'title': playlist.snippet!.title!,
                  },
                ).toString(), // URI を文字列に変換
              );
            },
          ),
        );
      },
    );
  }
}
