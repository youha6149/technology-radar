# 求人の取得元 調査まとめ

調査日: 2026-10-24〜25。規約は要約ベースで確認したものを含むので、採用前に原文を確認する。

## 判定の軸
1. **取得してよいか**: robots.txt で求人パスが Disallow されていない / 利用規約でスクレイピングが明示的に禁止されていない / ログイン不要
2. **このアプリに合うか**: エンジニア専門か / 技術・働き方・給料が構造化されているか / HTMLに本文があるか（JS描画でないか）

※ 最初の調査では 1 だけで判定していて、2 が抜けていた（そのため Green・Greenhouse を推していた）。

## 一覧

### 使える（1を満たす）
| 取得元 | 方式 | エンジニア専門 | 構造化 | メモ | 根拠 |
|---|---|---|---|---|---|
| **paiza** | HTML + sitemap（`/sitemap.xml.gz`、career求人 約2.2万件、全件 `lastmod` あり） | ✅ | ✅ 開発言語 / フレームワーク / 特徴（働き方）/ 職種 / ポジション。給料は JSON-LD `baseSalary` に数値 | **採用**。1ページ約65KB（ページ全体）。給料は JSON-LD に数値。robots.txt は全許可。規約第24条5号は私的利用を超える利用の禁止のみ | https://paiza.jp/guide/kiyaku |
| Green | HTML + `/sitemap/jobs.xml`（約2.8万件、`lastmod` なし） | ❌ 職種混在 | 給料のみ JSON-LD に数値。技術なし | 不向き。1ページ約270KB。規約第11条は私的利用を超える使用の禁止のみ | https://www.green-japan.com/mobile/contents/terms |
| Greenhouse Job Board API | JSON（企業ごと、認証不要） | ❌ 企業ごとに混在（確認した1社では82件中28件） | ❌ 給料は「経験に応じ決定」、技術なし | 「特定の企業を追う」用途なら可 | https://developers.greenhouse.io/job-board.html |
| Lever Postings API | JSON（企業ごと） | ❌ 企業ごとに混在 | 未確認 | 同上。日本企業の実例は1社のみ確認 | https://github.com/lever/postings-api |
| Ashby Posting API | JSON（企業ごと） | ❌ | 未確認 | 日本企業の実例は未確認 | https://developers.ashbyhq.com/docs/public-job-posting-api |
| Forkwell Jobs | HTML + sitemap | ✅（約1,400件） | 未確認 | **本文がJavaScript描画**。HTMLには `<meta description>` の要約（技術と年収）のみ。ヘッドレスブラウザが必要 | https://forkwell.com/terms_of_use |
| type | HTML + sitemap | ❌ 職種混在 | 未確認 | 規約第4条は私的利用を超える利用の禁止のみ | https://type.jp/help/category_14.html |
| マイナビIT AGENT | HTML + sitemap | IT寄りだがエージェント型 | 未確認 | 規約第7条1項7号は私的利用を超える使用の禁止のみ | https://mynavi-agent.jp/privacy/kiyaku.html |

### グレー / 未確認
| 取得元 | 状況 |
|---|---|
| レバテックキャリア | 一覧 `/engineer/offer/search/` は Disallow、詳細は許可、`sitemap.xml` あり。ClaudeBot は全面禁止。自動アクセスは CloudFront で 403。規約（https://levtech.jp/legal/ 第7条）は過負荷・運営妨害の禁止のみ |
| Japan Dev / TokyoDev | エンジニア専門（英語、日本の企業）。robots.txt はほぼ許可。規約は確認できず（TokyoDevは403、Japan Devは404） |
| LAPRAS | JS描画。規約第18条2項の秘密情報に求人が含まれるか不明 |
| Findy | 求人パスは robots.txt で許可だが、規約本文が JS 描画で未確認。旧調査では第13条で禁止・第16条で秘密情報扱い → **使わない** |
| HRMOS / Talentio（企業の採用ページ） | robots.txt は制限なし。求職者向け規約は未確認 |
| Wantedly | 規約1.8 第10号で事前承諾のないスクレイピングを禁止（❌寄り） |
| doda | robots.txt の取得に失敗 |

### 使わない
| 取得元 | 理由 |
|---|---|
| Geekly | 規約第15条⑾でスクレイピングを明示的に禁止。第14条で求人情報は秘密保持の対象（保存済みHTMLは削除済み） |
| Offers | 規約第20条1項(16)でスクレイピングを禁止 |
| YOUTRUST | 規約第5条11号で自動的手段を禁止 |
| 転職ドラフト | 規約第13条1項⑮で巡回ツールを禁止 |
| HERP Careers | 規約第4条1項(9)でスクレイピングを禁止 |
| エン転職 | robots.txt で ClaudeBot を全面禁止 |
| ビズリーチ | 会員制。403 |
| Qiita Jobs | 2024-05-31 にサービス終了 |
| Remotive / We Work Remotely | 取得はできるが海外求人で、日本と条件が違いすぎる |
| ハローワーク求人情報API | 対象が自治体・職業訓練施設・職業紹介事業者で、個人は利用できない見込み |

## 取得したサンプル（`samples/` など。git には入れない）
実在の求人の内容を公開しないため、ファイル名（求人ID）は載せない。

| 内容 | 取得日 |
|---|---|
| Greenhouse の公開API（1社分の求人一覧） | 2026-10-24 |
| Green の sitemap と求人ページ2件 | 2026-10-24 |
| paiza の sitemap | 2026-10-25 |
| Forkwell Jobs の求人ページ1件（募集終了） | 2026-10-25 |
| paiza の求人ページ6件（ページ全体。`spec/local/` のテストのフィクスチャ） | 2026-10-25 |
| paiza の求人ページ20件（`.o-recruiters-show` の部分だけを切り出したもので、ページ全体ではない。`legacy/`） | 以前に取得 |
