#!/usr/bin/env ruby

require 'byebug'
require 'concurrent-ruby'
require 'engtagger'
require 'optparse'
require 'pry'
require 'smarter_csv'
require 'tty-prompt'

require_relative('anki_web_client')
require_relative('anki_writer')
require_relative('helpers')
require_relative('kindle_note_reader')

options = {}

OptionParser.new do |parser|
  parser.on(
    '-in',
    '--input-file FILEPATH',
    'Input file to turn into a Deck'
  ) { |v| options[:input_file] = File.expand_path(v) }
  parser.on(
    '-t',
    '--threads THREAD_COUNT',
    'Number of threads to make network requests (speeds up execution)'
  ) { |v| options[:threads] = v.to_i }
  parser.on(
    '-d',
    '--deck NAME',
    'The name of the deck to append cards to'
  ) {
    |v| options[:deck] = v
  }
end.parse!

DECK_NAME = options[:deck]
NUM_CONNECTIONS = options[:threads] || 1
MAX_WORDS_TO_HIDE = 3
POS_PUNCTUATION = %w[PP PPC PPD PPL PPR PPS LRB RRB]

config = JSON.parse(File.read(File.expand_path('./config.json')))
reader = KindleNoteReader.new(options[:input_file])
tagger = EngTagger.new

cards = []

reader.notes.each do |note|
  note_with_tags = tagger.get_readable(note).split(' ')
  # Find the word_pairs in the note that we'll hide.
  candidate_words_to_hide_with_tag = Set.new
  note_with_tags.each do |word_tag_pair|
    _, tag = word_tag_pair.split('/')
    if tag == 'CD' || tag == 'NNP' || tag == 'NN'
      candidate_words_to_hide_with_tag.add(word_tag_pair)
    end
  end
  # Shuffle the set so that we don't hide the first N words, but randomly dispersed words.
  candidate_words_to_hide_with_tag =
    Set.new(candidate_words_to_hide_with_tag).to_a.sample(MAX_WORDS_TO_HIDE)
  # Build the content and hide candidates.
  card_content = ''
  hide_count = 0
  note_with_tags.each_with_index do |word_tag_pair, index|
    word, tag = word_tag_pair.split('/')
    is_first_index = index.zero?
    can_add_space = !is_first_index && !POS_PUNCTUATION.include?(tag) # Not punctuation
    if candidate_words_to_hide_with_tag.member?(word_tag_pair) &&
       hide_count < MAX_WORDS_TO_HIDE
      hide_count += 1
      word = "{{c1::#{word}}}"
    end
    card_content << ' ' if can_add_space
    card_content << word
  end
  cards << {
    'front' => card_content,
  }
end

prompt = TTY::Prompt.new
unless prompt.yes?("This will create #{cards.size} cards in '#{DECK_NAME}'. Continue?")
  exit
end

writer = AnkiWriter.new(DECK_NAME)
writer.add_cards(cards)
writer.write

puts 'test'
