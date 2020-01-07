require 'capybara'
require 'watir'
require 'escape_utils'
require 'tty-spinner'
require 'byebug'
require 'http'

class AnkiWebClient
  COOKIE_PATH = File.expand_path('./.cookies')
  class CardType
    BASIC = 0
    BASIC_AND_REVERSED_CARD = 1
    BASIC_AND_OPTIONAL_REVERSED_CARD = 2
    BASIC_TYPE_IN_ANSWER = 3
    CLOZE = 4
  end

  def initialize(username, password)
    @browser = Watir::Browser.new :chrome, headless: true
    @browser.goto('https://ankiweb.net/account/login')
    if File.exist?('.cookies')
      @browser.cookies.load(COOKIE_PATH)
    else
      login(username, password)
    end
    # Extract the 2 tokens we need to make requests.
    @browser.goto('https://ankiweb.net/edit/')
    binding.pry
    @csrf_token = @browser.execute_script("return editor.csrf_token")
    @csrf_token_2 = @browser.execute_script("return editor.csrf_token_2")
    cookies = YAML.load_file(COOKIE_PATH)
    @session_token = cookies.find { |cookie| cookie[:name] == 'ankiweb' }[:value]
    @browser.close
  end

  def login(username, password)
    form = @browser.form(action: 'https://ankiweb.net/account/login')
    form.text_field(name: 'username').set(username)
    form.text_field(name: 'password').set(password)
    form.submit
    @browser.cookies.save '.cookies'
    self
  end

  def add_card(deck:, front:, back: nil, tag: '', card_type: CardType::CLOZE)
    response =
      http
        .headers(
          'Cookie' => "ankiweb=#{@session_token}",
          'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
          'X-Requested-With' => 'XMLHttpRequest',
          'Accept-Language' => 'en',
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip, deflate, br',
          'Referer' => 'https://ankiuser.net/edit/',
          'Origin' => "https://ankiuser.net",
          'Dnt' => 1,
          'Authority' => 'ankiuser.net',
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36',
        )
        .post(
          '/edit/save',
          form: {
            csrf_token: @csrf_token,
            data: [
              [
                EscapeUtils.escape_javascript(front),
                back.nil? ? '' : EscapeUtils.escape_javascript(back)
              ],
              "", # tag
            ].to_json,
            deck: deck,
            mid: '1524449011564', # card type?
         }
      )
    if response.code != '200'
      binding.pry
    end
    response.flush
  end

  private

  def http
    @http = HTTP.persistent('https://ankiuser.net')
  end
end
