module Scraper
  # paiza の求人詳細ページ（HTML全体）から jobs の項目を取り出す。
  # DB にも HTTP にも触れない「原文 → Hash」の変換（docs/design.md「構成」）
  class PaizaParser
    # <br> の位置を、空白をまとめたあとに改行へ戻すための目印（私用領域の文字なので本文には出てこない）
    LINE_BREAK = "\u{E000}".freeze
    YEN_PER_MAN = 10_000

    def parse(html)
      doc = Nokogiri::HTML(html)
      salary_min, salary_max = salary_range(doc)

      {
        title: text_of(doc.at_css("h1")),
        company: text_of(doc.at_css("h2.a-heading-primary-large")),
        position: text_of(definition(doc, "職種名")),
        job_types: split_list(text_of(definition(doc, "職種"))),
        description: description(doc),
        salary_min: salary_min,
        salary_max: salary_max,
        technologies: technologies(doc),
        features: labels(definition(doc, "特徴"))
      }
    end

    private

    # paiza の各欄は <dt>見出し</dt><dd>中身</dd> の組で並んでいる
    def definition(doc, term)
      doc.css("dt").find { |dt| dt.text.strip == term }&.next_element
    end

    # <dd> の中に <span> のラベルとして並んでいる値（開発言語・特徴など）
    def labels(node)
      return [] unless node

      node.css("span").map { |span| span.text.strip }.reject(&:empty?)
    end

    # 「、」区切りの文章として書かれている値（職種・データベースなど）
    def split_list(text)
      return [] unless text

      text.split("、").map(&:strip).reject(&:empty?)
    end

    # 「主要開発技術」「開発言語」「フレームワーク」は <span> のラベルとして並んでいるが、「クラウドプラットフォーム」「データベース」は「、」区切りの文章として書かれているので、両方をまとめて返す
    def technologies(doc)
      spans = [ "主要開発技術", "開発言語", "フレームワーク" ].flat_map do |term|
        labels(definition(doc, term))
      end

      splits_japanese_comma = [ "クラウドプラットフォーム", "データベース" ].flat_map do |term|
        split_list(text_of(definition(doc, term)))
      end

      spans | splits_japanese_comma
    end

    # 「求人概要」欄の説明文。ブラウザの表示と同じく、ソース上の改行・連続する空白は1つの空白にまとめ、<br> だけを改行にする
    def description(doc)
      paragraph = doc.at_css("#job-offer-summary ~ div .o-recruiters-show__content-text p")
      return unless paragraph

      paragraph.css("br").each { |br| br.replace(LINE_BREAK) }
      paragraph.text.gsub(/[ \t\r\n]+/, " ").gsub(/ ?#{LINE_BREAK} ?/o, "\n").strip
    end

    # 給料は [下限, 上限]（万円）で返す。JSON-LD があればそこから、なければ「給与(想定年収)」欄の文字列から取る
    def salary_range(doc)
      json_ld_salary_range(doc) || text_salary_range(text_of(definition(doc, "給与(想定年収)")))
    end

    # JSON-LD（Schema.org の JobPosting）の baseSalary には円の数値で入っている
    def json_ld_salary_range(doc)
      value = job_posting(doc)&.dig("baseSalary", "value")
      return unless value

      [ value["minValue"], value["maxValue"] ].map { |yen| yen && (yen / YEN_PER_MAN) }
    end

    # 欄の文字列（例: "400万 〜 900万円 （※ 想定年収 は年収提示額を保証するものではありません）"）から読む
    def text_salary_range(text)
      return unless text
      text = text.delete(",")
      if text.include?("〜")
        min_text, max_text = text.split("〜", 2).map(&:strip)
        min_value = min_text[/(\d+)万/, 1]&.to_i
        max_value = max_text[/(\d+)万/, 1]&.to_i
        [ min_value, max_value ]
      else
        min_value = text[/(\d+)万/, 1]&.to_i
        [ min_value, nil ]
      end
    end

    def job_posting(doc)
      doc.css('script[type="application/ld+json"]').each do |script|
        data = JSON.parse(script.text)
        return data if data["@type"] == "JobPosting"
      end
      nil
    end

    def text_of(node)
      node&.text&.strip
    end
  end
end
