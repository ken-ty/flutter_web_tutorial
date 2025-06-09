import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:http/http.dart' as http;

// アプリの状態管理クラス: YouTube プレイリストデータを管理
// ChangeNotifier を継承することで、状態変更を UI に通知可能
class FlutterDevPlaylists extends ChangeNotifier {
  FlutterDevPlaylists({
    required String flutterDevAccountId,
    required String youTubeApiKey,
  }) : _flutterDevAccountId = flutterDevAccountId {
    // YouTube API クライアントを初期化
    // _ApiKeyClient でAPIキーを自動付与する仕組み
    _api = YouTubeApi(_ApiKeyClient(client: http.Client(), key: youTubeApiKey));
    // コンストラクタ実行時に非同期でプレイリストを読み込み
    _loadPlaylists();
  }

  // プライベートメソッド: チャンネルの全プレイリストを取得
  Future<void> _loadPlaylists() async {
    String? nextPageToken; // ページネーション用トークン
    _playlists.clear(); // 既存データをクリア

    // do-while ループで全ページを取得（YouTube APIは1回に最大50件まで）
    do {
      // YouTube Data API v3 でプレイリスト一覧を取得
      final response = await _api.playlists.list(
        ['snippet', 'contentDetails', 'id'], // 取得するフィールドを指定
        channelId: _flutterDevAccountId, // 対象チャンネルID
        maxResults: 50, // 1回のリクエストで取得する最大件数
        pageToken: nextPageToken, // 次ページのトークン
      );
      // 取得したプレイリストをリストに追加
      _playlists.addAll(response.items!);
      // アルファベット順にソート（大文字小文字を区別しない）
      _playlists.sort(
        (a, b) => a.snippet!.title!.toLowerCase().compareTo(
          b.snippet!.title!.toLowerCase(),
        ),
      );
      // UI に状態変更を通知（リビルドをトリガー）
      notifyListeners();
    } while (nextPageToken != null); // 次ページが存在する限り続行
  }

  final String _flutterDevAccountId; // チャンネルID（イミュータブル）
  late final YouTubeApi _api; // YouTube API クライアント（遅延初期化）

  // プレイリスト一覧を格納するプライベートリスト
  final List<Playlist> _playlists = [];
  // 外部からは読み取り専用でアクセス可能（UnmodifiableListView でカプセル化）
  List<Playlist> get playlists => UnmodifiableListView(_playlists);

  // プレイリストアイテムのキャッシュ（プレイリストID → アイテムリスト）
  final Map<String, List<PlaylistItem>> _playlistItems = {};

  // 指定されたプレイリストのアイテムを取得（遅延読み込み）
  List<PlaylistItem> playlistItems({required String playlistId}) {
    // キャッシュに存在しない場合は新規作成し、非同期で取得開始
    if (!_playlistItems.containsKey(playlistId)) {
      _playlistItems[playlistId] = []; // 空リストで初期化
      _retrievePlaylist(playlistId); // 非同期でデータ取得
    }
    // 読み取り専用リストを返す（データが非同期で追加される）
    return UnmodifiableListView(_playlistItems[playlistId]!);
  }

  // プライベートメソッド: 指定プレイリストの全動画を取得
  Future<void> _retrievePlaylist(String playlistId) async {
    String? nextPageToken;
    do {
      // プレイリスト内の動画一覧を取得
      var response = await _api.playlistItems.list(
        ['snippet', 'contentDetails'], // 動画の基本情報を取得
        playlistId: playlistId, // 対象プレイリストID
        maxResults: 25, // 1回のリクエストで取得する最大件数
        pageToken: nextPageToken,
      );
      var items = response.items;
      if (items != null) {
        // 取得した動画をキャッシュに追加
        _playlistItems[playlistId]!.addAll(items);
      }
      // UI に新しい動画が追加されたことを通知
      notifyListeners();
      nextPageToken = response.nextPageToken;
    } while (nextPageToken != null);
  }
}

// カスタムHTTPクライアント: 全リクエストに自動でAPIキーを付与
class _ApiKeyClient extends http.BaseClient {
  _ApiKeyClient({required this.key, required this.client});

  final String key; // YouTube Data API のAPIキー
  final http.Client client; // ベースとなるHTTPクライアント

  // 全てのHTTPリクエストをインターセプトしてAPIキーを追加
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // 既存のクエリパラメータに 'key' パラメータを追加
    final url = request.url.replace(
      queryParameters: <String, List<String>>{
        ...request.url.queryParametersAll, // 既存パラメータを保持
        'key': [key], // APIキーを追加
      },
    );

    // 新しいURLでリクエストを送信
    return client.send(http.Request(request.method, url));
  }
}
