import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

// プレイリスト選択時のコールバック関数の型定義
// void Function(Playlist playlist) のエイリアス
// 関数型をより読みやすく、再利用可能にするためのtypedef
typedef PlaylistsListSelected = void Function(Playlist playlist);

class Playlists extends StatelessWidget {
  const Playlists({super.key, required this.playlistSelected});

  // コールバック関数: プレイリストが選択された時に呼び出される関数
  // アダプティブレイアウトで異なる処理（ページ遷移 vs 状態更新）を実現
  final PlaylistsListSelected playlistSelected;

  @override
  Widget build(BuildContext context) {
    return Consumer<FlutterDevPlaylists>(
      builder: (context, flutterDev, child) {
        final playlists = flutterDev.playlists;
        if (playlists.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // プレイリスト一覧をリスト表示Widgetに渡す
        return _PlaylistsListView(
          items: playlists,
          playlistSelected: playlistSelected, // コールバック関数を子Widgetに渡す
        );
      },
    );
  }
}

// プレイリストリスト表示Widget: StatelessWidget から StatefulWidget に変更
// ScrollController の管理のためにライフサイクルメソッドが必要
class _PlaylistsListView extends StatefulWidget {
  const _PlaylistsListView({
    required this.items,
    required this.playlistSelected,
  });

  final List<Playlist> items; // 表示するプレイリストのリスト
  final PlaylistsListSelected playlistSelected; // プレイリスト選択時のコールバック

  @override
  State<_PlaylistsListView> createState() => _PlaylistsListViewState();
}

class _PlaylistsListViewState extends State<_PlaylistsListView> {
  // ScrollController: スクロール位置や動作を制御するコントローラー
  // late キーワード: 非null型だがinitStateで初期化される変数
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // ScrollControllerを初期化（Widgetの生成時に1回だけ実行）
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // ScrollControllerのリソースを解放（メモリリークを防ぐ）
    // StatefulWidgetでリソースを持つ場合は必ずdisposeで解放
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // ScrollControllerを明示的に設定（スクロール制御が可能）
      controller: _scrollController,
      // widget.items でStatefulWidgetのプロパティにアクセス
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        var playlist = widget.items[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Image.network(
              playlist.snippet!.thumbnails!.default_!.url!,
            ),
            title: Text(playlist.snippet!.title!),
            subtitle: Text(playlist.snippet!.description!),
            onTap: () {
              // 従来のNavigator.push の代わりにコールバック関数を実行
              // 処理内容は親Widget（アダプティブレイアウト）が決定
              widget.playlistSelected(playlist);
            },
          ),
        );
      },
    );
  }
}
