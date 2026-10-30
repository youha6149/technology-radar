require "rails_helper"

RSpec.describe Scraper::PaizaParser do
  describe "#parse" do
    subject(:result) { described_class.new.parse(html) }

    context "紛らわしい要素（おとり）を含む架空の求人ページのとき" do
      let(:html) { file_fixture("fake/paiza_job_offer.html").read }

      it "タイトルが取得できること" do
        expect(result[:title]).to eq("架空の求人タイトル【リモート可】Rails で社内ツールを作る")
      end

      it "会社名が取得できること" do
        expect(result[:company]).to eq("株式会社サンプル")
      end

      it "職種名が取得できること" do
        expect(result[:position]).to eq("Webアプリケーションエンジニア")
      end

      it "職種が取得できること" do
        expect(result[:job_types]).to eq([ "バックエンド/サーバサイド", "フロントエンド" ])
      end

      it "給与下限が取得できること" do
        expect(result[:salary_min]).to eq(500)
      end

      it "給与上限が取得できること" do
        expect(result[:salary_max]).to eq(800)
      end

      it "技術スタックが取得できること" do
        expect(result[:technologies]).to eq([ "Ruby", "TypeScript", "SQL", "Ruby on Rails", "React", "Amazon Web Services", "Google Cloud", "PostgreSQL", "Redis" ])
      end

      it "特徴が取得できること" do
        expect(result[:features]).to eq([ "フルリモート", "副業OK", "フレックス" ])
      end

      it "業務内容が求人概要の最初の一文で始まること" do
        expect(result[:description]).to start_with("株式会社サンプルは、架空の会社です。")
      end

      it "業務内容が隣の欄の見出しを含まないこと" do
        expect(result[:description]).not_to include("職種名")
      end
    end

    context "技術が複数の欄に重複して書かれているとき" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <dt>主要開発技術</dt>
              <dd>
                <span>Ruby</span>
              </dd>
              <dt>開発言語</dt>
              <dd>
                <span>Ruby</span>
                <span>TypeScript</span>
              </dd>
            </body>
          </html>
        HTML
      end

      it "重複を除いた技術スタックが取得できること" do
        expect(result[:technologies]).to eq([ "Ruby", "TypeScript" ])
      end
    end

    context "給与欄に上限が存在しないとき" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <dt>給与(想定年収)</dt>
              <dd>348万 〜 </dd>
            </body>
          </html>
        HTML
      end

      it "給与上限が nil になること" do
        expect(result[:salary_max]).to be_nil
      end

      it "給与下限が正しく取得できること" do
        expect(result[:salary_min]).to eq(348)
      end
    end

    context "給与欄に下限が存在しないとき" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <dt>給与(想定年収)</dt>
              <dd> 〜 450万円</dd>
            </body>
          </html>
        HTML
      end

      it "給与下限が nil になること" do
        expect(result[:salary_min]).to be_nil
      end

      it "給与上限が正しく取得できること" do
        expect(result[:salary_max]).to eq(450)
      end
    end

    context "給与にカンマが含まれるとき" do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <dt>給与(想定年収)</dt>
              <dd>1,000万 〜 1,500万円</dd>
            </body>
          </html>
        HTML
      end

      it "給与下限が正しく取得できること" do
        expect(result[:salary_min]).to eq(1000)
      end

      it "給与上限が正しく取得できること" do
        expect(result[:salary_max]).to eq(1500)
      end
    end

    context "給与欄が存在しないとき" do
      let(:html) do
        <<~HTML
          <html>
            <body>
            </body>
          </html>
        HTML
      end

      it "給与下限が nil になること" do
        expect(result[:salary_min]).to be_nil
      end

      it "給与上限が nil になること" do
        expect(result[:salary_max]).to be_nil
      end
    end
  end
end
