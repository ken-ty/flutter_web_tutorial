import 'package:flutter/material.dart';

// エントリポイント。ここからプログラムの実行が開始される。
// Dart VM 上で実行される。
void main() {
  // アプリの実行。
  // runApp は Flutter Engine に Widget ツリーのルート（MyApp）を登録し、
  // Flutter Framework 側で WidgetsBinding を初期化して、
  // Element ツリーと RenderObject ツリーの構築を開始する。
  runApp(const MyApp());
}

// アプリのルートWidget（StatelessWidget）
// StatelessWidget: 状態を持たない不変のWidget
// アプリ全体の設定（テーマ、ルートページなど）を定義
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // build メソッド：Widget ツリーの構築を行う
  // BuildContext: Widget の位置情報や親子関係の情報を持つ
  //
  // そもそも build メソッドとは:
  // Widgetの見た目と構造を決めるメソッドのこと。 必ず @override する。
  // StatelessWidgetでは Widgetが作られた時に1度だけ呼ばれる。
  // StatefulWidgetでは 最初に作られた時、 状態変更された時、 親 Widget が再構築された時に呼ばれる。
  @override
  Widget build(BuildContext context) {
    // MaterialApp: Material Design のアプリケーションのルートWidget
    // アプリ全体のナビゲーション、テーマ、ローカライゼーションなどを管理
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple), // アプリ全体のテーマ設定
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// ホーム画面のWidget（StatefulWidget）
// StatefulWidget: 状態を持つことができる動的なWidget
// State オブジェクトと組み合わせて状態管理を行う
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title; // AppBar に表示するタイトル

  // createState: 対応する State オブジェクトを生成
  // StatefulWidget と State は分離されており、Widget は再構築されても
  // State オブジェクトは保持されるため状態が維持される
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State クラス：実際の状態とビジネスロジックを管理
// State<MyHomePage> により MyHomePage Widget と紐づく
class _MyHomePageState extends State<MyHomePage> {
  // 状態変数：カウンタの値を保持
  // _ から始まる変数名は Dart でプライベート変数を示す
  int _counter = 0;

  // イベントハンドラ：ボタンが押された時の処理
  // setState() を呼ぶことで Flutter Framework に状態変更を通知
  void _incrementCounter() {
    // setState: 状態変更を Framework に通知し、UI の再描画をトリガー
    // この関数内で状態変数を更新すると、build メソッドが再実行される
    setState(() {
      _counter++; // カウンタをインクリメント
    });
  }

  // build メソッド：UI の構造を定義（状態が変わるたびに呼ばれる）
  // setState が呼ばれるとこのメソッドが再実行され、UI が更新される
  @override
  Widget build(BuildContext context) {
    // Scaffold: Material Design の基本的な画面レイアウト構造
    // AppBar、Body、FloatingActionButton などの配置を管理
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          // MainAxisAlignment: 主軸（縦方向）の配置方法を指定
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter', // 文字列補間でカウンタ値を文字列に変換している
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
