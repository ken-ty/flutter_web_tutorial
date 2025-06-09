import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';

import 'app_state.dart';

// プレイリスト詳細画面の StatelessWidget
class PlaylistDetails extends StatelessWidget {
  const PlaylistDetails({
    required this.playlistId,
    required this.playlistName,
    super.key,
  });
  final String playlistId; // 表示するプレイリストのID
  final String playlistName; // AppBar に表示するプレイリスト名

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 動的にプレイリスト名をタイトルに設定
      appBar: AppBar(title: Text(playlistName)),
      // Consumer で状態管理オブジェクトを監視
      body: Consumer<FlutterDevPlaylists>(
        builder: (context, playlists, _) {
          // 指定されたプレイリストのアイテム（動画）を取得
          final playlistItems = playlists.playlistItems(playlistId: playlistId);
          // データがまだ読み込まれていない場合
          if (playlistItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // データが存在する場合は詳細リストを表示
          return _PlaylistDetailsListView(playlistItems: playlistItems);
        },
      ),
    );
  }
}

// プライベートクラス: プレイリスト内の動画一覧表示Widget
class _PlaylistDetailsListView extends StatelessWidget {
  const _PlaylistDetailsListView({required this.playlistItems});
  final List<PlaylistItem> playlistItems; // 表示する動画アイテムのリスト

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: playlistItems.length,
      itemBuilder: (context, index) {
        final playlistItem = playlistItems[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          // ClipRRect: 子Widgetの角を丸くクリップ
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4), // 4pxの角丸
            // Stack: 子Widgetを重ね合わせて配置するWidget
            // 動画サムネイル、グラデーション、テキスト、再生ボタンを重ねて表示
            child: Stack(
              alignment: Alignment.center, // 子Widgetを中央揃え
              children: [
                // 背景: 動画のサムネイル画像
                if (playlistItem.snippet!.thumbnails!.high != null)
                  Image.network(playlistItem.snippet!.thumbnails!.high!.url!),
                // グラデーションオーバーレイ（画像の上に重ねる）
                _buildGradient(context),
                // タイトルとサブタイトルのテキスト
                _buildTitleAndSubtitle(context, playlistItem),
                // 再生ボタン
                _buildPlayButton(context, playlistItem),
              ],
            ),
          ),
        );
      },
    );
  }

  // グラデーションオーバーレイを作成するメソッド
  Widget _buildGradient(BuildContext context) {
    // Positioned.fill: 親Stackの全領域を埋めるように配置
    return Positioned.fill(
      // DecoratedBox: 装飾（グラデーション）を適用するコンテナ
      child: DecoratedBox(
        decoration: BoxDecoration(
          // LinearGradient: 線形グラデーション
          gradient: LinearGradient(
            // 透明から現在のテーマの背景色へのグラデーション
            colors: [Colors.transparent, Theme.of(context).colorScheme.surface],
            begin: Alignment.topCenter, // 上部から開始
            end: Alignment.bottomCenter, // 下部で終了
            stops: const [0.5, 0.95], // グラデーションの開始・終了位置
          ),
        ),
      ),
    );
  }

  // タイトルとサブタイトルを配置するメソッド
  Widget _buildTitleAndSubtitle(
    BuildContext context,
    PlaylistItem playlistItem,
  ) {
    // Positioned: Stack内での絶対位置指定
    return Positioned(
      left: 20, // 左端から20px
      right: 0, // 右端まで
      bottom: 20, // 下端から20px
      child: Column(
        mainAxisSize: MainAxisSize.min, // 必要最小限の高さ
        crossAxisAlignment: CrossAxisAlignment.start, // 左揃え
        children: [
          // 動画のタイトル
          Text(
            playlistItem.snippet!.title!,
            // テーマからベーステキストスタイルを取得してカスタマイズ
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 18, // フォントサイズを18pxに変更
              // fontWeight: FontWeight.bold, // コメントアウト（太字にしない）
            ),
          ),
          // チャンネル名（存在する場合のみ表示）
          if (playlistItem.snippet!.videoOwnerChannelTitle != null)
            Text(
              playlistItem.snippet!.videoOwnerChannelTitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontSize: 12), // 小さめのフォント
            ),
        ],
      ),
    );
  }

  // 再生ボタンを作成するメソッド
  Widget _buildPlayButton(BuildContext context, PlaylistItem playlistItem) {
    // Stack: 白い背景円の上にアイコンボタンを重ね合わせ
    return Stack(
      alignment: AlignmentDirectional.center, // 中央揃え
      children: [
        // 白い円形の背景
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Colors.white, // 白色の背景
            borderRadius: BorderRadius.all(Radius.circular(21)), // 完全な円形
          ),
        ),
        // Link Widget: 外部URLへのリンク機能を提供
        Link(
          // YouTube の動画URLを構築
          uri: Uri.parse(
            'https://www.youtube.com/watch?v=${playlistItem.snippet!.resourceId!.videoId}',
          ),
          // builder: リンクの見た目を定義
          // followLink: リンクを開く関数（onPressedに渡す）
          builder: (context, followLink) => IconButton(
            onPressed: followLink, // タップ時にYouTubeページを開く
            color: Colors.red, // YouTubeブランドカラー
            icon: const Icon(Icons.play_circle_fill), // 再生アイコン
            iconSize: 45, // アイコンサイズ
          ),
        ),
      ],
    );
  }
}
