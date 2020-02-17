# Logic for writing a Deck to Anki.

require_relative('helpers')
require_relative('kindle_note_reader')
require_relative('anki_connect')

class AnkiWriter
  PATH = './output'
  DELIMITER = "\t".freeze
  NEWLINE = "\n".freeze
  attr_writer :input_file
  attr_reader :cards

  def initialize(deck_name, opts = {})
    @cards = []
    @deck_name = deck_name
    @opts = opts
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

  def write_to_anki
    connect = AnkiConnect.new
    connect.create_deck(@deck_name)
    connect.create_cards(@cards, @deck_name)
  end

  def generate_cards(card_type)
    fail 'No input file.' if @input_file.nil?
    case card_type
    when :cloze
      reader = KindleNoteReader.new(@input_file)
      @cards = []
      reader.notes.each do |note|
        @cards << {
          'front' => cloze_text(note),
        }
      end
    end
  end
end
