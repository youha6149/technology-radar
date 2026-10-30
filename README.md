# Technology Radar

エンジニア求人を1件ずつ見て +1 / -1 を付け、**自分がワクワクする技術・仕事の傾向**を知るための個人用 Rails アプリです。

『ソフトウェアエンジニアリングの基礎』（オライリー・ジャパン）14章「キャリアマネジメント」の「自分の情熱を注げるものを見つける」をきっかけに作っています。利用者は自分だけです。

## できること

| 状態 | 機能 |
|---|---|
| ✅ | 求人をカードで1件ずつ表示する（会社名・求人タイトル・職種・年収・技術・特徴・業務内容） |
| ✅ | +1 / -1 / スキップを付ける（スキップした求人は未評価のまま残り、一周するとまた出てくる） |
| ✅ | +1 を付けた求人を一覧で見返す |
| ✅ | 保存済みの求人ページを取り込み、Parser を直したら保存済みの原文から再抽出する |
| 予定 | paiza の sitemap から新着の求人を取得する（Fetcher） |
| 予定 | 評価の理由を質問形式で記録する（「何が良かった？」「何が合わなかった？」） |
| 予定 | +1 / -1 の傾向（技術・職種・働き方）をグラフや表で見る |

予定の全体は [docs/todo.md](docs/todo.md) にあります。

## 技術スタック

- Ruby 3.3 / Rails 8.0 / SQLite
- Nokogiri（HTML の解析）
- RSpec / rubocop-rspec / WebMock

## 構成

```
lib/scraper/        取得部分（画面からは参照しない）
  paiza_parser.rb   求人ページの HTML → jobs の項目（Hash）。DB にも HTTP にも触れない
lib/tasks/
  scraper.rake      取り込み（scraper:import_samples）と再抽出（scraper:reparse）
app/                画面（求人カード、+1 / -1、+1 の一覧）
```

```
求人ページ（HTML）──保存──▶ raw_documents（原文をそのまま）──Parser──▶ jobs（集計に使う項目）
                                                  ▲
                                   Parser を直したら、ここから再抽出する（再取得はしない）
```

- **原文を必ず残す**: 何を分析軸にすべきかはまだ分からないので、抽出のルールを後から変えて、過去の分も抽出し直せるようにしています
- **Parser は副作用のない変換にする**: 取得（HTTP）と抽出を分けているので、Parser のテストは HTML だけで書けます
- DB は `raw_documents` / `jobs` / `reactions`（+1 / -1）/ `reasons`（評価の理由）の4テーブルです

## スクレイピングの方針

求人サイトの情報を扱うので、次のルールを決めて守っています。

**対象の選び方**
- robots.txt と利用規約の**両方**で禁止されていない、ログイン不要の公開ページだけを対象にします
- 約25の求人サイト・採用APIの robots.txt と規約を確認し、スクレイピングを規約で禁止しているサイトは対象から外しました（[docs/job-sources.md](docs/job-sources.md)）
- 現在の取得元は paiza 1つです（robots.txt で全許可、規約は私的利用の範囲を超える利用のみ禁止）

**取得のしかた**（取得部分の Fetcher は実装予定。以下はその方針です）
- 一覧はサイトが機械向けに公開している sitemap から取ります
- 1サイト1日30件まで、リクエストの間隔は5秒以上あけ、手動で実行します
- 取得済みの URL は再取得しません
- User-Agent はブラウザを装わず、正直に名乗ります。403 などで拒否されたら回避しません
- リダイレクトは追いません（存在しない求人が一覧ページへリダイレクトされるため）

**取得したデータの扱い**
- 個人利用に限り、公開・共有しません
- 取得した HTML とそれを使うテストは、このリポジトリに含めていません（`.gitignore`）。README やテストに出てくる求人はすべて架空のものです

## テストの工夫

Parser のテスト（`spec/lib/scraper/paiza_parser_spec.rb`）は、**実在の求人を使わず**に書いています。

- **おとり入りの架空の求人ページ**（[`spec/fixtures/files/fake/paiza_job_offer.html`](spec/fixtures/files/fake/paiza_job_offer.html)）: Parser の要素の選び方が雑だった場合に代わりに拾ってしまう要素（クラスのない h2、「職種」を含む「職種名」の欄、「特徴」を含む「その他の特徴」の欄、サイト名付きの `<title>` など）を、正しい要素より前に置いています。おとりの文言は「おとり: 〜」にそろえていて、間違った要素を拾うと失敗メッセージですぐ分かります
- **spec の中に書く小さな HTML**: 給料の書き方（カンマ区切り・上限なし・下限なし・欄なし）や技術の重複など、特定の入力だけを試すケース
- **実装をわざと壊して赤くなるか確かめる**: テストが本当に間違いを見つけられるかを確認しています
- 実在の求人ページを使うテストは手元だけで動かしています（`spec/local/`、git では追跡しない）

テストケースは自分で考え、AI（Claude Code）には答えではなく観点で問い返してもらう進め方で設計しています。

## 動かし方

```bash
bundle install
bin/rails db:prepare
bundle exec rspec        # テスト
bundle exec rubocop      # Lint
bin/rails s              # http://localhost:3000
```

求人ページの HTML はリポジトリに含めていないため、clone した直後は画面に求人が出ません。手元に保存した paiza の求人ページを `samples/paiza/job_<求人ID>.html` に置き、`bin/rails scraper:import_samples` で取り込みます。

## ドキュメント

| ファイル | 内容 |
|---|---|
| [docs/design.md](docs/design.md) | 設計メモ（目的・ユーザーストーリー・決定事項とその理由・経緯） |
| [docs/job-sources.md](docs/job-sources.md) | 求人の取得元の調査（robots.txt・規約の確認結果） |
| [docs/cheatsheet.md](docs/cheatsheet.md) | 実装中に見返す決定事項の早見表 |
| [docs/todo.md](docs/todo.md) | やり残し |
