require "rails_helper"

RSpec.describe Scraper::PoliteHttpClient do
  subject(:client) { described_class.new(user_agent: user_agent, interval: 5, sleeper: sleeper) }

  let(:user_agent) { "technology-radar-test" }
  let(:url) { "https://example.com/job_offers/1" }
  # 本当には待たず、呼ばれた秒数を記録するだけ（docs/design.md「取得部分の設計」）
  let(:waits) { [] }
  let(:sleeper) { ->(seconds) { waits << seconds } }

  describe "#get" do
    context "200が返るとき" do
      before { stub_request(:get, url).to_return(status: 200, body: "<html>求人</html>") }

      it "本文を返すこと" do
        expect(client.get(url)).to eq("<html>求人</html>")
      end

      it "User-Agentでアクセスすること" do
        client.get(url)
        expect(a_request(:get, url).with(headers: { "User-Agent" => user_agent })).to have_been_made
      end

      it "2回目以降は interval 秒待つこと" do
        client.get(url)
        client.get(url)
        expect(waits).to eq([ 5 ])
      end
    end

    [ 403, 429 ].each do |status|
      context "#{status}でアクセスが拒否されたとき" do
        before { stub_request(:get, url).to_return(status: status) }

        it "AccessRefusedを投げること" do
          expect { client.get(url) }.to raise_error(Scraper::AccessRefused)
        end
      end
    end

    [ 201, 302, 404, 500 ].each do |status|
      context "#{status}でリクエストが失敗したとき" do
        before { stub_request(:get, url).to_return(status: status) }

        it "RequestFailedが返ること" do
          expect { client.get(url) }.to raise_error(Scraper::RequestFailed)
        end
      end
    end

    context "タイムアウトしたとき" do
      before { stub_request(:get, url).to_timeout }

      it "RequestFailedが返ること" do
        expect { client.get(url) }.to raise_error(Scraper::RequestFailed)
      end
    end

    context "接続に失敗したとき" do
      before { stub_request(:get, url).to_raise(Errno::ECONNREFUSED) }

      it "RequestFailedが返ること" do
        expect { client.get(url) }.to raise_error(Scraper::RequestFailed)
      end
    end

    context "リダイレクトが返されたとき" do
      let(:redirect_url) { "https://example.com/redirected" }

      before { stub_request(:get, url).to_return(status: 302, headers: { "Location" => redirect_url }) }

      it "リダイレクト先に送らないこと" do
        begin
          client.get(url)
        rescue Scraper::RequestFailed
        end
        expect(a_request(:get, redirect_url)).not_to have_been_made
      end
    end
  end
end
