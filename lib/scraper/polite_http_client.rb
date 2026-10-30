require "net/http"

module Scraper
  # 取得元に関係なく守る HTTP の礼儀をまとめる（docs/design.md「取得部分の設計」）:
  # 正直な User-Agent、2回目以降は毎回 interval 秒待つ、リダイレクトを追わない、タイムアウトを短めに明示する
  class PoliteHttpClient
    # 応答がない・接続できないなど、ステータスコードが返る前の失敗。どれも呼び出す側の扱いは同じなので RequestFailed にまとめる
    # （Net::OpenTimeout / Net::ReadTimeout は Timeout::Error、Errno::ECONNREFUSED などは SystemCallError の仲間）
    CONNECTION_ERRORS = [ Timeout::Error, SystemCallError, SocketError, IOError, OpenSSL::SSL::SSLError ].freeze

    def initialize(user_agent:, interval: 5, sleeper: ->(seconds) { sleep(seconds) }, open_timeout: 5, read_timeout: 10)
      @user_agent = user_agent
      @interval = interval
      @sleeper = sleeper
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @requested = false
    end

    # 200 なら本文を返す。403 / 429 は AccessRefused、それ以外の失敗は RequestFailed
    def get(url)
      wait_for_interval
      response = request(URI(url))
      handle_response(response, url)
    end

    private

    # 1回目は待たず、2回目以降は毎回 interval 秒待つ。失敗したリクエストのあとも待つ
    def wait_for_interval
      @sleeper.call(@interval) if @requested
      @requested = true
    end

    # Net::HTTP はリダイレクトを自動では追わない。3xx はそのまま返ってくるので handle_response で失敗にする
    def request(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                      open_timeout: @open_timeout, read_timeout: @read_timeout) do |http|
        http.get(uri.request_uri, "User-Agent" => @user_agent)
      end
    rescue *CONNECTION_ERRORS => e
      # rescue の中で raise すると、元の例外は自動で RequestFailed#cause に残る
      raise RequestFailed, "#{uri}: #{e.class}: #{e.message}"
    end

    def handle_response(response, url)
      case response.code
      when "200"
        body_of(response)
      when "403", "429"
        raise AccessRefused, "url: #{url}, status: #{response.code}"
      else
        raise RequestFailed, "url: #{url}, status: #{response.code}"
      end
    end

    # Net::HTTP は本文を文字コード不明（ASCII-8BIT）のバイト列で返す。paiza のページは UTF-8 なので、そのように読む
    def body_of(response)
      response.body.to_s.dup.force_encoding(Encoding::UTF_8)
    end
  end
end
