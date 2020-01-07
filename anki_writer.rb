# Create a valid import file to be added to Anki app.
# https://apps.ankiweb.net/docs/manual.html#importing-text-files
class AnkiWriter
  PATH = './output'
  DELIMITER = "\t".freeze
  NEWLINE = "\n".freeze

  def initialize(deck_name)
    @cards = []
    @deck_name = deck_name
  end

  def add_cards(cards)
    @cards = cards
  end

  def write(path = "#{PATH}/#{@deck_name}.txt")
    file = File.new(path, 'w')
    @cards.each do |card|
      front = card['front']
      back = card['back']
      front.gsub!("\n", "<br/>")
      file.write(front)
      if !back.nil?
        back.gsub!("\n", "<br/>")
        file.write(DELIMITER)
        file.write(back)
      end
      file.write(NEWLINE)
    end
    file.close
  end
end
