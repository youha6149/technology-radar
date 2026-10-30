# 決定事項の早見表

実装中に見返す用。理由や経緯は design.md を見る。決定が変わったらここも直す。

## jobs の各カラムの取り方（paiza）

| カラム | ページのどこから | 型 | メモ |
|---|---|---|---|
| `title` | `<h1>`（求人タイトル） | 文字列 | 職種名ではない |
| `company` | 会社名（`<h2>`） | 文字列 | |
| `position` | 「職種名」欄 | 文字列 | 職種名だけ |
| `job_types` | 「職種」欄 | 配列 | 「、」で分割 |
| `salary_min` / `salary_max` | JSON-LD `baseSalary` の `minValue` / `maxValue` | 整数（**万円**） | 円 → 万円に変換 |
| `technologies` | 主要開発技術・開発言語・フレームワーク（span）＋ クラウドプラットフォーム・データベース（「、」区切りの文章） | 配列 | 完全に同じ文字列の重複は除く。表記ゆれはそのまま |
| `features` | 「特徴」欄（span） | 配列 | |
| `description` | 「求人概要」の説明文 | 文字列 | |

**jobs に持たないもの**（原文に残っているので、必要になったら再抽出で足す）

| 項目 | 理由 |
|---|---|
| ポジション（例: テックメンバー） | 情報を絞るため |
| 応募要件 | 同上。分析で必要になったら `requirements` を足す |
| 開発内容タイプ（例: B2C, SaaS） | 技術ではない。将来の「分野」カラムで使う |

## テストの書き方

- `describe` はメソッド名（`"#parse"`）、`context` と `it` は日本語
  - `context` は「〜のとき」「〜の場合」で終わる（`.rubocop.yml` の `RSpec/ContextWording`）
  - `it` は「〜こと」で統一する（例: 「会社名が取得できること」）。「正しい」は付けない
- 1つの `it` で確かめることは1つ（`RSpec/ExampleLength`、`RSpec/MultipleExpectations`）
- 長い文章は全文一致にしない。「端」（`start_with`）と「隣」（`not_to include`）で確かめる
- 公開するテスト（`spec/lib/`）は架空の HTML だけを使う: `spec/fixtures/files/fake/`（おとり入りの架空の求人ページ）か、spec の中に書く小さな HTML
- 実在の求人ページを使うテストは `spec/local/`（git で追跡しない）に置く。フィクスチャは `spec/fixtures/files/paiza/`（これも git には入れない）
- rubocop-rspec のルールは緩めない。緩めるときは承認を得て、`.rubocop.yml` に理由を書く

## 評価（reactions）

- +1 / -1 の2択。0 はない。判断できなければスキップ（行を作らない）
- 理由は質問形式。+1「何が良かった？」/ -1「何が合わなかった？」

## ファイルの置き場所

| もの | 場所 |
|---|---|
| 取得部分（Fetcher / Parser / Runner） | `lib/scraper/`（`Scraper::`） |
| 取得元の調査結果 | `docs/job-sources.md` |
| 取得したサンプル | `samples/`（git には入れない） |
| 古いスクリプト | `legacy/`（git には入れない。Geekly 向けなど公開できないスクリプトを含む） |

## やり残し

[docs/todo.md](todo.md) を見る。
