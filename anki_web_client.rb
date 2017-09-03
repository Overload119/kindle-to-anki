require 'capybara'
require 'watir'
require 'escape_utils'

class AnkiWebClient
  def initialize(username, password)
    @browser = Watir::Browser.new :chrome, headless: true
    @browser.goto('https://ankiweb.net/account/login')
    form = @browser.form(action: 'https://ankiweb.net/account/login')
    form.text_field(name: 'username').set(username)
    form.text_field(name: 'password').set(password)
    form.submit
  end

  def add_card(deck_name, front, back, tag = '')
    unless @browser.url == 'https://ankiweb.net/edit/'
      @browser.goto('https://ankiweb.net/edit/')
    end

    @browser.text_field(id: 'deck').set(deck_name)
    escaped_front = EscapeUtils.escape_javascript(front)
    @browser.execute_script("$('#f0').html('#{escaped_front}')")
    escaped_back = EscapeUtils.escape_javascript(back)
    @browser.execute_script("$('#f1').html('#{escaped_back}')")
    @browser.execute_script("editor.save()")
    Watir::Wait.until(5) { @browser.div(id: 'msg').visible? }
  end
end
