import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/youtube/v3.dart';
// SplitView: 画面を水平または垂直に分割するWidget
// デスクトップ向けのマスター・詳細レイアウトを実現
import 'package:split_view/split_view.dart';

import 'playlist_details.dart';
import 'playlists.dart';

// アダプティブプレイリスト: デバイスとスクリーンサイズに応じてレイアウトを切り替え
class AdaptivePlaylists extends StatelessWidget {
  const AdaptivePlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery でデバイスの画面幅を取得
    final screenWidth = MediaQuery.of(context).size.width;
    // Theme からプラットフォーム情報を取得
    final targetPlatform = Theme.of(context).platform;

    // モバイルデバイスまたは狭い画面の場合のレイアウト判定
    if (targetPlatform == TargetPlatform.android ||
        targetPlatform == TargetPlatform.iOS ||
        screenWidth <= 600) {
      // 600px以下は狭い画面として扱う
      // モバイル向け: 単一画面でページ遷移ナビゲーション
      return const NarrowDisplayPlaylists();
    } else {
      // デスクトップ向け: 分割画面でマスター・詳細同時表示
      return const WideDisplayPlaylists();
    }
  }
}

// 狭い画面向けプレイリストWidget（モバイル・タブレット縦向け）
class NarrowDisplayPlaylists extends StatelessWidget {
  const NarrowDisplayPlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlutterDev Playlists')),
      body: Playlists(
        // コールバック関数: プレイリスト選択時の処理を定義
        // 従来のNavigator.push の代わりにGoRouterでページ遷移
        playlistSelected: (playlist) {
          context.go(
            // URI構築: パスパラメータとクエリパラメータを組み合わせ
            Uri(
              path: '/playlist/${playlist.id}', // プレイリストIDをパスに埋め込み
              queryParameters: <String, String>{
                'title': playlist.snippet!.title!, // タイトルをクエリパラメータで渡す
              },
            ).toString(),
          );
        },
      ),
    );
  }
}

// 広い画面向けプレイリストWidget（デスクトップ・タブレット横向け）
class WideDisplayPlaylists extends StatefulWidget {
  const WideDisplayPlaylists({super.key});

  @override
  State<WideDisplayPlaylists> createState() => _WideDisplayPlaylistsState();
}

class _WideDisplayPlaylistsState extends State<WideDisplayPlaylists> {
  // 現在選択されているプレイリストの状態を管理
  // null の場合は「プレイリストを選択してください」メッセージを表示
  Playlist? selectedPlaylist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBarタイトルを動的に変更: 選択状態に応じてタイトルを切り替え
      appBar: AppBar(
        title: selectedPlaylist == null
            ? const Text('FlutterDev Playlists') // 未選択時
            : Text(
                'FlutterDev Playlist: ${selectedPlaylist!.snippet!.title!}',
              ), // 選択時
      ),
      // SplitView: 画面を水平分割してマスター・詳細レイアウトを実現
      body: SplitView(
        viewMode: SplitViewMode.Horizontal, // 水平分割（左右に配置）
        children: [
          // 左側: プレイリスト一覧（マスター部分）
          Playlists(
            // コールバック関数: プレイリスト選択時にsetStateで状態更新
            // ページ遷移ではなく、右側の詳細表示を更新
            playlistSelected: (playlist) {
              setState(() {
                selectedPlaylist = playlist; // 選択されたプレイリストを状態に保存
              });
            },
          ),
          // 右側: プレイリスト詳細（詳細部分）
          // 条件付きWidget表示: プレイリストが選択されているかで切り替え
          if (selectedPlaylist != null)
            // 選択済み: 対応する詳細画面を表示
            PlaylistDetails(
              playlistId: selectedPlaylist!.id!,
              playlistName: selectedPlaylist!.snippet!.title!,
            )
          else
            // 未選択: プレースホルダーメッセージを表示
            const Center(child: Text('Select a playlist')),
        ],
      ),
    );
  }
}
