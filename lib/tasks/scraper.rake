namespace :scraper do
  # walking skeleton 用: samples/paiza/ の保存済みHTMLを取り込む（ネットワークは使わない）。
  # 原文 → jobs の変換は、後でテスト駆動の ParseRawDocument に置き換える（docs/todo.md）
  desc "samples/paiza/ の保存済み求人ページを raw_documents と jobs に取り込む"
  task import_samples: :environment do
    parser = Scraper::PaizaParser.new

    Rails.root.glob("samples/paiza/job_*.html").sort.each do |path|
      id = path.basename(".html").to_s.delete_prefix("job_")
      url = "https://paiza.jp/career/job_offers/#{id}"
      next puts("skip (取り込み済み): #{url}") if RawDocument.exists?(url: url)

      raw = RawDocument.create!(
        source: "paiza", url: url, content_type: "text/html",
        body: path.read, fetched_at: path.mtime
      )

      begin
        raw.create_job!(parser.parse(raw.body).merge(extracted_at: Time.current))
        puts "imported: #{url}"
      rescue StandardError => e
        # 原文は必ず残し、変換の失敗だけを記録する（docs/design.md「失敗の扱い」）
        raw.update!(parse_error: "#{e.class}: #{e.message}")
        puts "parse error: #{url} (#{e.message})"
      end
    end
  end

  # Parser を直したあとに、保存済みの原文すべてに Parser をかけ直す（再取得はしない。docs/design.md「データの持ち方」）
  desc "保存済みの raw_documents に Parser をかけ直して jobs を更新する"
  task reparse: :environment do
    parser = Scraper::PaizaParser.new

    RawDocument.where(source: "paiza").find_each do |raw|
      attributes = parser.parse(raw.body).merge(extracted_at: Time.current)
      raw.job ? raw.job.update!(attributes) : raw.create_job!(attributes)
      raw.update!(parse_error: nil)
      puts "reparsed: #{raw.url}"
    rescue StandardError => e
      raw.update!(parse_error: "#{e.class}: #{e.message}")
      puts "parse error: #{raw.url} (#{e.message})"
    end
  end
end
